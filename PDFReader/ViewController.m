// PDFViewController.m

#import "ViewController.h"
#import "PDFTextViewController.h"
#import "PDFPage.h"
#import "PDFScrollView.h"
#import "DocumentsView.h"
#import "OutlineViewController.h"

#define DOC_NAME @"drawingwithquartz2d"
//#define DOC_NAME @"sample"
//#define DOC_NAME @"oreilly-978-4-87311-549-8e"
void operator_Text(CGPDFScannerRef scanner, void* info){
    [(ViewController*)info operatorTextScanned:scanner];
}

void operator_Font(CGPDFScannerRef scanner,void* info){
    [(ViewController*)info operatorFontScanned:scanner];
}

void operator_Rect(CGPDFScannerRef scanner,void* info){
    [(ViewController*)info operatorFontScanned:scanner];
}
unichar unicharWithGlyph(CGGlyph glyph){
    int i;
    
    // グリフからUnicodeへのマップの作成
    static CGGlyph  _glyphs[65535];
    static BOOL     _initialized = NO;
    if (!_initialized) {
        // Unicodeテーブルの初期化
        UniChar unichars[65535];
        for (i = 0; i < 65535; i++) {
            unichars[i] = i;
        }
        
        // CTFontの作成
        CTFontRef   ctFont;
        ctFont = CTFontCreateWithName((CFStringRef)@"HiraKakuProN-W3", 10.0f, NULL);
        
        // Unicodeからグリフの取得
        CTFontGetGlyphsForCharacters(ctFont, unichars, _glyphs, 65535);
        
        // 初期化済みフラグの設定
        _initialized = YES;
    }
    
    // マップの検索
    for (i = 0; i < 65535; i++) {
        // 指定されたグリフが見つかった場合、そのインデクッスがunicodeとなっている
        if (_glyphs[i] == glyph) {
            return i;
        }
    }
    
    return 0;
}

@implementation ViewController

//--------------------------------------------------------------//
#pragma mark -- View --
//--------------------------------------------------------------//

- (void)viewDidLoad
{
    _subScrollView.controller = self;
    _array = [[NSMutableArray alloc]init];
    // PDFドキュメントの作成
    NSString*   path;
    NSURL*      url;
    path = [[NSBundle mainBundle] pathForResource:DOC_NAME ofType:@"pdf"];
    url = [NSURL fileURLWithPath:path];
    _document = CGPDFDocumentCreateWithURL((CFURLRef)url);
    
    [_mainScrollView addSubview:_innerView];// innerViewをメインスクロールビューに追加
    _mainScrollView.contentSize = _innerView.frame.size;// メインスクロールビューのコンテントサイズを設定
    _index = -1;// インデックスの初期値として-1を設定
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self _renewPages];
}

//--------------------------------------------------------------//
#pragma mark -- Image --
//--------------------------------------------------------------//

- (PDFPage*)_createPdfViewWithIndex:(int)index
{
    // PDF viewを作成
    PDFPage*    pdfView;
    pdfView = [[PDFPage alloc] initWithFrame:CGRectZero];
    [pdfView autorelease];
    
    // PDFページを取得
    CGPDFPageRef    page = NULL;
    if (index > 0 || index <= CGPDFDocumentGetNumberOfPages(_document)) {
        page = CGPDFDocumentGetPage(_document, index);
    }
    pdfView.page = page;
    
    // PDFの大きさを取得
    CGRect  pageRect = CGRectZero;
    float   scale = 1.0f;
    if (page) {
        pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    }
    if (CGRectGetWidth(pageRect) > 0) {
        scale = CGRectGetWidth(self.view.frame) / CGRectGetWidth(pageRect);
    }
    
    // 初期のPDF表示の大きさおよびスケールを設定
    pageRect.size.width *= scale;
    pageRect.size.height *= scale;
    pdfView.frame = pageRect;
    pdfView.scale = scale;
    
    return pdfView;
}

