//
//  V2MenuView.h
//  v2ex-iOS
//
//  Created by Singro on 3/18/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2MenuView : UIView

@property (nonatomic, copy) void (^didSelectedIndexBlock)(NSInteger index);

- (void)setDidSelectedIndexBlock:(void (^)(NSInteger index))didSelectedIndexBlock;



@property (nonatomic, strong) UIImage *blurredImage;

- (void)setOffsetProgress:(CGFloat)progress;

@end
