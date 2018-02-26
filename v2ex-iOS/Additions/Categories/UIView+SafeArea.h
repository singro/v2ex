//
//  UIView+SafeArea.h
//  v2ex-dev
//
//  Created by Singro on 02/12/2017.
//  Copyright © 2017 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SafeArea)

@property (class, nonatomic, readonly) CGFloat sc_statusBarHeight; // 37 for iPhone X, 20 for Others
@property (class, nonatomic, readonly) CGFloat sc_navigationBarHeighExcludeStatusBar; // 44
@property (class, nonatomic, readonly) CGFloat sc_navigationBarHeight; // status + naviExStatus
@property (class, nonatomic, readonly) CGFloat sc_bottomInset;

@end
