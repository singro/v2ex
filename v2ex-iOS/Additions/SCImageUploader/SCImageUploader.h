//
//  SCImageUploader.h
//  v2ex-iOS
//
//  Created by Singro on 8/6/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCImageUploader : NSObject

- (instancetype)initWithImage:(UIImage *)image compelete:(void (^)(NSURL *url, BOOL finished))block;

- (void)sc_show:(BOOL)animated;

- (void)sc_hide:(BOOL)animated;

+ (UIImage *)scaleAndRotateImage:(UIImage *)image;

@end
