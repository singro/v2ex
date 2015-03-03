//
//  V2SettingCell.h
//  v2ex-iOS
//
//  Created by Singro on 6/27/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2SettingCell : UITableViewCell

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign, getter = isTop) BOOL top;
@property (nonatomic, assign, getter = isBottom) BOOL bottom;

@end
