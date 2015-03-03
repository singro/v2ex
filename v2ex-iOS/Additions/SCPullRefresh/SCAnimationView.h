//
//  SCAnimationView.h
//  v2ex-iOS
//
//  Created by Singro on 4/3/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCAnimationView : UIView

@property (nonatomic, assign) CGFloat timeOffset;  // 0.0 ~ 1.0

- (void)beginRefreshing;
- (void)endRefreshing;

@end
