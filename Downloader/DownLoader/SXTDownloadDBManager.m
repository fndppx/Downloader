
//
//  SXTDownloadDBManager.m
//  shuxiaotong-mobile
//
//  Created by k12 on 2019/7/5.
//

#import "SXTDownloadDBManager.h"
#import "SXTDownloadConst.h"
#import "SXTCommonUtil.h"
#import <FMDB.h>
typedef NS_ENUM(NSInteger, SXTDBGetDateOption) {
    SXTDBGetDateOptionAllCacheData = 0,      // 所有缓存数据
    SXTDBGetDateOptionAllDownloadingData,    // 所有正在下载的数据
    SXTDBGetDateOptionAllDownloadedData,     // 所有下载完成的数据
    SXTDBGetDateOptionAllUnDownloadedData,   // 所有未下载完成的数据
    SXTDBGetDateOptionAllWaitingData,        // 所有等待下载的数据
    SXTDBGetDateOptionModelWithUrl,          // 通过url获取单条数据
    SXTDBGetDateOptionWaitingModel,          // 第一条等待的数据
    SXTDBGetDateOptionLastDownloadingModel,  // 最后一条正在下载的数据
};
@interface SXTDownloadDBManager ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation SXTDownloadDBManager

+ (instancetype)shareManager
{
    static SXTDownloadDBManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self creatVideoCachesTable];
    }
    
    return self;
}

// 创表
- (void)creatVideoCachesTable
{
    // 数据库文件路径
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"SXTDownloadFileCaches.sqlite"];
    
    // 创建队列对象，内部会自动创建一个数据库, 并且自动打开
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        // 创表
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_videoCaches (id integer PRIMARY KEY AUTOINCREMENT, vid text, fileName text, url text, resumeData blob, totalFileSize integer, tmpFileSize integer, state integer, progress float, lastSpeedTime double, intervalFileSize integer, lastStateTime integer)"];
        if (result) {
            IKBLog(@"视频缓存数据表创建成功");
        }else {
            IKBLog(@"视频缓存数据表创建失败");
        }
    }];
}

// 插入数据
- (void)insertModel:(SXTDownloadModel *)model
{
    [_dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"INSERT INTO t_videoCaches (vid, fileName, url, resumeData, totalFileSize, tmpFileSize, state, progress, lastSpeedTime, intervalFileSize, lastStateTime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", model.vid, model.fileName, model.url, model.resumeData, [NSNumber numberWithInteger:model.totalFileSize], [NSNumber numberWithInteger:model.tmpFileSize], [NSNumber numberWithInteger:model.state], [NSNumber numberWithFloat:model.progress], [NSNumber numberWithDouble:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0]];
        if (result) {
            IKBLog(@"插入成功：%@", model.fileName);
        }else {
            IKBLog(@"插入失败：%@", model.fileName);
        }
    }];
}

// 获取单条数据
- (SXTDownloadModel *)getModelWithUrl:(NSString *)url
{
    return [self getModelWithOption:SXTDBGetDateOptionModelWithUrl url:url];
}

// 获取第一条等待的数据
- (SXTDownloadModel *)getWaitingModel
{
    return [self getModelWithOption:SXTDBGetDateOptionWaitingModel url:nil];
}

// 获取最后一条正在下载的数据
- (SXTDownloadModel *)getLastDownloadingModel
{
    return [self getModelWithOption:SXTDBGetDateOptionLastDownloadingModel url:nil];
}

// 获取所有数据
- (NSArray<SXTDownloadModel *> *)getAllCacheData
{
    return [self getDateWithOption:SXTDBGetDateOptionAllCacheData];
}

// 根据lastStateTime倒叙获取所有正在下载的数据
- (NSArray<SXTDownloadModel *> *)getAllDownloadingData
{
    return [self getDateWithOption:SXTDBGetDateOptionAllDownloadingData];
}

// 获取所有下载完成的数据
- (NSArray<SXTDownloadModel *> *)getAllDownloadedData
{
    return [self getDateWithOption:SXTDBGetDateOptionAllDownloadedData];
}

// 获取所有未下载完成的数据
- (NSArray<SXTDownloadModel *> *)getAllUnDownloadedData
{
    return [self getDateWithOption:SXTDBGetDateOptionAllUnDownloadedData];
}

// 获取所有等待下载的数据
- (NSArray<SXTDownloadModel *> *)getAllWaitingData
{
    return [self getDateWithOption:SXTDBGetDateOptionAllWaitingData];
}

// 获取单条数据
- (SXTDownloadModel *)getModelWithOption:(SXTDBGetDateOption)option url:(NSString *)url
{
    __block SXTDownloadModel *model = nil;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet;
        switch (option) {
            case SXTDBGetDateOptionModelWithUrl:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches WHERE url = ?", url];
                break;
                
            case SXTDBGetDateOptionWaitingModel:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches WHERE state = ? order by lastStateTime asc limit 0,1", [NSNumber numberWithInteger:SXTDownloadStateWaiting]];
                break;
                
            case SXTDBGetDateOptionLastDownloadingModel:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches WHERE state = ? order by lastStateTime desc limit 0,1", [NSNumber numberWithInteger:SXTDownloadStateDownloading]];
                break;
                
            default:
                break;
        }
        
        while ([resultSet next]) {
            model = [[SXTDownloadModel alloc] initWithFMResultSet:resultSet];
        }
    }];
    
    return model;
}

