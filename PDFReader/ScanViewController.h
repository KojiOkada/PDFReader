//
//  ScanViewController.h
//  PDFReader
//
//  Created by システム管理者 on 13/03/11.
//  Copyright (c) 2013年 Koji Okada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "pageScanner.h"
@protocol ScanViewDelegate<NSObject>
-(void)openPage:(int)index;
@end
@interface ScanViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,pageScannerDelegate>{
    
    CGPDFPageRef pdfPage;
    NSOperationQueue* queue;
}
@property (nonatomic,strong) id<ScanViewDelegate> delegate;
@property (nonatomic,weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableString *keyword;
@property (nonatomic,assign) int pageIndex;
@property (nonatomic,assign) int numberOfPage;
@property (nonatomic,retain) NSString *content;
@property (nonatomic,assign) CGPDFDocumentRef pdfDocument;

@end
