//
//  SCActionSheet.h
//  KeyShare
//
//  Created by Singro on 12/27/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCActionSheetButton;

@interface SCActionSheet : UIView

@property (nonatomic, copy) UIColor *titleTextColor;
@property (nonatomic, copy) UIColor *deviderLineColor;
@property (nonatomic, copy) void (^endAnimationBlock)();

@property (nonatomic, strong) UIView *showInView;

+ (BOOL)isActionSheetShowing;

- (instancetype)sc_initWithTitles:(NSArray *)titles customViews:(NSArray *)customViews buttonTitles:(NSString *)buttonTitles, ...;

//- (instancetype)initWithTitle:(NSString *)title customView:(UIView *)customView titleArray:(NSArray *)buttonTitles;

- (void)sc_setButtonHandler:(void (^)(void))block forIndex:(NSInteger)index;

- (void)sc_configureButtonWithBlock:(void (^)(SCActionSheetButton *button))block forIndex:(NSInteger)index;

- (void)sc_show:(BOOL)animated;

- (void)sc_hide:(BOOL)animated;

@end
