// PDFView.h

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Scanner.h"
@interface PDFPage : UIView
{
    CGPDFPageRef    _page;
    float           _scale;
}

// プロパティ
@property (nonatomic) CGPDFPageRef page;
@property (nonatomic) float scale;
@property (nonatomic, retain) Scanner *scanner;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSArray *selections;

@end

