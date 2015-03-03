//
//  V2TopicTitleCell.m
//  v2ex-iOS
//
//  Created by Singro on 3/19/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2TopicTitleCell.h"

#import "V2ProfileViewController.h"

static CGFloat const kAvatarHeight = 30.0f;
static CGFloat const kTitleFontSize = 18.0f;
//static CGFloat const kTitleLabelWidth = 250.0f;
#define kTitleLabelWidth (kScreenWidth - 20)

@interface V2TopicTitleCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton    *avatarButton;
@property (nonatomic, strong) UILabel     *titleLabel;

@property (nonatomic, assign) NSInteger   titleHeight;

@end

@implementation V2TopicTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = kBackgroundColorWhite;

//        self.avatarImageView                    = [[UIImageView alloc] init];
//        self.avatarImageView.contentMode        = UIViewContentModeScaleAspectFill;
//        self.avatarImageView.layer.cornerRadius = kAvatarHeight/2.0;
//        self.avatarImageView.clipsToBounds      = YES;
//        [self addSubview:self.avatarImageView];
//
//        self.avatarButton                       = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self addSubview:self.avatarButton];

        self.titleLabel                         = [[UILabel alloc] init];
        self.titleLabel.backgroundColor         = [UIColor clearColor];
        self.titleLabel.textColor               = kFontColorBlackDark;
        self.titleLabel.font                    = [UIFont boldSystemFontOfSize:kTitleFontSize];;
        self.titleLabel.numberOfLines           = 0;
        self.titleLabel.lineBreakMode           = NSLineBreakByCharWrapping;
        [self addSubview:self.titleLabel];
        
//        // Handles
//        @weakify(self);
//        [self.avatarButton bk_addEventHandler:^(id sender) {
//            @strongify(self);
//            
//            V2ProfileViewController *profileVC = [[V2ProfileViewController alloc] init];
//            profileVC.member = self.model.topicCreator;
//            [self.navi pushViewController:profileVC animated:YES];
//            
//        } forControlEvents:UIControlEventTouchUpInside];

        // test
//        self.avatarButton.backgroundColor = [UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:0.260];
    
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarImageView.frame   = (CGRect){kScreenWidth - 10 - kAvatarHeight, 0, kAvatarHeight, kAvatarHeight};
    self.avatarButton.frame   = (CGRect){kScreenWidth - 10 - kAvatarHeight - 10, 0, kAvatarHeight + 20, kAvatarHeight + 20};
    self.titleLabel.frame        = CGRectMake(10, 15, kTitleLabelWidth, self.titleHeight);
    self.avatarImageView.centerY = self.height / 2.0;
    self.avatarButton.centerY = self.height / 2.0;
    
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;

}

- (void)setModel:(V2TopicModel *)model {
    _model = model;
    
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:model.topicCreator.memberAvatarNormal] placeholderImage:[UIImage imageNamed:@"default_avatar"] options:0];
    
    self.titleLabel.text = model.topicTitle;
    self.titleHeight = [V2Helper getTextHeightWithText:model.topicTitle Font:[UIFont systemFontOfSize:kTitleFontSize] Width:kTitleLabelWidth] + 1;
    
}


#pragma mark - Class Methods
+ (CGFloat)getCellHeightWithTopicModel:(V2TopicModel *)model {
    
    NSInteger titleHeight = [V2Helper getTextHeightWithText:model.topicTitle Font:[UIFont systemFontOfSize:kTitleFontSize] Width:kTitleLabelWidth] + 1;
    if (model.topicTitle.length > 0) {
        return titleHeight + 25;
    } else {
        return 0;
    }
}

@end
