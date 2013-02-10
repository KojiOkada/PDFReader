// PDFScrollView.m

#import "ViewController.h"
#import "PDFScrollView.h"

@implementation PDFScrollView

- (void)layoutSubviews {
    [_controller frameToCenter];
}

@end

