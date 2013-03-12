// PDFView.m

#import "PDFPage.h"

@implementation PDFPage

// プロパティ
@synthesize page = _page;
@synthesize scale = _scale;

//--------------------------------------------------------------//
#pragma mark -- Initialize --
//--------------------------------------------------------------//

+ (Class)layerClass
{
    return [CATiledLayer class];
}

- (void)_init
{
    // インスタンス変数の初期化
    _scale = 1.0f;
    self.contentScaleFactor = 1.0f;
    
    // レイヤーの設定
    CATiledLayer*   layer;
    layer = (CATiledLayer*)self.layer;
    layer.levelsOfDetail = 4;
    layer.levelsOfDetailBias = 4;
    layer.tileSize = CGSizeMake(1024.0f, 1024.0f);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    // 共通の初期化処理
    [self _init];
    
    return self;
}

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    // 共通の初期化処理
    [self _init];
    
    return self;
}

//--------------------------------------------------------------//
#pragma mark -- Property --
//--------------------------------------------------------------//

- (void)setPage:(CGPDFPageRef)page
{
    // ページの設定
    _page = page;
    
    // 画面の更新
    [self setNeedsDisplay];
	self.scanner = [Scanner scannerWithPage:_page];
}

//--------------------------------------------------------------//
#pragma mark -- Drawing --
//--------------------------------------------------------------//

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
    // 背景を白で塗りつぶす
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, self.bounds);
	
    // グラフィックコンテキストの保存
	CGContextSaveGState(context);
    
    // 垂直方向に反転するアフィン変換の設定
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextTranslateCTM(context, 0, -CGRectGetHeight(self.bounds));
	
    // スケールの設定
	CGContextScaleCTM(context, _scale,_scale);	
    
    // ページの描画
	CGContextDrawPDFPage(context, _page);
    
    // グラフィックコンテキストの復元
	CGContextRestoreGState(context);
}


@end

