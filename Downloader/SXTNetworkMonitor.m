//
//  IKBNetworkMonitor.m
//  ikebang
//
//  Created by imooc on 04/07/2018.
//  Copyright © 2018 kim. All rights reserved.
//

#import "SXTNetworkMonitor.h"
#import <AFNetworkReachabilityManager.h>

NSString * const IKBNetworStatusDidChangeNotification = @"IKBNetworStatusDidChangeNotification";

@interface SXTNetworkMonitor ()
@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;
@end

@implementation SXTNetworkMonitor

+ (instancetype)sharedMonitor
{
    static SXTNetworkMonitor *monitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[SXTNetworkMonitor alloc] init];
    });
    return monitor;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.reachabilityManager = [AFNetworkReachabilityManager managerForDomain:@"www.baidu.com"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:AFNetworkingReachabilityDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)startMonitor
{
    [self.reachabilityManager startMonitoring];
}

- (void)stopMonitor
{
    [self.reachabilityManager stopMonitoring];
}


#pragma mark - Notification
- (void)reachabilityChanged:(NSNotification *)noti
{
    NSDictionary *statusDictionary = noti.userInfo;
    AFNetworkReachabilityStatus status = [[statusDictionary objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue];
    
    IKBNetworkStatus ikbstatus;
    
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:     ikbstatus = IKBNetworkStatusNone; break;
        case AFNetworkReachabilityStatusReachableViaWWAN: ikbstatus = IKBNetworkStatusWWAN; break;
        case AFNetworkReachabilityStatusReachableViaWiFi: ikbstatus = IKBNetworkStatusWiFi; break;
        case AFNetworkReachabilityStatusUnknown:          ikbstatus = IKBNetworkStatusUnknown; break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:IKBNetworStatusDidChangeNotification object:[NSNumber numberWithInt:ikbstatus]];
}


- (IKBNetworkStatus)currentNetworkStatus
{
    IKBNetworkStatus ikbstatus;
    switch (self.reachabilityManager.networkReachabilityStatus) {
        case AFNetworkReachabilityStatusNotReachable:     ikbstatus = IKBNetworkStatusNone; break;
        case AFNetworkReachabilityStatusReachableViaWWAN: ikbstatus = IKBNetworkStatusWWAN; break;
        case AFNetworkReachabilityStatusReachableViaWiFi: ikbstatus = IKBNetworkStatusWiFi; break;
        case AFNetworkReachabilityStatusUnknown:          ikbstatus = IKBNetworkStatusUnknown; break;
    }
    return ikbstatus;
}

@end
