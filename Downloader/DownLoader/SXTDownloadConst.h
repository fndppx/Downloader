//
//  SXTDownloadConst.h
//  shuxiaotong-mobile
//
//  Created by k12 on 2019/7/5.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/************************* 下载 *************************/
UIKIT_EXTERN NSString * const SXTDownloadProgressNotification;                   // 进度回调通知
UIKIT_EXTERN NSString * const SXTDownloadStateChangeNotification;                // 状态改变通知
UIKIT_EXTERN NSString * const SXTDownloadMaxConcurrentCountKey;                  // 最大同时下载数量key
UIKIT_EXTERN NSString * const SXTDownloadMaxConcurrentCountChangeNotification;   // 最大同时下载数量改变通知
UIKIT_EXTERN NSString * const SXTDownloadAllowsCellularAccessKey;                // 是否允许蜂窝网络下载key
UIKIT_EXTERN NSString * const SXTDownloadAllowsCellularAccessChangeNotification; // 是否允许蜂窝网络下载改变通知

/************************* 网络 *************************/
UIKIT_EXTERN NSString * const SXTNetworkingReachabilityDidChangeNotification;    // 网络改变改变通知
