//
//  AppDelegate.h
//  PDFReader
//
//  Created by Koji Okada on 2013/02/10.
//  Copyright (c) 2013年 Koji Okada. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic,retain) NSMutableArray * searchResult;

@end
