//
//  SXTDownloadDBManager.h
//  shuxiaotong-mobile
//
//  Created by k12 on 2019/7/5.
//

#import <Foundation/Foundation.h>
#import "SXTDownload.h"

typedef NS_OPTIONS(NSUInteger, SXTDBUpdateOption) {
    SXTDBUpdateOptionState         = 1 << 0,  // 更新状态
    SXTDBUpdateOptionLastStateTime = 1 << 1,  // 更新状态最后改变的时间
    SXTDBUpdateOptionResumeData    = 1 << 2,  // 更新下载的数据
    SXTDBUpdateOptionProgressData  = 1 << 3,  // 更新进度数据（包含tmpFileSize、totalFileSize、progress、intervalFileSize、lastSpeedTime）
    SXTDBUpdateOptionAllParam      = 1 << 4   // 更新全部数据
};
@interface SXTDownloadDBManager : NSObject

// 获取单例
+ (instancetype)shareManager;

// 插入数据
- (void)insertModel:(SXTDownloadModel *)model;

// 获取数据
- (SXTDownloadModel *)getModelWithUrl:(NSString *)url;    // 根据url获取数据
- (SXTDownloadModel *)getWaitingModel;                    // 获取第一条等待的数据
- (SXTDownloadModel *)getLastDownloadingModel;            // 获取最后一条正在下载的数据
- (NSArray<SXTDownloadModel *> *)getAllCacheData;         // 获取所有数据
- (NSArray<SXTDownloadModel *> *)getAllDownloadingData;   // 根据lastStateTime倒叙获取所有正在下载的数据
- (NSArray<SXTDownloadModel *> *)getAllDownloadedData;    // 获取所有下载完成的数据
- (NSArray<SXTDownloadModel *> *)getAllUnDownloadedData;  // 获取所有未下载完成的数据（包含正在下载、等待、暂停、错误）
- (NSArray<SXTDownloadModel *> *)getAllWaitingData;       // 获取所有等待下载的数据

// 更新数据
- (void)updateWithModel:(SXTDownloadModel *)model option:(SXTDBUpdateOption)option;

// 删除数据
- (void)deleteModelWithUrl:(NSString *)url;

@end
