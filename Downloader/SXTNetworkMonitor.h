//
//  IKBNetworkMonitor.h
//  ikebang
//
//  Created by imooc on 04/07/2018.
//  Copyright © 2018 kim. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const IKBNetworStatusDidChangeNotification;

typedef NS_ENUM(NSInteger, IKBNetworkStatus) {
    IKBNetworkStatusUnknown = -1,
    IKBNetworkStatusNone    = 0,
    IKBNetworkStatusWiFi    = 1,
    IKBNetworkStatusWWAN    = 2
};

@interface SXTNetworkMonitor : NSObject


+ (instancetype)sharedMonitor;
- (void)startMonitor;
- (void)stopMonitor;
- (IKBNetworkStatus)currentNetworkStatus;


@end
