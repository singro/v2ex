//
//  V2ProfileCell.h
//  v2ex-iOS
//
//  Created by Singro on 5/4/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, V2ProfileCellType) {
    V2ProfileCellTypeTopic,
    V2ProfileCellTypeReply,
    V2ProfileCellTypeTwitter,
    V2ProfileCellTypeLocation,
    V2ProfileCellTypeWebsite
};

static NSString *const kProfileType = @"profileType";
static NSString *const kProfileValue = @"profileValue";

@interface V2ProfileCell : UITableViewCell

@property (nonatomic, assign) V2ProfileCellType type;
@property (nonatomic, copy) NSString *title;

//@property (nonatomic, copy) NSDictionary *model;

@property (nonatomic, assign) BOOL isTop;
@property (nonatomic, assign) BOOL isBottom;

+ (CGFloat)getCellHeight;

@end


