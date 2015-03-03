//
//  V2ProfileBioCell.h
//  v2ex-iOS
//
//  Created by Singro on 5/4/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2ProfileBioCell : UITableViewCell

@property (nonatomic, copy) NSString *bioString;

+ (CGFloat)getCellHeightWithBioString:(NSString *)bioString;

@end
