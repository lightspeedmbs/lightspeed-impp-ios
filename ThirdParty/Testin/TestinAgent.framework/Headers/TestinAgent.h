//
//  TestinAgent.h
//  TestinAgent
//
//  Created by maximli on 15/5/20.
//  Copyright (c) 2015年 testin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TestinConfig.h"
#import "TestinLog.h"

@interface TestinAgent : NSObject

/**
 *  Testin mAPM SDK 初始化接口函数
 *  已不推荐使用
 *  @param appId 在平台添加应用时获取的AppKey
 */
+ (void)init:(nonnull NSString*)appId DEPRECATED_MSG_ATTRIBUTE("use init:channel:config");
/**
 *  Testin mAPM SDK 初始化接口函数
 *  已不推荐使用
 *  @param appId   在平台添加应用时获取的AppKey
 *  @param channel 应用渠道号
 */
+ (void)init:(nonnull NSString*)appId channel:(nullable NSString*)channel DEPRECATED_MSG_ATTRIBUTE("use init:channel:config");
/**
 *  Testin mAPM SDK 初始化接口函数
 *
 *  @param appId   在平台添加应用时获取的AppKey
 *  @param channel 应用渠道号
 *  @param config  SDK的设置选项，默认值为[TestinConfig defaultConfig], 默认值可以通过构建TestinConfig对象修改
 */
+ (void)init:(nonnull NSString*)appId channel:(nullable NSString*)channel config:(nullable TestinConfig*)config;

/**
 *  设置用户信息，如不设置，平台将默认显示为“匿名用户”
 *
 *  @param userInfo 用户信息 注：若涉及敏感信息，请自行加密处理
 */
+ (void)setUserInfo:(nonnull NSString*)userInfo;

/**
 *  上传程序内捕获的异常信息
 *
 *  @param exception 异常对象
 *  @param message   设置自定义信息
 */
+ (void)reportCustomizedException:(nonnull NSException*)exception message:(nonnull NSString*)message;
/**
 *  上传程序内捕获的异常信息
 *
 *  @param type       语言类型 其中包括：Java:0; C++:1; OC:2; Lua:3; JS:4; C#:5
 *  @param message    自定义信息
 *  @param stackTrace 调用栈信息
 */
+ (void)reportCustomizedException:(nonnull NSNumber*)type message:(nonnull NSString*)message stackTrace:(nonnull NSString*)stackTrace;

/**
 *  上传HTTP请求信息
 *
 *  @param request   请求对象
 *  @param response  响应对象
 *  @param latency   请求耗时
 *  @param bytesRecv 接收数据的字节数
 *  @param bytesSend 发送数据的字节数
 *  @param error     错误描述对象
 *
 *  @return 成功返回YES，其他返回NO
 */
+ (BOOL)reportURLRequest:(nonnull NSURLRequest*)request
                response:(nonnull NSURLResponse*)response
                 latency:(NSTimeInterval)latency
               bytesRecv:(NSInteger)bytesRecv
               bytesSend:(NSInteger)bytesSend
                   error:(nullable NSError*)error;
/**
 *  上传HTTP请求信息
 *
 *  @param url         请求地址
 *  @param method      请求方法
 *  @param contentType 请求协议类型
 *  @param latency     请求耗时
 *  @param bytesRecv   接收数据的字节数
 *  @param bytesSend   发送数据的字节数
 *  @param statusCode  响应状态码
 *
 *  @return 成功返回YES，其他返回NO
 */
+ (BOOL)reportURL:(nonnull NSString*)url
           method:(nonnull NSString*)method
      contentType:(nonnull NSString*)contentType
          latency:(NSTimeInterval)latency
        bytesRecv:(NSInteger)bytesRecv
        bytesSend:(NSInteger)bytesSend
       statusCode:(NSInteger)statusCode;
/**
 *  自定义日志记录
 *
 *  @param string 自定义字符串
 */
+ (void)leaveBreadcrumbWithString:(nonnull NSString*)string;
/**
 *  自定义记录日志
 *
 *  @param format 自定义格式化字符串
 */
+ (void)leaveBreadcrumbWithFormat:(nonnull NSString*)format, ...;

/**
 *  释放SDK资源
 */
+ (void)terminate;

@end
