//
//  MKLog.h
//  ikebang
//
//  Created by k12 on 2018/6/11.
//  Copyright © 2018年 kim. All rights reserved.
//

#ifndef IKBLog_h
#define IKBLog_h

#ifdef DEBUG
#   define IKBLog(...) NSLog(__VA_ARGS__)
#   define IKBLogMethod() IKBLog(@"[%@(%p) %@] invoked", NSStringFromClass([self class]), self, NSStringFromSelector(_cmd))
#else
#   define IKBLog(...) (void)0
#   define IKBLogMethod()    (void)0
#endif  // #ifdef DEBUG

#endif /* MKLog_h */
