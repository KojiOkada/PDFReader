// PDFTextViewController.h

#import <UIKit/UIKit.h>

@interface PDFTextViewController : UIViewController
{
    IBOutlet UITextView*    _textView;
}

// Property
@property (nonatomic, readonly) UITextView* textView;

// Action
- (IBAction)doneAction;

@end

