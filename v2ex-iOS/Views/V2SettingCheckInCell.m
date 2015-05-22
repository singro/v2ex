//
//  V2SettingCheckInCell.m
//  v2ex-iOS
//
//  Created by Singro on 7/5/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2SettingCheckInCell.h"

@interface V2SettingCheckInCell ()

@property (nonatomic, strong) UILabel *checkInCountLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation V2SettingCheckInCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = kBackgroundColorWhite;
        
        self.checkInCountLabel = [UILabel new];
        self.checkInCountLabel.font = [UIFont systemFontOfSize:15.0f];
        self.checkInCountLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.checkInCountLabel];
        
        self.activityView = [[UIActivityIndicatorView alloc] init];
        self.activityView.color = kLineColorBlackDark;
        self.activityView.hidden = YES;
        [self addSubview:self.activityView];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.activityView.frame = (CGRect){kScreenWidth - 15 - 44, 0, 44, 44};
    self.checkInCountLabel.frame = (CGRect){kScreenWidth - 15 - 150, 0, 150, self.height};
    [self configureLabel];

}

- (void)configureLabel {
    
    NSString *isCheckInString = @"";
    if ([V2CheckInManager manager].isExpired) {
        isCheckInString = @" (未签到)";
        self.checkInCountLabel.textColor = kFontColorBlackDark;
    } else {
        isCheckInString = @" (已签到)";
        self.checkInCountLabel.textColor = kFontColorBlackLight;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    self.checkInCountLabel.text = [NSString stringWithFormat:@"%ld天%@", (long)[V2CheckInManager manager].checkInCount, isCheckInString];

}

- (void)beginCheckIn {
    
    self.checkInCountLabel.hidden = YES;
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
    
}

- (void)endCheckIn {
    
    [self configureLabel];
    self.checkInCountLabel.hidden = NO;
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}
@end
