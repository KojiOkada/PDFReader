//
//  pageScanner.m
//  PDFReader
//
//  Created by システム管理者 on 13/03/12.
//  Copyright (c) 2013年 Koji Okada. All rights reserved.
//

#import "pageScanner.h"
#import "ViewController.h"
@implementation pageScanner

-(void)main{
    [self scanText];
}
-(id)initWithPDFDocument:(CGPDFPageRef)page pageIndex:(int)pageIndex keyword:(NSString*)keyword{
    
    self = [super init];
    
    if(self){
    _keyword = [keyword retain];
    _pageIndex = pageIndex;
    _pdfPage = page;
    }
    return self;
}
-(void)scanText{
    
    DebugLog(@"start scan")
    
    // PDFコンテントストリームを取得
    _stream = CGPDFContentStreamCreateWithPage(_pdfPage);
    
    // PDFオペレータテーブルを作成
    CGPDFOperatorTableRef   table;
    table = CGPDFOperatorTableCreate();
    CGPDFOperatorTableSetCallback(table, "TJ", op_Text);
    CGPDFOperatorTableSetCallback(table, "Tj", op_Text);
    CGPDFOperatorTableSetCallback(table, "Tf", op_Font);
//    CGPDFOperatorTableSetCallback(table, "Td", op_Rect);
//    CGPDFOperatorTableSetCallback(table, "TD", op_Rect);
//    CGPDFOperatorTableSetCallback(table, "Tm", op_Rect);
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
    
    if(![_text isKindOfClass:[NSMutableString class]]){
        return;
    }
    BOOL bl = [_text hasPrefix:_keyword];

    DebugLog(@"%@ %@ %@",_keyword,_text,_encoding)
    if([_text length]> [_keyword length]){
        NSRange range = [_text rangeOfString:_keyword];
        if (range.location == NSNotFound) {
//            DebugLog(@"検索対象が存在しない場合の処理");
        }else{
            DebugLog(@"Detect!!%d",_pageIndex)
            NSDictionary *dic = @{@"page":[NSString stringWithFormat:@"%d",_pageIndex]};
            [_delegate detectKeyWord:dic];
        }
    }
    
    
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
    
//    if(string){
//        DebugLog(@"%@",string)
//    }
    // テキストの追加
    if (string) {
        [_text appendString:string];
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
//    DebugLog(@"%@",_encoding)
}

@end


void op_Text(CGPDFScannerRef scanner, void* info){
    [(pageScanner*)info operatorTextScanned:scanner];
}

void op_Font(CGPDFScannerRef scanner,void* info){
    [(pageScanner*)info operatorFontScanned:scanner];
}
