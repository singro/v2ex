//
//  SCWeiboManager.m
//  SCWeiboManagerDemo
//
//  Created by Singro on 6/4/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCWeiboManager.h"

#import "JSONKit.h"
#import "FXKeychain.h"

#import "WBRequest+Block.h"

static NSString *const kBaseURL = @"https://api.weibo.com/2/";

static NSString *const kWeiboToken = @"kWeiboToken";
static NSString *const kWeiboExpirationDate = @"kWeiboExpirationDate";

@interface SCWeiboManager () <WBHttpRequestDelegate>

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSDate *expirationDate;

@property (nonatomic, readwrite, getter = isExpired, setter = expired:) BOOL expired;

@property (nonatomic, strong) WBAuthorizeRequest *authorizeRequest;

@end

@implementation SCWeiboManager


+ (instancetype)manager {
    static SCWeiboManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SCWeiboManager alloc] init];
        
        [WeiboSDK registerApp:kWeiboAppKey];

        manager.token = [[FXKeychain defaultKeychain] objectForKey:kWeiboToken];
        manager.expirationDate = [[FXKeychain defaultKeychain] objectForKey:kWeiboExpirationDate];
        
    });
    
    return manager;
}

#pragma mark - Setters & getters

- (void)setToken:(NSString *)token {
    _token = token;
    
    [[FXKeychain defaultKeychain] setObject:token forKey:kWeiboToken];
    
}

- (void)setExpirationDate:(NSDate *)expirationDate {
    _expirationDate = expirationDate;
    
    [[FXKeychain defaultKeychain] setObject:expirationDate forKey:kWeiboExpirationDate];
    
}

- (BOOL)isExpired {
    if (self.expirationDate && [self.expirationDate timeIntervalSinceNow] > 0) {
        return NO;
    }
    return YES;
}

- (void)clean {

    [[FXKeychain defaultKeychain] removeObjectForKey:kWeiboToken];
    [[FXKeychain defaultKeychain] removeObjectForKey:kWeiboExpirationDate];
    _token = nil;
    _expirationDate = nil;
    
}

#pragma mark - Base Request

- (WBHttpRequest *)requestWithUrl:(NSString *)url
                       httpMethod:(NSString *)httpMethod
                       parameters:(NSDictionary *)parameters
                          success:(void (^)(WBHttpRequest *reuqest, id responseObject))success
                          failure:(void (^)(NSError *error))failure {
    
    NSString *urlString = [kBaseURL stringByAppendingString:url];
    
    NSMutableDictionary *paras = [[NSMutableDictionary alloc] init];
    [paras setObject:kWeiboAppKey forKey:@"source"];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paras setObject:obj forKey:key];
    }];
    
    WBHttpRequest *request = [WBHttpRequest requestWithAccessToken:self.token
                                                               url:urlString
                                                        httpMethod:httpMethod
                                                            params:paras
                                                          delegate:self
                                                           withTag:nil];
    
    request.successBlock = success;
    request.failureBlock = failure;
    
    return request;
}

#pragma mark - Authorize

- (WBAuthorizeRequest *)authorizeToWeiboSuccess:(void (^)(WBBaseResponse *response))success
                                        failure:(void (^)(NSError *error))failure {
    
    self.authorizeRequest = [WBAuthorizeRequest request];
    self.authorizeRequest.redirectURI = kWeiboRedirectUrl;
    self.authorizeRequest.scope = @"all";
    self.authorizeRequest.successBlock = success;
    self.authorizeRequest.failureBlock = failure;
    [WeiboSDK sendRequest:self.authorizeRequest];
    
    return self.authorizeRequest;

}


#pragma mark - Request

#pragma mark - WBHttpRequestDelegate

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    
    id responseObject = [result objectFromJSONString];
    
    if (request.successBlock) {
        request.successBlock(request, responseObject);
    }
    
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error;
{
    
    if (request.failureBlock) {
        request.failureBlock(error);
    }
    
}

#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        
        
        self.token = [(WBAuthorizeResponse *)response accessToken];
        self.userId = [(WBAuthorizeResponse *)response userID];
        self.expirationDate = [(WBAuthorizeResponse *)response expirationDate];
        if(self.token) {
            if (self.authorizeRequest.successBlock) {
                self.authorizeRequest.successBlock(response);
            }
        } else {
            if (self.authorizeRequest.failureBlock) {
                NSError *error = [[NSError alloc] initWithDomain:@"singro.v2ex" code:WeiboSDKResponseStatusCodeUserCancel userInfo:nil];
                self.authorizeRequest.failureBlock(error);
            }
        }
        
    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class]) {
        
    }
    
}

#pragma mark - Custom Methods

#pragma mark - Send Weibo

- (WBHttpRequest *)sendWeiboWithText:(NSString *)text
                             Success:(void (^)(NSDictionary *responseDict))success
                             failure:(void (^)(NSError *error))failure {
    if (!text) {
        return nil;
    }
    
    return [self requestWithUrl:@"statuses/update.json"
                     httpMethod:@"POST"
                     parameters:@{@"status":text}
                        success:^(WBHttpRequest *reuqest, id responseObject) {
                            if (success) {
                                success(responseObject);
                            }
                        } failure:^(NSError *error) {
                            if (failure) {
                                failure(error);
                            }
                        }];
}


- (WBHttpRequest *)sendWeiboWithText:(NSString *)text
                               image:(UIImage *)image
                             Success:(void (^)(NSDictionary *responseDict))success
                             failure:(void (^)(NSError *error))failure {
    
    if (!text || !image) {
        return nil;
    }
    
    return [self requestWithUrl:@"statuses/upload.json"
                     httpMethod:@"POST"
                     parameters:@{
                                  @"status":text,
                                  @"pic": UIImagePNGRepresentation(image),
                                  @"visible": @"2",
                                  }
                        success:^(WBHttpRequest *reuqest, id responseObject) {
                            if (success) {
                                success(responseObject);
                            }
                        } failure:^(NSError *error) {
                            if (failure) {
                                failure(error);
                            }
                        }];

    
}

#pragma mark - Upload Image

- (WBHttpRequest *)uploadImage:(UIImage *)image
                       Success:(void (^)(NSURL *url))success
                       failure:(void (^)(NSError *error))failure {
    
    if (!image) {
        return nil;
    }
    
    return [self requestWithUrl:@"statuses/upload.json"
                     httpMethod:@"POST"
                     parameters:@{
                                  @"status":@"#V2EX图片#",
                                  @"pic": UIImagePNGRepresentation(image),
                                  @"visible": @"2",
                                  }
                        success:^(WBHttpRequest *reuqest, id responseObject) {
                            if (success) {
                                NSDictionary *dict = (NSDictionary *)responseObject;
                                NSString *imageURL = [dict objectForSafeKey:@"original_pic"];
                                success([NSURL URLWithString:imageURL]);
                            }
                        } failure:^(NSError *error) {
                            if (failure) {
                                failure(error);
                            }
                        }];

}

@end
