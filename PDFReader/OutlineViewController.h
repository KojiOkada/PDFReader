//
//  OutlineViewController.h
//  PDFKitten
//
//  Created by Koji Okada on 2013/02/10.
//  Copyright (c) 2013年 Chalmers Göteborg. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol OutlineViewDelegate <NSObject>
-(void)openPage:(int)index;
@end

@interface OutlineViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>{

@private
    CGPDFDocumentRef document_;
    NSMutableArray* tableOfContents_;
}
@property (nonatomic,retain)NSMutableArray *dataSource;
@property (nonatomic, retain, readonly ) NSArray* tableOfContents;
@property (nonatomic, strong) id <OutlineViewDelegate> delegate;
-(id) initWithCGPDFDocument:(CGPDFDocumentRef) document;
-(NSArray*) buildStructure;
@end
