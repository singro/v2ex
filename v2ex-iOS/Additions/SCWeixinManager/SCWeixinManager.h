//
//  SCWeixinManager.h
//  v2ex-iOS
//
//  Created by Singro on 8/8/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "WXApi.h"

#import "V2AppKeys.h"

@interface SCWeixinManager : NSObject <WXApiDelegate>

+ (instancetype)manager;

- (void)shareWithWXScene:(enum WXScene)scene
                   Title:(NSString *)title
                    link:(NSString *)link
             description:(NSString *)description
                   image:(UIImage *)image;

@end
