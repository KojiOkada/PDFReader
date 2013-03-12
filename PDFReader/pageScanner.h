//
//  pageScanner.h
//  PDFReader
//
//  Created by システム管理者 on 13/03/12.
//  Copyright (c) 2013年 Koji Okada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@protocol pageScannerDelegate<NSObject>

-(void)detectKeyWord:(NSDictionary*)dic;

@end

@interface pageScanner : NSOperation{
    CGPDFContentStreamRef   _stream;
    NSString*               _encoding;
}
@property (nonatomic,strong) id<pageScannerDelegate> delegate;
@property (nonatomic,strong) NSString *keyword;
@property (nonatomic,assign) int pageIndex;
@property (nonatomic,assign) int numberOfPage;
@property (nonatomic,retain) NSMutableString *text;
@property (nonatomic,assign) CGPDFPageRef pdfPage;

-(id)initWithPDFDocument:(CGPDFPageRef)page pageIndex:(int)pageIndex keyword:(NSString*)keyword;
@end


void op_Text(
                   CGPDFScannerRef scanner,
                   void* info);
void op_Font(
                   CGPDFScannerRef scanner,
                   void* info);
void op_Rect(
                   CGPDFScannerRef scanner,
                   void* info);