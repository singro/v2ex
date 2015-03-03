//
//  V2CheckInManager.h
//  v2ex-iOS
//
//  Created by Singro on 7/6/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface V2CheckInManager : NSObject

@property (nonatomic, assign) NSInteger checkInCount;
@property (nonatomic, assign, getter = isExpired) BOOL expired;

+ (instancetype)manager;

- (void)resetStatus;

- (void)updateStatus;

- (void)removeStatus;

- (NSURLSessionDataTask *)checkInSuccess:(void (^)(NSInteger count))success
                                 failure:(void (^)(NSError *error))failure;

@end
