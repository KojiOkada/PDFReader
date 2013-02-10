//
//  OutlineViewController.h
//  PDFKitten
//
//  Created by Koji Okada on 2013/02/10.
//  Copyright (c) 2013年 Chalmers Göteborg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OutlineViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>{

@private
    CGPDFDocumentRef document_;
    NSMutableArray* tableOfContents_;
    id delegate;
}
@property (nonatomic,retain)NSMutableArray *dataSource;
@property (nonatomic, retain, readonly ) NSArray* tableOfContents;
@property (nonatomic, assign) id delegate;
-(id) initWithCGPDFDocument:(CGPDFDocumentRef) document;
-(NSArray*) buildStructure;
@end
