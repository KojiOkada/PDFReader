// PDFView.h

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PDFPage : UIView
{
    CGPDFPageRef    _page;
    float           _scale;
}

// プロパティ
@property (nonatomic) CGPDFPageRef page;
@property (nonatomic) float scale;

@end

