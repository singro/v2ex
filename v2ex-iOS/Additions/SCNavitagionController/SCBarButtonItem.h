//
//  SCBarButtonItem.h
//  v2ex-iOS
//
//  Created by Singro on 5/25/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SCBarButtonItemStyle) {  // for future use
    SCBarButtonItemStylePlain,
    SCBarButtonItemStyleBordered,
    SCBarButtonItemStyleDone,
};

@interface SCBarButtonItem : NSObject

@property (nonatomic, strong) UIView *view;

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;
@property (nonatomic, copy) NSString *badge;

- (instancetype)initWithTitle:(NSString *)title style:(SCBarButtonItemStyle)style handler:(void (^)(id sender))action;

- (instancetype)initWithImage:(UIImage *)image style:(SCBarButtonItemStyle)style handler:(void (^)(id sender))action;

@end
