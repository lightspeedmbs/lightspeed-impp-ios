//
//  ApiCaller.m
//  AnSocialTwo
//
//  Created by Tim on 10/27/14.
//  Copyright (c) 2014 Herxun. All rights reserved.
//

#define BOUNDARY @"---------------------------14737809831466499882746641449"
#define DATA(X)	[X dataUsingEncoding:NSUTF8StringEncoding]

#import "ApiCaller.h"

@interface ApiCaller ()
@property (strong, nonatomic) NSMutableData *httpPostResponse;

@end

@implementation ApiCaller

#pragma mark - Init

+ (ApiCaller *)caller
{
    static ApiCaller *_caller = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _caller = [[ApiCaller alloc] init];
    });
    return _caller;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Public

- (void)httpRequestWithMethod:(NSString *)method
                          url:(NSString *)urlString
                         body:(NSDictionary *)requestBody
                   attachment:(NSDictionary *)attachment
                   completion:(void (^)(BOOL, NSDictionary*, NSError*))completion
{
    NSMutableString *bodyString = [[NSMutableString alloc] initWithCapacity:0];
    for (NSString *key in [requestBody allKeys])
    {
        [bodyString appendString:[NSString stringWithFormat:@"%@=%@&", key, requestBody[key]]];
    }
    
    NSMutableURLRequest* request;
    if ([method isEqualToString:@"GET"])
    {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, bodyString.length > 1 ? [bodyString substringToIndex:bodyString.length-1] : bodyString]]];
    }
    else if ([method isEqualToString:@"POST"])
    {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        if (attachment)
        {
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BOUNDARY];
            [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
            NSMutableData *body = [NSMutableData data];
            
            if ([attachment[@"type"] isEqualToString:@"image"])
            {
                // image
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Disposition: form-data; name=\"photo\"; filename=\"photo.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[NSData dataWithData:attachment[@"data"]]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            for (NSString *request in [requestBody allKeys])
            {
                // text parameter
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", request] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[requestBody[request] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
            [request setHTTPBody:body];
        }
        else
        {
            if (bodyString && ![bodyString isEqualToString:@""])
            {
                NSData* postData = [[bodyString substringToIndex:bodyString.length-1] dataUsingEncoding:NSUTF8StringEncoding];
                NSString* postDataLengthString = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [request setValue:postDataLengthString forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
            }
        }
    }
    else
    {
        if (completion)
            completion(NO, nil, [NSError errorWithDomain:nil code:0 userInfo:@{@"description": @"Incorrect HTTP Methods"}]);
    }
    
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    [request setHTTPMethod:method];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError* error)
     {
         if (error)
         {
             if (completion)
                 completion(NO, nil, error);
         }
         else
         {
             NSDictionary* dictData = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingMutableLeaves
                                                                        error:nil];
             NSDictionary* dictMeta = [dictData objectForKey:@"meta"];
             if (dictMeta)
             {
                 if (!dictMeta[@"errorCode"])
                 {
                     if (completion)
                         completion(YES, dictData[@"response"], nil);
                 }
                 else
                 {
                     if (completion)
                         completion(NO, dictMeta, nil);
                 }
                 //                [[NSNotificationCenter defaultCenter] postNotificationName:@"AnSocialAPICallResponsed" object:nil];
             }
         }
     }];
}

@end
