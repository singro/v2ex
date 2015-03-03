//
//  V2TopicToolBarItemView.h
//  v2ex-iOS
//
//  Created by Singro on 3/23/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2TopicToolBarItemView : UIView

@property (nonatomic, copy  ) NSString           *itemTitle;
@property (nonatomic, strong) UIImage            *itemImage;
@property (nonatomic, copy  ) void (^buttonPressedBlock)();

@property (nonatomic, copy) UIColor *backgroundColorNormal;
@property (nonatomic, copy) UIColor *backgroundColorHighlighted;

@end
