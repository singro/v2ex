//
//  SCActionSheetButton.m
//  KeyShare
//
//  Created by Singro on 12/27/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCActionSheetButton.h"

@interface SCActionSheetButton ()

@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation SCActionSheetButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.type = SCActionSheetButtonTypeNormal;
        
        self.layer.borderColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1] CGColor];
        self.layer.borderWidth = 0.5f;
        self.backgroundColor = [UIColor whiteColor];
        [self setTitleColor:kFontColorBlackMid forState:UIControlStateNormal];
        self.titleLabel.backgroundColor = [UIColor clearColor];

        UIView *tempview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44.0f)];
        tempview.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1];
        UIImage *btnImage = [V2Helper getImageFromView:tempview];
        
        if (btnImage && btnImage.size.width > 0) {
            [self setBackgroundImage:btnImage forState:UIControlStateReserved];
            [self setBackgroundImage:btnImage forState:UIControlStateSelected];
            [self setBackgroundImage:btnImage forState:UIControlStateHighlighted];
        }

        self.bottomLineView = [[UIView alloc] initWithFrame:(CGRect){0, self.height, self.width, 0.5}];
        self.bottomLineView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.07];
        [self addSubview:self.bottomLineView];

        
    }
    return self;
}

- (void)setButtonBackgroundColor:(UIColor *)buttonBackgroundColor {
    _buttonBackgroundColor = buttonBackgroundColor;
        
    UIView *tempview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44.0f)];
    tempview.backgroundColor = self.buttonBackgroundColor;
    UIImage *btnImage = [V2Helper getImageFromView:tempview];
    
    if (btnImage && btnImage.size.width > 0) {
        [self setBackgroundImage:btnImage forState:UIControlStateReserved];
        [self setBackgroundImage:btnImage forState:UIControlStateSelected];
        [self setBackgroundImage:btnImage forState:UIControlStateHighlighted];
    }

}

- (void)setButtonBottomLineColor:(UIColor *)buttonBottomLineColor {
    _buttonBottomLineColor = buttonBottomLineColor;
    
    self.bottomLineView.backgroundColor = self.buttonBottomLineColor;
    
}

- (void)setButtonBorderColor:(UIColor *)buttonBorderColor {
    _buttonBorderColor = buttonBorderColor;
    
    self.layer.borderColor = self.buttonBorderColor.CGColor;

}

- (void)setType:(SCActionSheetButtonType)type {
    _type = type;
    
    if (type == SCActionSheetButtonTypeRed) {
        
        self.backgroundColor = RGB(0xf86a5b, 1.0);
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.buttonBackgroundColor = RGB(0xe95545, 1.0);
        self.buttonBottomLineColor = RGB(0xe95545, 1.0);
        self.buttonBorderColor = RGB(0xe95545, 1.0);

    } else {
        
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1];
        [self setTitleColor:[UIColor colorWithRed:110.0f/255.0f green:110.0f/255.0f blue:110.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        self.buttonBackgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1];
        self.buttonBottomLineColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.07];
        self.buttonBorderColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1];

    }
    
}

@end
