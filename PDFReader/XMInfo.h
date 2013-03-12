//
//  XMInfo.h
//  PDFReader
//
//  Created by システム管理者 on 13/03/11.
//  Copyright (c) 2013年 Koji Okada. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMInfo : NSObject
@property (nonatomic,assign) int infoId;
@property (nonatomic,retain) NSString *keyWord;
@property (nonatomic,assign) int pageIndex;
@end
