//
//  V2TopicToolBarView.m
//  v2ex-iOS
//
//  Created by Singro on 3/23/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2TopicToolBarView.h"

#import "V2TopicToolBarItemView.h"

CGFloat const kMaxCircleOffsetX = 240.0;
CGFloat const kCircleHeight     = 28.0;

@interface V2TopicToolBarView ()

@property (nonatomic, assign) CGPoint          locationEnd;

@property (nonatomic, strong) UIView           *circleView;
@property (nonatomic, strong) NSMutableArray   *toolBarItemArray;

@property (nonatomic, strong) SCMetionTextView *textView;

@property (nonatomic, strong) NSArray          *itemTitleArray;
@property (nonatomic, strong) NSArray          *itemImageArray;

@property (nonatomic, strong) UIImageView      *backgroundImageView;
@property (nonatomic, strong) UIButton         *backgroundButton;

@property (nonatomic, strong) UIButton         *imageInsertButton;
@property (nonatomic, assign) NSInteger        keyboardHeight;
@property (nonatomic, assign) NSInteger        sharpIndex;

@property (nonatomic, copy) NSString *contentString;

@property (nonatomic, assign, readwrite) BOOL isShowing;

@end

@implementation V2TopicToolBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor        = [UIColor clearColor];
        self.userInteractionEnabled = NO;

        self.isShowing = NO;
        
//        self.itemTitleArray         = @[@"分享", @"收藏", @"评论", @"设置"];
//        self.itemImageArray         = @[@"icon_share", @"icon_fav", @"icon_reply", @"icon_setting"];
        self.itemTitleArray         = @[@"评论", @"收藏"];
        self.itemImageArray         = @[@"icon_reply", @"icon_fav"];

        [self configureViews];
        [self configureImageInsertView];
//        [self configureToolBarItems];
        [self configureBlocks];
        [self configureNotifications];

    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configure

- (void)configureViews {
    
    self.backgroundImageView = [[UIImageView alloc] init];
    self.backgroundImageView.backgroundColor = kBackgroundColorWhite;
    self.backgroundImageView.alpha           = 0.0;
    [self addSubview:self.backgroundImageView];

    self.backgroundButton                    = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.backgroundButton];

//    self.circleView                          = [[UIView alloc] init];
//    self.circleView.backgroundColor          = [UIColor colorWithRed:0.182 green:0.645 blue:1.000 alpha:1.000];
//    self.circleView.clipsToBounds            = YES;
//    self.circleView.layer.cornerRadius       = kCircleHeight / 2.0;
//    [self addSubview:self.circleView];

    self.textView                            = [[SCMetionTextView alloc] initWithFrame:CGRectMake(10, 368 - kScreenHeight, kScreenWidth - 20, kScreenHeight - 368)];
    self.textView.textColor                  = kFontColorBlackDark;
    self.textView.layer.borderColor          = kLineColorBlackLight.CGColor;
    self.textView.backgroundColor            = kBackgroundColorWhite;
    self.textView.layer.borderWidth          = 0.5;
    self.textView.font                       = [UIFont systemFontOfSize:17];
    self.textView.returnKeyType              = UIReturnKeyDefault;
    self.textView.autocapitalizationType     = UITextAutocapitalizationTypeNone;
    self.textView.autocorrectionType         = UITextAutocorrectionTypeNo;
    self.textView.contentInsetTop            = 2;
    self.textView.contentInsetLeft           = 5;
    self.textView.showsHorizontalScrollIndicator = NO;
    self.textView.alwaysBounceHorizontal = NO;
    [self addSubview:self.textView];
    
    if (kCurrentTheme == V2ThemeNight) {
        self.textView.keyboardAppearance         = UIKeyboardAppearanceDark;
        self.textView.placeholderColor           = [UIColor colorWithRed:0.820 green:0.820 blue:0.840 alpha:0.240];
    } else {
        self.textView.keyboardAppearance         = UIKeyboardAppearanceDefault;
        self.textView.placeholderColor           = [UIColor colorWithRed:0.82f green:0.82f blue:0.84f alpha:1.00f];
    }
    
    // handles
    @weakify(self);
    
    [self.textView setTextViewShouldChangeBlock:^BOOL(UITextView *textView, NSString *text) {
        @strongify(self);
        
        if ([text isEqualToString:@"&"]) {
            
            self.sharpIndex = textView.text.length + 1;
            [self showImageInsertView];
            
        } else {
            
            self.sharpIndex = NSNotFound;
            [self hideImageInsertView];
            
        }
        
        return YES;
    }];

    [self.textView setTextViewDidChangeBlock:^(UITextView *textView) {
        @strongify(self);
        
        if (self.contentIsEmptyBlock) {
            self.contentIsEmptyBlock(textView.text.length == 0);
        }
        
    }];

}