- (void)_renewPages
{
    CGRect          rect;
    
    // 現在のインデックスを保存
    int oldIndex = _index;
    
    // PDFのページ数を取得
    int pageNumber;
    pageNumber = CGPDFDocumentGetNumberOfPages(_document);
    
    // コンテントオフセットを取得
    CGPoint offset;
    offset = _mainScrollView.contentOffset;
    if (offset.x == 0) {
        // 前のページへ移動
        _index--;
    }
    if (offset.x >= _mainScrollView.contentSize.width - CGRectGetWidth(_mainScrollView.frame)) {
        // 次のページへ移動
        _index++;
    }
    
    // インデックスの値をチェック
    if (_index < 1) {
        _index = 1;
    }
    if (_index > pageNumber) {
        _index = pageNumber;
    }
    
    if (_index == oldIndex) {
        return;
    }
    
    //
    // 左側のPDF viewを更新
    //
    
    // 古いPDF Viewを解放
    [_pdfView0 removeFromSuperview];
    [_pdfView0 release], _pdfView0 = nil;
    
    // PDF Viewを作成
    _pdfView0 = [[self _createPdfViewWithIndex:_index - 1] retain];
    
    // 表示位置の設定
    rect.size = _pdfView0.frame.size;
    rect.origin = CGPointZero;
    if (!CGSizeEqualToSize(_pdfView0.frame.size, CGSizeZero)) {
        rect.origin.x += (CGRectGetWidth(self.view.frame) - CGRectGetWidth(rect)) * 0.5f;
        rect.origin.y += (CGRectGetHeight(self.view.frame) - CGRectGetHeight(rect)) * 0.5f;
    }
    _pdfView0.frame = rect;
    [_mainScrollView addSubview:_pdfView0];
    
    //
    // 中央のPDF view、サブスクロールビューを更新
    //
    
    // サブスクロールビューのframe
    rect.origin.x = CGRectGetMaxX(_pdfView0.frame) > 0 ?
    CGRectGetMaxX(_pdfView0.frame) + 20.0f : 0;
    rect.origin.y = 0;
    rect.size = self.view.frame.size;
    
    // サブスクロールビューの設定
    _subScrollView.frame = rect;
    
    // 古いPDF Viewを解放
    [_pdfView1 removeFromSuperview];
    [_pdfView1 release], _pdfView1 = nil;
    
    // PDF Viewを作成
    _pdfView1 = [[self _createPdfViewWithIndex:_index] retain];
    
    // 表示位置の設定
    rect.size = _pdfView1.frame.size;
    rect.origin = CGPointZero;
    if (!CGSizeEqualToSize(_pdfView1.frame.size, CGSizeZero)) {
        rect.origin.x += (CGRectGetWidth(self.view.frame) - CGRectGetWidth(rect)) * 0.5f;
        rect.origin.y += (CGRectGetHeight(self.view.frame) - CGRectGetHeight(rect)) * 0.5f;
    }
    _pdfView1.frame = rect;
    [_subScrollView addSubview:_pdfView1];
    
    // サブスクロールビューのコンテントサイズを設定
    _subScrollView.contentSize = rect.size;
    
    //
    // 右側のPDF viewを更新
    //
    
    // 古いPDF Viewを解放
    [_pdfView2 removeFromSuperview];
    [_pdfView2 release], _pdfView2 = nil;
    
    // PDF Viewを作成
    _pdfView2 = [[self _createPdfViewWithIndex:_index + 1] retain];
    
    // 表示位置の設定
    rect.size = _pdfView2.frame.size;
    rect.origin.x = CGRectGetMaxX(_subScrollView.frame) + 20.0f;
    rect.origin.y = 0;
    if (!CGSizeEqualToSize(_pdfView2.frame.size, CGSizeZero)) {
        rect.origin.x += (CGRectGetWidth(self.view.frame) - CGRectGetWidth(rect)) * 0.5f;
        rect.origin.y += (CGRectGetHeight(self.view.frame) - CGRectGetHeight(rect)) * 0.5f;
    }
    _pdfView2.frame = rect;
    [_mainScrollView addSubview:_pdfView2];
    
    //
    // メインスクロールビューの更新
    //
    
    // コンテントサイズとオフセットの設定
    CGSize  size;
    size.width = _index > 1 && _index < pageNumber ?
    (CGRectGetWidth(self.view.frame) + 20.0f) * 3.0f :
    (CGRectGetWidth(self.view.frame) + 20.0f) * 2.0f;
    size.height = 0;
    _mainScrollView.contentSize = size;
    _mainScrollView.contentOffset = _subScrollView.frame.origin;
}

- (void)frameToCenter
{
    // 現在のビューのサイズを取得
    CGSize size;
    size = self.view.bounds.size;
    
    // PDFビューのframeを取得
    CGRect  pdfFrame;
    pdfFrame = _pdfView1.frame;
    
    // 横方向の中央に移動
    if (CGRectGetWidth(pdfFrame) < size.width) {
        pdfFrame.origin.x = (size.width - CGRectGetWidth(pdfFrame)) * 0.5f;
    }
    else {
        pdfFrame.origin.x = 0;
    }
    
    // 縦方向の中央に移動
    if (CGRectGetHeight(pdfFrame) < size.height) {
        pdfFrame.origin.y = (size.height - CGRectGetHeight(pdfFrame)) * 0.5f;
    }
    else {
        pdfFrame.origin.y = 0;
    }
    
    // PDFビューのframeを設定
    _pdfView1.frame = pdfFrame;
}

