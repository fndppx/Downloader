//
//  NSURLSession+CorrectedResumeData.h
//  shuxiaotong-mobile
//
//  Created by k12 on 2019/7/5.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (CorrectedResumeData)
- (NSURLSessionDownloadTask *)downloadTaskWithCorrectResumeData:(NSData *)resumeData;

@end
