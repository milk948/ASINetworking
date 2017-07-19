//
//  ViewController.m
//  ASINetworking
//
//  Created by panyf on 2017/7/19.
//  Copyright © 2017年 panyuanfeng. All rights reserved.
//

#import "ViewController.h"
#import "ASIHttpUtil.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

#pragma mark 测试GET
    [ASIHttpUtil getRequestWithPath:@"http://apistore.baidu.com/microservice/cityinfo?cityname=北京" params:nil completed:^(id json, NSString *stringData) {

        NSLog(@"测试成功");

    } failed:^(NSError *error) {

        NSLog(@"测试失败");

    }];

#pragma mark 测试POST
    NSDictionary *postDict = @{ @"urls": @[@"http://www.henishuo.com/git-use-inwork/",
                                           @"http://www.henishuo.com/ios-open-source-hybloopscrollview/"]
                                };
    NSString *path = @"http://apistore.baidu.com/urls?site=www.henishuo.com&token=bRidefmXoNxIi3Jp";
    // 由于这里有两套基础路径，用时就需要更新
    [ASIHttpUtil updateBaseUrl:@"http://data.zz.baidu.com"];
    [ASIHttpUtil postRequestWithPath:path params:postDict completed:^(id json, NSString *stringData) {

        NSLog(@"测试成功");

    } failed:^(NSError *error) {

        NSLog(@"测试失败");
        
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
