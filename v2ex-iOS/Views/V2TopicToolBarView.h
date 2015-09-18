//
//  V2TopicToolBarView.h
//  v2ex-iOS
//
//  Created by Singro on 3/23/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCMetionTextView.h"

@interface V2TopicToolBarView : UIView

@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGPoint locationStart;
@property (nonatomic, assign) CGPoint locationChanged;

@property (nonatomic, assign, getter = isCreate) BOOL create;
@property (nonatomic, readonly) BOOL isShowing;

@property (nonatomic, strong) UIImage *blurredBackgroundImage;

@property (nonatomic, copy, readonly) NSString *replyContentString;
@property (nonatomic, assign, readonly, getter = isContentEmpty) BOOL contentEmpty;
@property (nonatomic, copy) void (^contentIsEmptyBlock)(BOOL isEmpty);

@property (nonatomic, copy) void (^insertImageBlock)();

- (void)setLocationEnd:(CGPoint)locationEnd velocity:(CGPoint)velocity;

- (void)showReplyViewWithQuotes:(NSArray *)quotes animated:(BOOL)animated;

- (void)addImageWithURL:(NSURL *)url;

- (void)clearTextView;

- (void)popToolBar;

@end

static NSString *const kShowReplyTextViewNotification = @"kShowReplyTextViewNotification";
static NSString *const kHideReplyTextViewNotification = @"kHideReplyTextViewNotification";
static NSString *const kReplySuccessNotification = @"kReplySuccessNotification";
static NSString *const kTakeScreenShootNotification = @"kTakeScreenShootNotification";