//
//  SCActionSheet.m
//  KeyShare
//
//  Created by Singro on 12/27/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCActionSheet.h"

#import "UIImage+REFrosted.h"
#import "UIView+REFrosted.h"

#import "SCActionSheetButton.h"

#define kButtonWidth (kScreenWidth - 64.0)

static CGFloat const kTitleLabelHeight = 20;
static CGFloat const kButtonHeight     = 44.0;
//static CGFloat const kCloseButtonWidth = 34.0;

static CGFloat const kTitleFontSize = 15;
static CGFloat const kButtonFontSize = 15;

static CGFloat const kAnimationDuration = 0.1f;

static BOOL kActionSheetShowing = NO;

@interface SCActionSheet ()

@property (nonatomic, strong) UIView      *contentView;
@property (nonatomic, strong) UIImageView *backgroundImageView;

// ActionSheet
//@property (nonatomic, strong) UIView      *containerView;
@property (nonatomic, strong) UIButton    *backgroundButton;

@property (nonatomic, strong) UIImageView *blurBackgroundImageView;
@property (nonatomic, strong) UIView      *backgroundMaskView;

// Data
@property (nonatomic, strong) NSArray *buttonArray;
@property (nonatomic, strong) NSArray *viewArray;
@property (nonatomic, strong) NSArray *titleLabelArray;

@property (nonatomic, assign) CGFloat contentHeight;

@end

@implementation SCActionSheet

- (instancetype)sc_initWithTitles:(NSArray *)titles customViews:(NSArray *)customViews buttonTitles:(NSString *)buttonTitles, ... {

    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    va_list argumentList;
    id eachObject = nil;
    
    if (buttonTitles) {
        [list addObject: buttonTitles];
        va_start(argumentList, buttonTitles);
        while ((eachObject = va_arg(argumentList, id)))
            [list addObject: eachObject];
        va_end(argumentList);
    }
    
    return [self initWithTitles:titles customViews:customViews buttonTitles:list];
}