- (void)configureToolBarItems {
    
    self.toolBarItemArray = [[NSMutableArray alloc] init];
    
    void (^buttonHandleBlock)(NSInteger index) = ^(NSInteger index) {
        
        if (index == 0) {
            [self showReplyViewWithQuotes:nil animated:YES];
        }
        
        if (index == 1) {
            ;
        }

//        if (index == 2) {
//            
//            
//        }
//
//        if (index == 3) {
//            ;
//        }

        
    };
    
    for (int i = 0; i < 2; i ++) {
        V2TopicToolBarItemView *item = [[V2TopicToolBarItemView alloc] init];
        item.itemTitle = self.itemTitleArray[i];
        item.itemImage = [UIImage imageNamed:self.itemImageArray[i]];
        item.alpha = 0.0;
        item.buttonPressedBlock = ^{
            buttonHandleBlock(i);
        };
        [self addSubview:item];
        [self.toolBarItemArray addObject:item];
    }
    
}

- (void)configureImageInsertView {
    
    self.imageInsertButton = [[UIButton alloc] initWithFrame:(CGRect){0, 0, 100, 36}];
    self.imageInsertButton.backgroundColor = kFontColorBlackDark;
    self.imageInsertButton.alpha = 0.3;
    self.imageInsertButton.layer.cornerRadius = 3;
    self.imageInsertButton.clipsToBounds = YES;
    [self.imageInsertButton setTitle:@"插入图片" forState:UIControlStateNormal];
    [self.imageInsertButton setTitleColor:kLineColorBlackDark forState:UIControlStateNormal];
    [self addSubview:self.imageInsertButton];
    
    self.imageInsertButton.centerX = 160;
    [self hideImageInsertView];
    
    // Handles
    @weakify(self);
    [self.imageInsertButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        
        self.textView.text = [self.textView.text substringToIndex:self.sharpIndex - 1];
        [self hideImageInsertView];
        
        if (self.insertImageBlock) {
            [self.textView resignFirstResponder];
            self.insertImageBlock();
        }
        
    } forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)configureBlocks {
    
    [self.backgroundButton bk_addEventHandler:^(id sender) {
        
        [self hideToolBar];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)configureNotifications {
    
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:kReplySuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        
        [self hideToolBar];
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        
        CGRect keyboardFrame;
        [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        
        self.keyboardHeight = keyboardFrame.size.height;

        
    }];
    
}

#pragma mark - Layout

- (void)layoutSubviews {
    
    self.backgroundImageView.frame = self.frame;
    self.backgroundButton.frame    = self.frame;
    self.circleView.frame          = (CGRect){321, 200, kCircleHeight, kCircleHeight};
    
    self.imageInsertButton.centerY = (kScreenHeight - self.keyboardHeight - self.textView.y - self.textView.height) / 2 + self.textView.y + self.textView.height;

    if (self.isCreate) {
        self.textView.placeholder      = @"输入主题内容";
        [self.backgroundButton bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
    } else {
        self.textView.placeholder      = @"让回复对别人有帮助";
    }

}

#pragma mark - Setters

- (void)setOffset:(CGFloat)offset {
    _offset = offset;
    
    if (self.isShowing) {
        return;
    }
    
    self.circleView.x = offset;
    
}

- (void)setLocationStart:(CGPoint)locationStart {
    _locationStart = locationStart;
    
    if (self.isShowing) {
        return;
    }

    if (self.locationStart.y > 100 && self.locationStart.y < self.height - 100) {
        [UIView animateWithDuration:0.1 animations:^{
            self.circleView.centerY = self.locationStart.y * 0.8;
            self.circleView.centerX = self.locationStart.x * 0.8;
        }];
        
        self.userInteractionEnabled = YES;
    }
    
}

- (void)setLocationChanged:(CGPoint)locationChanged {
    _locationChanged = locationChanged;
    
    if (self.isShowing) {
        return;
    }

    if (self.isUserInteractionEnabled) {
//        CGFloat changedRateX = MAX(kMaxCircleOffsetX, self.locationChanged.x * 1.3);
        self.circleView.centerX = self.locationChanged.x * 0.4;

//        CGFloat changedRateY = MAX(kMaxCircleOffsetX, self.locationChanged.y * 1.3);
        self.circleView.centerY = self.locationChanged.y * 0.7;
}
    
}

- (void)setLocationEnd:(CGPoint)locationEnd velocity:(CGPoint)velocity {
    _locationEnd = locationEnd;
    
    if (self.isShowing) {
        return;
    }

    if (self.isUserInteractionEnabled) {
        
        if (self.circleView.centerX < kMaxCircleOffsetX + 5 || velocity.x < 0) {
            [self showMenu];
        } else {
//            [self hideCircle];
        }
        
    }

}

- (void)setBlurredBackgroundImage:(UIImage *)blurredBackgroundImage {
    _blurredBackgroundImage = blurredBackgroundImage;
    
    self.backgroundImageView.image = self.blurredBackgroundImage;
    
}

- (NSString *)replyContentString {
    
    if (!self.contentString) {
        self.contentString = self.textView.renderedString;
    }
    return self.contentString;
    
}

- (BOOL)isContentEmpty {
    return self.textView.text.length == 0;
}

#pragma mark - Public Methods

- (void)showReplyViewWithQuotes:(NSArray *)quotes animated:(BOOL)animated {
    
    self.userInteractionEnabled = YES;
    self.isShowing = YES;

    if (quotes.count) {
        for (SCQuote *quote in quotes) {
            [self.textView addQuote:quote];
        }
    }

    if (animated) {
        [UIView animateWithDuration:0.1 animations:^{
            self.circleView.x = 321;
            for (V2TopicToolBarItemView *item in self.toolBarItemArray) {
                item.alpha = 0.0;
            }
        } completion:^(BOOL finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowReplyTextViewNotification object:nil];
            
            [self.textView becomeFirstResponder];
            
            [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.95 options:UIViewAnimationOptionCurveEaseIn animations:^{
                //                    self.backgroundImageView.alpha = 1;
                self.textView.y = UIView.sc_navigationBarHeight + 10;
            } completion:^(BOOL finished) {
                self.imageInsertButton.centerY = (kScreenHeight - self.keyboardHeight - self.textView.y - self.textView.height) / 2 + self.textView.y + self.textView.height;
            }];
            
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.backgroundImageView.alpha = 1;
                //                    self.textView.y = 74;
            } completion:^(BOOL finished) {
                ;
            }];
        }];
    } else {
        
        self.circleView.x = 321;
        for (V2TopicToolBarItemView *item in self.toolBarItemArray) {
            item.alpha = 0.0;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowReplyTextViewNotification object:nil];
        
        [self.textView becomeFirstResponder];
        
        self.textView.y = UIView.sc_navigationBarHeight + 10;
        
        self.imageInsertButton.centerY = (kScreenHeight - self.keyboardHeight - self.textView.y - self.textView.height) / 2 + self.textView.y + self.textView.height;

        self.backgroundImageView.alpha = 1;
        
    }
    
}

