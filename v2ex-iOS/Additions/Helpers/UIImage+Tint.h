//
//  UIImage+Tint.h
//  v2ex-iOS
//
//  Created by Singro on 5/25/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIImage (SCTint)

@property (nonatomic, strong) UIImage *imageForCurrentTheme;

- (UIImage *)imageWithTintColor:(UIColor *)tintColor;

- (CGSize)fitWidth:(CGFloat)fitWidth;

@end
