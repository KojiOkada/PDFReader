// PDFTextViewController.m

#import "PDFTextViewController.h"

@implementation PDFTextViewController

- (IBAction)doneAction{
    // ビューを隠す
    [[UIApplication sharedApplication] 
            setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self dismissModalViewControllerAnimated:YES];
}

@end
