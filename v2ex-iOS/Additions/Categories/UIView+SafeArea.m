//
//  UIView+SafeArea.m
//  v2ex-dev
//
//  Created by Singro on 02/12/2017.
//  Copyright © 2017 Singro. All rights reserved.
//

#import "UIView+SafeArea.h"

@implementation UIView (SafeArea)

+ (CGFloat)sc_statusBarHeight
{
    if (@available(iOS 11.0, *)) {
        return UIApplication.sharedApplication.keyWindow.safeAreaInsets.top;
    }
    return 20;
}

+ (CGFloat)sc_navigationBarHeighExcludeStatusBar
{
    return 44;
}

+ (CGFloat)sc_navigationBarHeight
{
    return self.sc_statusBarHeight + self.sc_navigationBarHeighExcludeStatusBar;
}

+ (CGFloat)sc_bottomInset
{
    if (@available(iOS 11.0, *)) {
        return UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    }
    return 0;
}

@end