- (instancetype)initWithTitles:(NSArray *)titles customViews:(NSArray *)customViews buttonTitles:(NSArray *)buttonTitles {
    
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        
        NSAssert(titles.count == customViews.count || (titles.count == 1 && customViews.count == 0), @"titles.count should equal to customViews.count or 1 for customViews.count = 0");
        
        self.titleTextColor = kFontColorBlackLight;
        self.deviderLineColor = kLineColorBlackLight;

        [self configureContainer];
        
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        self.contentView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0}];
        self.contentView.clipsToBounds = YES;
        [self addSubview:self.contentView];
        
        NSMutableArray *viewArray = [[NSMutableArray alloc] init];

        // configureCustomView
        if (titles.count) {
            
            NSMutableArray *titleLabelArray = [NSMutableArray new];
            
            if (customViews.count == 0) {
                
                UIView *customContainView = [[UIView alloc] init];

                UILabel *titleLabel = [self createTitleLabelWithTitle:titles.firstObject];
                [customContainView addSubview:titleLabel];
                
                CGFloat labelSpaceHeight = kTitleLabelHeight;
                titleLabel.y = 10;
                labelSpaceHeight = 10 + kTitleLabelHeight;

                [self.contentView addSubview:customContainView];
                [viewArray addObject:customContainView];
                [titleLabelArray addObject:titleLabel];

                // layout
                customContainView.frame = (CGRect){0, 0, kScreenWidth, labelSpaceHeight + 0.5};

                
            } else {
                
                for (NSInteger i = 0; i < titles.count; i ++) {
                    
                    UIView *customContainView = [[UIView alloc] init];
                    
                    UILabel *titleLabel = [self createTitleLabelWithTitle:titles[i]];
                    UIView *customView = customViews[i];
                    customView.origin = (CGPoint){0, 0};
                    
                    NSString *title = titles[i];
                    CGFloat labelSpaceHeight = kTitleLabelHeight;
                    if (title.length == 0) {
                        titleLabel.hidden = YES;
                        titleLabel.height = 0;
                        titleLabel.y = 0;
                        labelSpaceHeight = 0;
                    } else {
                        titleLabel.y = 10;
                        labelSpaceHeight = 10 + kTitleLabelHeight;
                    }
                    
                    [customContainView addSubview:titleLabel];
                    [customContainView addSubview:customView];
                    
                    UIView *lineView;
                    if (i < titles.count - 1 || buttonTitles.count > 0) {
                        lineView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0.5}];
                        lineView.backgroundColor = self.deviderLineColor;
                        [customContainView addSubview:lineView];
                    }
                    
                    // layout
                    customContainView.frame = (CGRect){0, 0, kScreenWidth, labelSpaceHeight + customView.height + 0.5};
                    customView.y = labelSpaceHeight;
                    lineView.y = customView.bottom;
                    
                    [self.contentView addSubview:customContainView];
                    [viewArray addObject:customContainView];
                    [titleLabelArray addObject:titleLabel];
                    
                }

            }
            
            self.titleLabelArray = titleLabelArray;
        }
        
        // configureButtons
        
        if (buttonTitles.count) {
            
            NSMutableArray *buttonArray = [[NSMutableArray alloc] init];
            
            for (NSInteger i= 0; i < buttonTitles.count; i ++) {
                
                UIView *buttonContainView = [[UIView alloc] init];
                SCActionSheetButton *button = [self createActionSheetButtonWithTitle:buttonTitles[i]];
                [buttonContainView addSubview:button];
                [buttonArray addObject:button];
                
                // layout
                CGFloat space = 15;
                button.y = space;
                if (i != buttonTitles.count - 1) {
                    buttonContainView.frame = (CGRect){0, 0, kScreenWidth, kButtonHeight + space};
                } else {
                    buttonContainView.frame = (CGRect){0, 0, kScreenWidth, kButtonHeight + space * 2};
                }
                
                
                [self.contentView addSubview:buttonContainView];
                [viewArray addObject:buttonContainView];
                
            }
            
            self.buttonArray = buttonArray;

        }
        
        // configureCancelButton
        UIView *buttonContainView = [[UIView alloc] init];
        UIButton *button = [[UIButton alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, kButtonHeight}];
        [button setTitle:@"取消" forState:UIControlStateNormal];
        [button setTitleColor:kFontColorBlackMid forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
        [buttonContainView addSubview:button];
        [button addTarget:self action:@selector(backgroundButtonPressed) forControlEvents:UIControlEventTouchUpInside];

        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0.5}];
        lineView.backgroundColor = self.deviderLineColor;
        [buttonContainView addSubview:lineView];

        // layout
        buttonContainView.frame = (CGRect){0, 0, kScreenWidth, kButtonHeight + 10};
        button.y = 5;
        
        [self.contentView addSubview:buttonContainView];
        [viewArray addObject:buttonContainView];
        
        
        // all
        self.viewArray = viewArray;
        
        // Layout ALl
        CGFloat allHeight = 0;
        for (NSInteger i = 0; i < viewArray.count; i ++) {
            UIView *view = viewArray[i];
            view.y = allHeight;
            allHeight += view.height;
        }
        
        self.contentView.height = allHeight;
        self.contentView.y = kScreenHeight;
        self.contentHeight = allHeight;

    }
    
    return self;
}


