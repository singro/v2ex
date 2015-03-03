//
//  V2ActionItemView.h
//  KeyShare
//
//  Created by Singro on 12/29/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat const kItemHeight = 80;
static CGFloat const kItemHeightTitle = 100;
static CGFloat const kItemWidth = 50.;
static CGFloat const kTitleFontSize = 11;

@interface V2ActionItemView : UIView

@property (nonatomic, copy) void (^actionBlock)(UIButton *button, UILabel *label);

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName;

@end