//--------------------------------------------------------------//
#pragma mark -- Action --
//--------------------------------------------------------------//

- (IBAction)textAction{
    
    // PDFドキュメントを作成
    CGPDFDocumentRef    document;
    document = _document;
    
    // PDFページを取得
    CGPDFPageRef    page;
    page = CGPDFDocumentGetPage(_document, _index);
    
    // PDFコンテントストリームを取得
    _stream = CGPDFContentStreamCreateWithPage(page);
    
    // PDFオペレータテーブルを作成
    CGPDFOperatorTableRef   table;
    table = CGPDFOperatorTableCreate();
    CGPDFOperatorTableSetCallback(table, "TJ", operator_Text);
    CGPDFOperatorTableSetCallback(table, "Tj", operator_Text);
    CGPDFOperatorTableSetCallback(table, "Tf", operator_Font);
    CGPDFOperatorTableSetCallback(table, "Td", operator_Rect);
    CGPDFOperatorTableSetCallback(table, "TD", operator_Rect);
    CGPDFOperatorTableSetCallback(table, "Tm", operator_Rect);
    // PDFスキャナを作成
    CGPDFScannerRef scanner;
    scanner = CGPDFScannerCreate(_stream, table, self);
    
    // スキャンを開始
    [_text release], _text = nil;
    _text = [[NSMutableString string] retain];
    CGPDFScannerScan(scanner);
    
    // オブジェクトの解放
    CGPDFScannerRelease(scanner), scanner = NULL;
    CGPDFOperatorTableRelease(table), table = NULL;
    CGPDFContentStreamRelease(_stream), _stream = NULL;
    //CGPDFDocumentRelease(document), document = NULL;
    
    // コントローラの作成
    PDFTextViewController*  controller;
    controller = [[PDFTextViewController alloc] initWithNibName:@"TextView" bundle:nil];
    [controller autorelease];
    [controller loadView];
    
    // テキストの設定
    controller.textView.text = _text;
    
    // コントローラの表示
    [[UIApplication sharedApplication]
     setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self presentModalViewController:controller animated:YES];
}
#pragma mark --buttonAction
- (IBAction)showLibraryPopover:(UIBarButtonItem *)sender
{
    if (libraryPopover)
    {
        [libraryPopover dismissPopoverAnimated:NO];
        [libraryPopover release]; libraryPopover = nil;
        _outline = nil;
        return;
    }
    
    DocumentsView *docView = [[[DocumentsView alloc] init] autorelease];
	docView.delegate = self;
    libraryPopover = [[UIPopoverController alloc] initWithContentViewController:docView];
    libraryPopover.delegate = self;
    [libraryPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(IBAction)showOutlineDidPush:(id)sender{
    if(libraryPopover){
        [libraryPopover dismissPopoverAnimated:NO];
        [libraryPopover release]; libraryPopover = nil;
        _outline = nil;
        return;
    }
    
    if(!_outline){
        _outline = [[OutlineViewController alloc]initWithCGPDFDocument:_document];
    }
    
    [_outline setDelegate:self];
    _navigationController = [[UINavigationController alloc]initWithRootViewController:_outline];
    _outline.title = @"もくじ";
    libraryPopover = [[UIPopoverController alloc] initWithContentViewController:_navigationController];
    libraryPopover.delegate = self;
    [libraryPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}
- (NSString*)stringInPDFObject:(CGPDFObjectRef)object
{
    bool    result;
    
    // PDFオブジェクトタイプの取得
    CGPDFObjectType type;
    type = CGPDFObjectGetType(object);
    
    // タイプ別による処理
    switch (type) {
            // PDF文字列の場合
        case kCGPDFObjectTypeString: {
            // PDF文字列の取得
            CGPDFStringRef  string;
            result = CGPDFObjectGetValue(object, type, &string);
            if (!result) {
                return nil;
            }
            
            // MacRomanEcodingの場合
            if ([_encoding isEqualToString:@"MacRomanEncoding"]) {
                // CGPDFStringからNSStringへの変換
                NSString*   nsstring;
                nsstring = (NSString*)CGPDFStringCopyTextString(string);
                [nsstring autorelease];
                
                return nsstring;
            }
            
            // Identity-Hの場合
            if ([_encoding isEqualToString:@"Identity-H"]) {
                // バッファの作成
                NSMutableString*    buffer;
                buffer = [NSMutableString string];
                
                // バイトのポインタを取得
                const unsigned char*    tmp;
                tmp = CGPDFStringGetBytePtr(string);
                
                // NSStringへの変換
                int i;
                for (i = 0; i < CGPDFStringGetLength(string) / 2; i++) {
                    // CIDを取得
                    uint16_t    cid;
                    cid = *tmp++ << 8;
                    cid |= *tmp++;
                    
                    // CIDをunicharへ変換
                    unichar c;
                    c = unicharWithGlyph(cid);
                    if (c == 0) {
                        break;
                    }
                    
                    // NSStringへ変換して追加
                    NSString*   nsstring;
                    nsstring = [NSString stringWithCharacters:&c length:1];
                    if (nsstring) {
                        [buffer appendString:nsstring];
                    }
                }
                
                return buffer;
            }
        }
            
            // PDF配列の場合
        case kCGPDFObjectTypeArray: {
            // PDF配列の取得
            CGPDFArrayRef   array;
            result = CGPDFObjectGetValue(object, type, &array);
            if (!result) {
                return nil;
            }
            
            // バッファの作成
            NSMutableString*    buffer;
            buffer = [NSMutableString string];
            
            size_t  count;
            count = CGPDFArrayGetCount(array);
            
            // PDF配列の中身の取得
            int i;
            for (i = 0; i < count; i++) {
                // PDF配列からオブジェクトを取得
                CGPDFObjectRef  child;
                CGPDFArrayGetObject(array, i, &child);
                
                // テキストの抽出
                NSString*   nsstring;
                nsstring = [self stringInPDFObject:child];
                if (nsstring) {
                    [buffer appendString:nsstring];
                }
            }
            
            return buffer;
        }
    }
    
    return nil;
}

- (void)operatorTextScanned:(CGPDFScannerRef)scanner
{
    // PDFオブジェクトの取得
    CGPDFObjectRef  object;
    CGPDFScannerPopObject(scanner, &object);
    
    // テキストの抽出
    NSString*   string;
    string = [self stringInPDFObject:object];
    
    DebugLog(@"%@",string)
    // テキストの追加
    if (string) {
        [_text appendString:string];
        [_array addObject:string];
    }
}

- (void)operatorFontScanned:(CGPDFScannerRef)scanner
{
    bool    result;
    
    // フォントサイズの取得
    CGPDFInteger    size;
    result = CGPDFScannerPopInteger(scanner, &size);
    if (!result) {
        return;
    }
    
    // フォント名の取得
    const char* name;
    result = CGPDFScannerPopName(scanner, &name);
    if (!result) {
        return;
    }
    
    // フォントの取得
    CGPDFObjectRef  object;
    object = CGPDFContentStreamGetResource(_stream, "Font", name);
    if (!object) {
        return;
    }
    
    // PDF辞書の取得
    CGPDFDictionaryRef  dict;
    result = CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &dict);
    if (!result) {
        return;
    }
    
    // エンコーディングの取得
    const char* encoding;
    result = CGPDFDictionaryGetName(dict, "Encoding", &encoding);
    if (!result) {
        return;
    }
    
    // エンコーディングの設定
    [_encoding release], _encoding = nil;
    _encoding = [[NSString stringWithCString:encoding encoding:NSASCIIStringEncoding] retain];
}

//--------------------------------------------------------------//
#pragma mark -- UIScrollViewDelegate --
//--------------------------------------------------------------//

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView == _mainScrollView) {
        if (!decelerate) {[self _renewPages];}
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView{
    if (scrollView == _mainScrollView) {[self _renewPages];}
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView{
    if (scrollView == _subScrollView) {
        return _pdfView1;// 中央のPDF viewを使う
    }
    return nil;
}
#pragma mark userMethod
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if ([popoverController isEqual:libraryPopover])    {
        [libraryPopover release]; libraryPopover = nil;
    }
}

- (void)didSelectDocument:(NSURL *)url{
	[libraryPopover dismissPopoverAnimated:YES];
	[libraryPopover release]; libraryPopover = nil;
	
	CGPDFDocumentRelease(_document);
	_document = CGPDFDocumentCreateWithURL((CFURLRef)url);
    _index = -1;
     [self _renewPages];
}
-(void)openPage:(int)index{
    _index = index;
    [self _renewPages];
}

#pragma mark Search

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
	[keyword release];
	keyword = [[aSearchBar text] retain];
	[_pdfView1 setKeyword:keyword];
	
	[aSearchBar resignFirstResponder];
}

@end
