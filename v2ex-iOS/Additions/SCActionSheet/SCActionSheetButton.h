//
//  SCActionSheetButton.h
//  KeyShare
//
//  Created by Singro on 12/27/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCActionSheetButtonType) {
    SCActionSheetButtonTypeRed,
    SCActionSheetButtonTypeNormal
};

@interface SCActionSheetButton : UIButton

@property (nonatomic, strong) UIColor *buttonBottomLineColor;
@property (nonatomic, strong) UIColor *buttonBackgroundColor;
@property (nonatomic, strong) UIColor *buttonBorderColor;

@property (nonatomic, assign) SCActionSheetButtonType type;

@end