- (void)addImageWithURL:(NSURL *)url {
    
    SCQuote *quote = [[SCQuote alloc] init];
    quote.type = SCQuoteTypeImage;
    quote.string = @"图片";
    quote.identifier = url.absoluteString;
    
    [self.textView addQuote:quote];
    
}

- (void)clearTextView {
    [self.textView removeAllQuotes];
    self.textView.text = @"";
}

- (void)popToolBar {
    [self hideToolBar];
}

#pragma mark - Animation Action

- (void)showMenu {
    
    self.isShowing = YES;
    
    for (int i = 0; i < self.toolBarItemArray.count; i ++) {
        
        V2TopicToolBarItemView *item = self.toolBarItemArray[i];
        item.alpha                   = 0.0;
//        item.centerY = self.circleView.centerY - (4 - i) * 44;
        item.x                       = kMaxCircleOffsetX - kCircleHeight / 2.0;
        item.y                       = self.circleView.centerY + i * 44;
        item.x                       = self.circleView.centerX;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
//        self.circleView.centerX = kMaxCircleOffsetX;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1 animations:^{
//            self.circleView.height = 180;
//            self.circleView.frame = CGRectMake(self.circleView.x, self.circleView.y, 100, 180);
//            self.circleView.size = (CGSize){180, 180};
//            self.circleView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        } completion:^(BOOL finished) {
            
//            self.circleView.x = 321;
//            self.circleView.transform = CGAffineTransformIdentity;

            [UIView animateWithDuration:0.3 animations:^{
                for (V2TopicToolBarItemView *item in self.toolBarItemArray) {
                    item.alpha = 1.0;
                }
            }];
        }];
        
    }];
    
}

- (void)hideCircle {
    
    self.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.circleView.x = 321;
//        for (V2TopicToolBarItemView *item in self.toolBarItemArray) {
//            item.alpha = 0.0;
//        }
    }];
    
}

- (void)hideToolBar {
    
    self.isShowing = NO;

    self.userInteractionEnabled = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideReplyTextViewNotification object:nil];
    [self hideImageInsertView];
    
    if (self.textView.y > 0) {
        [UIView animateWithDuration:0.1 animations:^{
            self.textView.y = UIView.sc_navigationBarHeight + 20;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1.05 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.textView.y = -self.textView.height;
            } completion:nil];
        }];
    }

    [UIView animateWithDuration:0.3 animations:^{
        self.circleView.x = 321;
        [self.textView resignFirstResponder];
        self.backgroundImageView.alpha = 0.0;
        for (V2TopicToolBarItemView *item in self.toolBarItemArray) {
            item.x = 321;
        }
    }];

}

- (void)showImageInsertView {
    
    self.imageInsertButton.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.imageInsertButton.alpha = 0.3;
    }];
    
}

- (void)hideImageInsertView {
    
    self.imageInsertButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.imageInsertButton.alpha = 0.0;
    }];

}

@end