// 获取数据集合
- (NSArray<SXTDownloadModel *> *)getDateWithOption:(SXTDBGetDateOption)option
{
    __block NSArray<SXTDownloadModel *> *array = nil;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet;
        switch (option) {
            case SXTDBGetDateOptionAllCacheData:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches"];
                break;
                
            case SXTDBGetDateOptionAllDownloadingData:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches WHERE state = ? order by lastStateTime desc", [NSNumber numberWithInteger:SXTDownloadStateDownloading]];
                break;
                
            case SXTDBGetDateOptionAllDownloadedData:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches WHERE state = ?", [NSNumber numberWithInteger:SXTDownloadStateFinish]];
                break;
                
            case SXTDBGetDateOptionAllUnDownloadedData:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches WHERE state != ?", [NSNumber numberWithInteger:SXTDownloadStateFinish]];
                break;
                
            case SXTDBGetDateOptionAllWaitingData:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches WHERE state = ?", [NSNumber numberWithInteger:SXTDownloadStateWaiting]];
                break;
                
            default:
                break;
        }
        
        NSMutableArray *tmpArr = [NSMutableArray array];
        while ([resultSet next]) {
            [tmpArr addObject:[[SXTDownloadModel alloc] initWithFMResultSet:resultSet]];
        }
        array = tmpArr;
    }];
    
    return array;
}

// 更新数据
- (void)updateWithModel:(SXTDownloadModel *)model option:(SXTDBUpdateOption)option
{
    [_dbQueue inDatabase:^(FMDatabase *db) {
        if (option & SXTDBUpdateOptionState) {
            [self postStateChangeNotificationWithFMDatabase:db model:model];
            [db executeUpdate:@"UPDATE t_videoCaches SET state = ? WHERE url = ?", [NSNumber numberWithInteger:model.state], model.url];
        }
        if (option & SXTDBUpdateOptionLastStateTime) {
            [db executeUpdate:@"UPDATE t_videoCaches SET lastStateTime = ? WHERE url = ?", [NSNumber numberWithInteger:[SXTCommonUtil getTimeStampWithDate:[NSDate date]]], model.url];
        }
        if (option & SXTDBUpdateOptionResumeData) {
            [db executeUpdate:@"UPDATE t_videoCaches SET resumeData = ? WHERE url = ?", model.resumeData, model.url];
        }
        if (option & SXTDBUpdateOptionProgressData) {
            [db executeUpdate:@"UPDATE t_videoCaches SET tmpFileSize = ?, totalFileSize = ?, progress = ?, lastSpeedTime = ?, intervalFileSize = ? WHERE url = ?", [NSNumber numberWithInteger:model.tmpFileSize], [NSNumber numberWithFloat:model.totalFileSize], [NSNumber numberWithFloat:model.progress], [NSNumber numberWithDouble:model.lastSpeedTime], [NSNumber numberWithInteger:model.intervalFileSize], model.url];
        }
        if (option & SXTDBUpdateOptionAllParam) {
            [self postStateChangeNotificationWithFMDatabase:db model:model];
            [db executeUpdate:@"UPDATE t_videoCaches SET resumeData = ?, totalFileSize = ?, tmpFileSize = ?, progress = ?, state = ?, lastSpeedTime = ?, intervalFileSize = ?, lastStateTime = ? WHERE url = ?", model.resumeData, [NSNumber numberWithInteger:model.totalFileSize], [NSNumber numberWithInteger:model.tmpFileSize], [NSNumber numberWithFloat:model.progress], [NSNumber numberWithInteger:model.state], [NSNumber numberWithDouble:model.lastSpeedTime], [NSNumber numberWithInteger:model.intervalFileSize], [NSNumber numberWithInteger:[SXTCommonUtil getTimeStampWithDate:[NSDate date]]], model.url];
        }
    }];
}

// 状态变更通知
- (void)postStateChangeNotificationWithFMDatabase:(FMDatabase *)db model:(SXTDownloadModel *)model
{
    // 原状态
    NSInteger oldState = [db intForQuery:@"SELECT state FROM t_videoCaches WHERE url = ?", model.url];
    if (oldState != model.state && oldState != SXTDownloadStateFinish) {
        // 状态变更通知
        [[NSNotificationCenter defaultCenter] postNotificationName:SXTDownloadStateChangeNotification object:model];
    }
}

// 删除数据
- (void)deleteModelWithUrl:(NSString *)url
{
    [_dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"DELETE FROM t_videoCaches WHERE url = ?", url];
        if (result) {
            IKBLog(@"删除成功：%@", url);
        }else {
            IKBLog(@"删除失败：%@", url);
        }
    }];
}

@end

