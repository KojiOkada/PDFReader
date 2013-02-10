// PDFViewController.h

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@class PDFPage;
@class PDFScrollView;

@interface ViewController : UIViewController{
    CGPDFDocumentRef        _document;
    int                     _index;
    NSMutableString*        _text;
    CGPDFContentStreamRef   _stream;
    NSString*               _encoding;
    UIPopoverController *libraryPopover;
    
    
    PDFPage*                _pdfView0;
    PDFPage*                _pdfView1;
    PDFPage*                _pdfView2;
    
    IBOutlet UIScrollView*  _mainScrollView;
    
    IBOutlet UIView*        _innerView;
    IBOutlet PDFScrollView* _subScrollView;
}
@property (nonatomic,retain)NSMutableArray *array;
@property (nonatomic, retain) UINavigationController *navigationController;
// Image
- (void)frameToCenter;

// Action
- (IBAction)textAction;
- (void)_renewPages;// 表示の更新
// オペレータコールバック
- (void)operatorTextScanned:(CGPDFScannerRef)scanner;
- (void)operatorFontScanned:(CGPDFScannerRef)scanner;
@end

void operator_Text(
                   CGPDFScannerRef scanner,
                   void* info);
void operator_Font(
                   CGPDFScannerRef scanner,
                   void* info);
void operator_Rect(
                   CGPDFScannerRef scanner,
                   void* info);