- (instancetype)init
{
    NSAssert(0, @"SCActionSheet must init with method: initWithTitles:customViews:buttonTitles");
    
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configureContainer {
    
    self.backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backgroundButton.backgroundColor = [UIColor colorWithWhite:0.000 alpha:1];
    self.backgroundButton.alpha = 0.0;
    self.backgroundButton.frame = [UIScreen mainScreen].bounds;
    [self.backgroundButton addTarget:self action:@selector(backgroundButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.backgroundMaskView = [[UIView alloc] initWithFrame:self.frame];
    self.backgroundMaskView.y = kScreenHeight;
    self.backgroundMaskView.clipsToBounds = YES;
    
    self.blurBackgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
    self.blurBackgroundImageView.y = - kScreenHeight;
    self.blurBackgroundImageView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.backgroundButton];
    [self addSubview:self.backgroundMaskView];
    [self.backgroundMaskView addSubview:self.blurBackgroundImageView];

}

#pragma mark - Private Action

- (void)backgroundButtonPressed {
    
    [self sc_hide:YES];
    
}

#pragma mark - Public Action

+ (BOOL)isActionSheetShowing {
    return kActionSheetShowing;
}

- (void)sc_setButtonHandler:(void (^)(void))block forIndex:(NSInteger)index {

    if (index >= self.buttonArray.count || !block) {
        return;
    }
    
    UIButton *button = self.buttonArray[index];
    
    @weakify(self);
    [button bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
    [button bk_addEventHandler:^(id sender) {
        @strongify(self);
        
        [self sc_hide:YES];
        block();
    } forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)sc_configureButtonWithBlock:(void (^)(SCActionSheetButton *button))block forIndex:(NSInteger)index {
    
    if (index >= self.buttonArray.count || !block) {
        return;
    }
    
    SCActionSheetButton *button = self.buttonArray[index];

    block(button);
    
}

- (void)sc_show:(BOOL)animated {
    
    kActionSheetShowing = YES;
    
    __block UIImage *image;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    void (^showBlock)() = ^{
        
        self.hidden = NO;
        self.backgroundButton.alpha = 0.0f;
        
        if (self.showInView) {
            [self.showInView bringSubviewToFront:self];
        } else {
            [window bringSubviewToFront:self];
        }
        
        
        if (animated) {
            [UIView animateWithDuration:kAnimationDuration + (self.contentHeight / 100) * 0.1 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1.2 options:UIViewAnimationOptionCurveLinear animations:^{
                self.backgroundButton.alpha = 0.5f;
                self.backgroundMaskView.y = kScreenHeight - self.contentHeight;
                self.blurBackgroundImageView.y = self.contentHeight - kScreenHeight;
                self.contentView.y = kScreenHeight - self.contentHeight;
            } completion:nil];
        } else {
            self.backgroundButton.alpha = 0.5f;
            self.backgroundMaskView.y = kScreenHeight - self.contentHeight;
            self.blurBackgroundImageView.y = self.contentHeight - kScreenHeight;
            self.contentView.y = kScreenHeight - self.contentHeight;
        }

    };
    
//    if ([[UIDevice currentDevice] is64bit]) {

        if (self.showInView) {
            image = [self.showInView re_screenshot];
        } else {
            image = [window re_screenshot];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            image = [image re_applyBlurWithRadius:7.0 tintColor:[UIColor colorWithWhite:1 alpha:0.85f] saturationDeltaFactor:1.8 maskImage:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.blurBackgroundImageView.image = image;
                showBlock();
                
            });
        });
//    }
//    else {
//        
//        self.blurBackgroundImageView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:0.97f];
//        showBlock();
//
//    }

}

- (void)sc_hide:(BOOL)animated {
    
    kActionSheetShowing = NO;

    if (animated) {
        [UIView animateWithDuration:kAnimationDuration + (self.contentHeight / 120) * 0.1 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1.2 options:UIViewAnimationOptionCurveLinear animations:^{
            self.backgroundButton.alpha = 0.0f;
            self.backgroundMaskView.y = kScreenHeight;
            self.blurBackgroundImageView.y = - kScreenHeight;
            self.contentView.y = kScreenHeight;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            if (self.endAnimationBlock) {
                self.endAnimationBlock();
                self.endAnimationBlock = nil;
            }
            [self removeFromSuperview];
        }];
    } else {
        self.backgroundButton.alpha = 0.0f;
        self.backgroundMaskView.y = kScreenHeight;
        self.blurBackgroundImageView.y = - kScreenHeight;
        self.contentView.y = kScreenHeight;
        self.hidden = YES;
        if (self.endAnimationBlock) {
            self.endAnimationBlock();
            self.endAnimationBlock = nil;
        }
        [self removeFromSuperview];
    }

}

#pragma mark - Public Setters

- (void)setTitleTextColor:(UIColor *)titleTextColor {
    _titleTextColor = titleTextColor;
    
    for (UILabel *label in self.titleLabelArray) {
        label.textColor = titleTextColor;
    }
}

#pragma mark - Private

- (UILabel *)createTitleLabelWithTitle:(NSString *)title {
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:kTitleFontSize];
    label.text = title;
    label.textColor = self.titleTextColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = (CGRect){0, 0, kButtonWidth, kTitleLabelHeight};
    label.centerX = kScreenWidth/2;
    
    return label;
}

- (SCActionSheetButton *)createActionSheetButtonWithTitle:(NSString *)title {
    
    SCActionSheetButton *actionSheetButton = [[SCActionSheetButton alloc] initWithFrame:(CGRect){0, 0, kButtonWidth, kButtonHeight}];
    actionSheetButton.centerX = kScreenWidth/2;
    [actionSheetButton setTitle:title forState:UIControlStateNormal];
    actionSheetButton.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];

    return actionSheetButton;
}

@end
