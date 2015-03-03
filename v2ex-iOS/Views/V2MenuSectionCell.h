//
//  V2MenuSectionCell.h
//  v2ex-iOS
//
//  Created by Singro on 3/30/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2MenuSectionCell : UITableViewCell

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *badge;

+ (CGFloat)getCellHeight;

@end
