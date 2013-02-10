// PDFScrollView.h

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class ViewController;

@interface PDFScrollView : UIScrollView
{
    ViewController*  _controller; // Assign
}

// プロパティ
@property (nonatomic, strong) ViewController* controller;

@end

