//
//  ASIHttpUtil.m
//  ASI封装
//
//  Created by panyf on 2017/7/19.
//  Copyright © 2017年 panyuanfeng. All rights reserved.
//

#import "ASIHttpUtil.h"
#import "ASIFormDataRequest.h"

NSString * kAPI_BASE_URL = @"http://apistore.baidu.com";
static BOOL sg_shouldAutoEncode = YES;
static NSDictionary *sg_httpHeaders = nil;

@implementation ASIHttpUtil

+ (ASIHttpUtil *)shareInstance{

    static ASIHttpUtil *httpUtil = nil;

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        httpUtil = [[ASIHttpUtil alloc] init];
    });

    return httpUtil;
}

+ (void)updateBaseUrl:(NSString *)baseUrl {
    kAPI_BASE_URL = baseUrl;
}

#pragma mark GET请求
+ (ASIHTTPRequest *)getRequestWithPath:(NSString *)path params:(NSDictionary *)paramsDic completed:(CompleteBlock)completeBlock failed:(FailedBlock)failed{

    NSString *urlString = [NSString stringWithFormat:@"%@",path];

    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURL *url = [NSURL URLWithString:urlString];

    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];

    request.requestMethod = @"GET";

    for (NSString *key in sg_httpHeaders.allKeys) {
        if (sg_httpHeaders[key] != nil) {
            [request addRequestHeader:key value:sg_httpHeaders[key]];
        }
    }

    [request setCompletionBlock:^{

        NSError *errorForJSON = [NSError errorWithDomain:@"请求数据解析为json格式，发出错误" code:2014 userInfo:@{@"请求数据json解析错误": @"中文",@"serial the data to json error":@"English"}];

        id jsonData = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&errorForJSON];

        completeBlock(jsonData,request.responseString);

    }];

    [request setFailedBlock:^{

        failed([request error]);

    }];

    [request startAsynchronous];

    return request;
}

#pragma mark POST请求
+ (ASIHTTPRequest *)postRequestWithPath:(NSString *)path params:(NSDictionary *)paramsDic completed:(CompleteBlock)completeBlock failed:(FailedBlock)failed{

    NSString *urlString = [NSString stringWithFormat:@"%@",path];

    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURL *url = [NSURL URLWithString:urlString];

    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];

    request.requestMethod = @"POST";

    for (NSString *key in sg_httpHeaders.allKeys) {
        if (sg_httpHeaders[key] != nil) {
            [request addRequestHeader:key value:sg_httpHeaders[key]];
        }
    }

    [paramsDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

         [request setPostValue:obj forKey:key];

    }];

    [request setCompletionBlock:^{
        NSError *errorForJSON = [NSError errorWithDomain:@"请求数据解析为json格式，发出错误" code:2014 userInfo:@{@"请求数据json解析错误": @"中文",@"serial the data to json error":@"English"}];

        id jsonData = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&errorForJSON];

        completeBlock(jsonData, request.responseString);
    }];

    [request setFailedBlock:^{
        failed([request error]);
    }];

    [request startAsynchronous];

    return request;
}

#pragma mark 文件上传
+ (ASIHTTPRequest *)uploadFileWithPath:(NSString *)path file:(NSString *)filePath forKey:(NSString *)fileKey params:(NSDictionary *)params setProgress:(ProgressBlock)progressBlock completed:(CompleteBlock)completedBlock failed:(FailedBlock)failed{

    NSURL *url = [NSURL URLWithString:path];

    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];

    for (NSString *key in sg_httpHeaders.allKeys) {
        if (sg_httpHeaders[key] != nil) {
            [request addRequestHeader:key value:sg_httpHeaders[key]];
        }
    }

    [request setFile:filePath forKey:fileKey];

    if (params.count > 0) {

        [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request setPostValue:obj forKey:key];

        }];
    }

    __block float upProgress = 0;

    [request setBytesSentBlock:^(unsigned long long size, unsigned long long total) {
        upProgress += (float)size/total;
        progressBlock(upProgress);
    }];

    [request setCompletionBlock:^{
        upProgress=0;
        NSError *errorForJSON = [NSError errorWithDomain:@"请求数据解析为json格式，发出错误" code:2014 userInfo:@{@"请求数据json解析错误": @"中文",@"serial the data to json error":@"English"}];
        id jsonData = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&errorForJSON];
        completedBlock(jsonData,[request responseString]);
    }];

    [request setFailedBlock:^{
        failed([request error]);
    }];

    [request startAsynchronous];

    NSLog(@"ASIClient 文件上传：%@ file=%@ key=%@",path,filePath,fileKey);

    NSLog(@"ASIClient 文件上传参数：%@",params);

    return request;
}

