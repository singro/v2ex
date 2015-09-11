//
//  UIImage+Cache.h
//  v2ex-iOS
//
//  Created by Singro on 9/11/15.
//  Copyright © 2015 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Cache)

@property (nonatomic, assign) BOOL cached;

- (UIImage *)imageWithCornerRadius:(CGFloat)cornerRadius;

@end
