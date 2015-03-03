//
//  V2SettingWeiboCell.m
//  v2ex-iOS
//
//  Created by Singro on 7/11/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2SettingWeiboCell.h"

@interface V2SettingWeiboCell ()

@property (nonatomic, strong) UILabel *descriptionLabel;

@end

@implementation V2SettingWeiboCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = kBackgroundColorWhite;
        
        self.descriptionLabel = [UILabel new];
        self.descriptionLabel.font = [UIFont systemFontOfSize:15.0f];
        self.descriptionLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.descriptionLabel];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.descriptionLabel.frame = (CGRect){kScreenWidth - 15 - 150, 0, 150, self.height};
    [self configureLabel];
    
}

- (void)configureLabel {
    
    NSString *isCheckInString = @"";
    if ([SCWeiboManager manager].isExpired) {
        isCheckInString = @"未绑定";
        self.descriptionLabel.textColor = kFontColorBlackDark;
    } else {
        isCheckInString = @"已绑定";
        self.descriptionLabel.textColor = kFontColorBlackLight;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    self.descriptionLabel.text = [NSString stringWithFormat:@"%@", isCheckInString];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}
@end
