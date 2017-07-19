//
//  ASIHttpUtil.h
//  ASI封装
//
//  Created by panyf on 2017/7/19.
//  Copyright © 2017年 panyuanfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"

/*
 * 请求完成回调
 */
typedef void (^CompleteBlock)(id json, NSString *stringData);

typedef void (^FailedBlock)(NSError *error);

typedef void (^ProgressBlock)(float progress);

@interface ASIHttpUtil : NSObject

/*!
 *
 *  用于指定网络请求接口的基础url，如：
 *  http://henishuo.com或者http://101.200.209.244
 *  通常在AppDelegate中启动时就设置一次就可以了。如果接口有来源
 *  于多个服务器，可以调用更新
 *
 *  @param baseUrl 网络接口的基础url
 */
+ (void)updateBaseUrl:(NSString *)baseUrl;

+ (ASIHttpUtil *)shareInstance;

/**
 *  GET请求，有参数
 *
 *  @param path 接口路径，不能为空
 *  @param paramsDic 请求的参数的字典，参数可为nil, 例如：NSDictionary *params = @{@"key":@"value"}
 *  @param completeBlock 请求完成块，返回 id JSON, NSString *stringData;
 *  @param failed 请求失败块，返回 NSError *error;
 */
+ (ASIHTTPRequest *)getRequestWithPath:(NSString *)path params:(NSDictionary *)paramsDic completed:(CompleteBlock)completeBlock failed:(FailedBlock)failed;

/**
 *  POST请求，有参数；
 *
 *  @param path 接口路径，不能为空；
 *  @param paramsDic 请求的参数的字典，参数可为nil, 例如：NSDictionary *params = @{@"key":@"value"}
 *  @param completeBlock 请求完成块，返回 id JSON, NSString *stringData;
 *  @param failed 请求失败块，返回 NSError *error;
 *
 *  @return 返回ASIHTTPRequest的指针，可用于 NSOperationQueue操作
 */
+ (ASIHTTPRequest *)postRequestWithPath:(NSString *)path params:(NSDictionary *)paramsDic completed:(CompleteBlock)completeBlock failed:(FailedBlock)failed;

/**
 *  POST上传文件；
 *
 *  @param path 上传接口路径，不能为空；
 *  @param filePath 要上传的文件路径，不能为空;
 *  @param fileKey 上传文件对应服务器接收的key，不能为空;
 *  @param params 请求的参数的字典，参数可为nil, 例如：NSDictionary *params = @{@"key":@"value"}
 *  @param progressBlock  上传文件的Progress块，返回 float progress,在此跟踪下载进度；
 *  @param completedBlock  请求完成块，返回 id JSON, NSString *stringData;
 *  @param failed 请求失败块，返回 NSError *error;
 *
 *  @return 返回ASIHTTPRequest的指针，可用于 NSOperationQueue操作
 */
+ (ASIHTTPRequest *)uploadFileWithPath:(NSString *)path file:(NSString *)filePath forKey:(NSString *)fileKey params:(NSDictionary *)params setProgress:(ProgressBlock)progressBlock completed:(CompleteBlock)completedBlock failed:(FailedBlock)failed;

/**
 *  GET请求下载文件；
 *
 *  @param path           接口路径，不能为空；
 *  @param destination    下载文件保存的路径，不能为空；
 *  @param name           下载文件保存的名字，不能为空；
 *  @param progressBlock  下载文件的Progress块，返回 float progress,在此跟踪下载进度；
 *  @param completedBlock  请求完成块，无返回值；
 *  @param failed         请求失败块，返回 NSError *error;
 *
 *  @return 返回ASIHTTPRequest的指针，可用于 NSOperationQueue操作
 */
+ (ASIHTTPRequest *)downFileWithPath:(NSString *)path writeTo:(NSString *)destination fileName:(NSString *)name setProgress:(ProgressBlock)progressBlock completed:(ASIBasicBlock)completedBlock failed:(FailedBlock)failed;

/**
 *  POST数据Data上传；
 *
 *  @param path 上传接口路径，不能为空；
 *  @param fData 要上传的文件Data，不能为空;
 *  @param dataKey 上传的Data对应服务器接收的key，不能为空;
 *  @param params 请求的参数的字典，参数可为nil, 例如：NSDictionary *params = @{@"key":@"value"}
 *  @param progressBlock 上传文件的Progress块，返回 float progress,在此跟踪下载进度；
 *  @param completedBlock 请求完成块，返回 id JSON, NSString *stringData;
 *  @param failed 请求失败块，返回 NSError *error;
 *
 *  @return 返回ASIHTTPRequest的指针，可用于 NSOperationQueue操作
 */
+ (ASIHTTPRequest *)uploadFileWithPath:(NSString *)path fileData:(NSData *)fData forKey:(NSString *)dataKey params:(NSDictionary *)params SetProgress:(ProgressBlock)progressBlock completed:(CompleteBlock)completedBlock failed:(FailedBlock)failed;

/**
 *  文件下载，支持断点续传功能；
 *
 *  @param path 接口路径，不能为空；
 *  @param destinationPath 下载文件要保存的路径，不能为空；
 *  @param tempPath 临时文件保存的路径，不能为空；
 *  @param name 下载保存的文件名，不能为空；
 *  @param progressBlock 下载文件的Progress块，返回 float progress,在此跟踪下载进度；
 *  @param completedBlock 下载完成回调块，无回返值；
 *  @param failed 下载失败回调块，返回 NSError *error;
 *
 *  @return 返回ASIHTTPRequest的指针，可用于 NSOperationQueue操作
 */
+ (ASIHTTPRequest *)resumeDownWithPath:(NSString *)path writeTo:(NSString *)destinationPath tempPath:(NSString *)tempPath fileName:(NSString *)name setProgress:(ProgressBlock )progressBlock completed:(ASIBasicBlock )completedBlock failed:(FailedBlock )failed;

@end
