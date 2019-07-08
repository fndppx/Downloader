//
//  AppDelegate.h
//  Downloader
//
//  Created by k12 on 2019/7/8.
//  Copyright © 2019 k12. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, copy) void (^ backgroundSessionCompletionHandler)(void);  // 后台所有下载任务完成回调


@end