#pragma mark 文件下载
+ (ASIHTTPRequest *)downFileWithPath:(NSString *)path writeTo:(NSString *)destination fileName:(NSString *)name setProgress:(ProgressBlock)progressBlock completed:(ASIBasicBlock)completedBlock failed:(FailedBlock)failed{

    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:path]];
    for (NSString *key in sg_httpHeaders.allKeys) {
        if (sg_httpHeaders[key] != nil) {
            [request addRequestHeader:key value:sg_httpHeaders[key]];
        }
    }
    NSString *filePath = nil;
    if ([destination hasSuffix:@"/"]) {
        filePath = [NSString stringWithFormat:@"%@%@",destination,name];
    }
    else
    {
        filePath = [NSString stringWithFormat:@"%@/%@",destination,name];
    }
    [request setDownloadDestinationPath:filePath];

    __block float downProgress = 0;
    [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
        downProgress += (float)size/total;
        progressBlock(downProgress);
    }];

    [request setCompletionBlock:^{
        downProgress = 0;
        completedBlock();
    }];

    [request setFailedBlock:^{
        failed([request error]);
    }];

    [request startAsynchronous];

    NSLog(@"ASIClient 下载文件：%@ ",path);
    NSLog(@"ASIClient 保存路径：%@",filePath);

    return request;

}

#pragma mark 数据上传
+ (ASIHTTPRequest *)uploadFileWithPath:(NSString *)path fileData:(NSData *)fData forKey:(NSString *)dataKey params:(NSDictionary *)params SetProgress:(ProgressBlock)progressBlock completed:(CompleteBlock)completedBlock failed:(FailedBlock)failed{

    NSURL *url = [NSURL URLWithString:path];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setData:fData forKey:dataKey];
    for (NSString *key in sg_httpHeaders.allKeys) {
        if (sg_httpHeaders[key] != nil) {
            [request addRequestHeader:key value:sg_httpHeaders[key]];
        }
    }
    if (params.count > 0) {
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request setPostValue:obj forKey:key];
        }];
    }

    __block float upProgress = 0;
    [request setBytesSentBlock:^(unsigned long long size, unsigned long long total) {
        upProgress += (float)size/total;
        progressBlock(upProgress);
    }];

    [request setCompletionBlock:^{
        upProgress=0;
        NSError *errorForJSON = [NSError errorWithDomain:@"请求数据解析为json格式，发出错误" code:2014 userInfo:@{@"请求数据json解析错误": @"中文",@"serial the data to json error":@"English"}];
        id jsonData = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&errorForJSON];
        completedBlock(jsonData,[request responseString]);
    }];

    [request setFailedBlock:^{
        failed([request error]);
    }];

    [request startAsynchronous];

    NSLog(@"ASIClient 文件上传：%@ size=%.2f MB  key=%@",path,fData.length/1024.0/1024.0,dataKey);
    NSLog(@"ASIClient 文件上传参数：%@",params);

    return request;
}

+ (ASIHTTPRequest *)resumeDownWithPath:(NSString *)path writeTo:(NSString *)destinationPath tempPath:(NSString *)tempPath fileName:(NSString *)name setProgress:(ProgressBlock)progressBlock completed:(ASIBasicBlock)completedBlock failed:(FailedBlock)failed{

    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:path]];
    for (NSString *key in sg_httpHeaders.allKeys) {
        if (sg_httpHeaders[key] != nil) {
            [request addRequestHeader:key value:sg_httpHeaders[key]];
        }
    }
    NSString *filePath = nil;
    if ([destinationPath hasSuffix:@"/"]) {
        filePath = [NSString stringWithFormat:@"%@%@",destinationPath,name];
    }
    else
    {
        filePath = [NSString stringWithFormat:@"%@/%@",destinationPath,name];
    }

    [request setDownloadDestinationPath:filePath];

    NSString *tempForDownPath = nil;
    if ([tempPath hasSuffix:@"/"]) {
        tempForDownPath = [NSString stringWithFormat:@"%@%@.download",tempPath,name];
    }
    else
    {
        tempForDownPath = [NSString stringWithFormat:@"%@/%@.download",tempPath,name];
    }

    [request setTemporaryFileDownloadPath:tempForDownPath];
    [request setAllowResumeForFileDownloads:YES];

    __block float downProgress = 0;
    downProgress = [[NSUserDefaults standardUserDefaults] floatForKey:@"ASIClient_ResumeDOWN_PROGRESS"];
    [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
        downProgress += (float)size/total;
        if (downProgress >1.0) {
            downProgress=1.0;
        }
        [[NSUserDefaults standardUserDefaults] setFloat:downProgress forKey:@"ASIClient_ResumeDOWN_PROGRESS"];
        progressBlock(downProgress);
    }];

    [request setCompletionBlock:^{
        downProgress = 0;
        [[NSUserDefaults standardUserDefaults] setFloat:downProgress forKey:@"ASIClient_ResumeDOWN_PROGRESS"];
        completedBlock();
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempForDownPath]) {
            //NSError *errorForDelete = [NSError errorWithDomain:@"删除临时文件发生错误！" code:2015 userInfo:@{@"删除临时文件发生错误": @"中文",@"delete the temp fife error":@"English"}];
            //[[NSFileManager defaultManager] removeItemAtPath:tempForDownPath error:&errorForDelete];
            NSLog(@"l  %d> %s",__LINE__,__func__);
        }
    }];

    [request setFailedBlock:^{
        failed([request error]);
    }];

    [request startAsynchronous];

    NSLog(@"ASIClient 下载文件：%@ ",path);
    NSLog(@"ASIClient 保存路径：%@",filePath);
    if (downProgress >0 && downProgress) {
        if (downProgress >=1.0) downProgress = 0.9999;
        NSLog(@"ASIClient 上次下载已完成：%.2f/100",downProgress*100);
    }
    return request;

}


@end
