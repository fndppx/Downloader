//
//  SXTDownloadManager.h
//  shuxiaotong-mobile
//
//  Created by k12 on 2019/7/5.
//

#import <Foundation/Foundation.h>
@class SXTDownloadModel;

typedef NS_ENUM(NSInteger, SXTDownloadState) {
    SXTDownloadStateDefault = 0,  // 默认
    SXTDownloadStateDownloading,  // 正在下载
    SXTDownloadStateWaiting,      // 等待
    SXTDownloadStatePaused,       // 暂停
    SXTDownloadStateFinish,       // 完成
    SXTDownloadStateError,        // 错误
};
@interface SXTDownloadManager : NSObject
// 初始化下载单例，若之前程序杀死时有正在下的任务，会自动恢复下载
+ (instancetype)shareManager;

// 开始下载
- (void)startDownloadTask:(SXTDownloadModel *)model;

// 暂停下载
- (void)pauseDownloadTask:(SXTDownloadModel *)model;

// 删除下载任务及本地缓存
- (void)deleteTaskAndCache:(SXTDownloadModel *)model;
@end
