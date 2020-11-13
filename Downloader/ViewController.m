//
//  ViewController.m
//  Downloader
//
//  Created by k12 on 2019/7/8.
//  Copyright © 2019 k12. All rights reserved.
//

#import "ViewController.h"
#import "SXTDownload.h"
#import "SXTDownloadConst.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *downLoadURL = @"http://www.ikebang.com/book/down?timestamp=1605233802&url=5c1075b483ba88a9535e171e&token=76a32c75e668826dab72287e01c812de";
    
    SXTDownloadModel *model = [SXTDownloadModel new];
    model.url = downLoadURL;
    model.vid = @"1";
    model.localPath = NSHomeDirectory();
    model.fileName = @"测试";
    [[SXTDownloadManager shareManager]startDownloadTask:model];
    
//    NSString * const SXTDownloadProgressNotification = @"SXTDownloadProgressNotification";
//    NSString * const SXTDownloadStateChangeNotification = @"SXTDownloadStateChangeNotification";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downloadProgressNotification:) name:SXTDownloadProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downloadStateChangeNotification:) name:SXTDownloadStateChangeNotification object:nil];
}

- (void)downloadStateChangeNotification:(NSNotification*)notify{
    
}

- (void)downloadProgressNotification:(NSNotification*)notify{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
