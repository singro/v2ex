//
//  V2TopicInfoCell.m
//  v2ex-iOS
//
//  Created by Singro on 3/19/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2TopicInfoCell.h"

#import "V2ProfileViewController.h"

static CGFloat const kAvatarHeight = 14.0f;

@interface V2TopicInfoCell ()

@property (nonatomic, strong) UILabel *byLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *nodeLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton    *avatarButton;

@end

@implementation V2TopicInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.clipsToBounds                = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = kBackgroundColorWhite;

//        self.byLabel                      = [[UILabel alloc] init];
//        self.byLabel.backgroundColor      = [UIColor clearColor];
//        self.byLabel.textColor            = kFontColorBlackLight;
//        self.byLabel.font                 = [UIFont systemFontOfSize:14.0];;
//        self.byLabel.textAlignment        = NSTextAlignmentLeft;
//        [self addSubview:self.byLabel];

        self.avatarImageView                    = [[UIImageView alloc] init];
        self.avatarImageView.contentMode        = UIViewContentModeScaleAspectFill;
        self.avatarImageView.layer.cornerRadius = 2; //kAvatarHeight/2.0;
        self.avatarImageView.clipsToBounds      = YES;
        self.avatarImageView.size               = CGSizeMake(kAvatarHeight, kAvatarHeight);
        self.avatarImageView.image              = [UIImage imageNamed:@"default_avatar"];
        [self addSubview:self.avatarImageView];
        
        self.avatarButton                       = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.avatarButton];

        self.nameLabel                    = [[UILabel alloc] init];
        self.nameLabel.backgroundColor    = [UIColor clearColor];
        self.nameLabel.textColor          = kFontColorBlackBlue;
        self.nameLabel.font               = [UIFont boldSystemFontOfSize:15.0];
        self.nameLabel.textAlignment      = NSTextAlignmentLeft;
        self.nameLabel.layer.cornerRadius = 3.0;
        self.nameLabel.clipsToBounds      = YES;
        [self addSubview:self.nameLabel];

        self.timeLabel                    = [[UILabel alloc] init];
        self.timeLabel.backgroundColor    = [UIColor clearColor];
        self.timeLabel.textColor          = kFontColorBlackLight;
        self.timeLabel.font               = [UIFont systemFontOfSize:14.0];;
        self.timeLabel.textAlignment      = NSTextAlignmentRight;
        [self addSubview:self.timeLabel];
        
//        self.nodeLabel = [[UILabel alloc] init];
//        self.nodeLabel.backgroundColor = [UIColor clearColor];
//        self.nodeLabel.textColor = kFontColorBlackLight;
//        self.nodeLabel.font = [UIFont systemFontOfSize:11.0f];
//        self.nodeLabel.textAlignment = NSTextAlignmentRight;
//        self.nodeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//        self.nodeLabel.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.040];
//        self.nodeLabel.layer.cornerRadius = 3.0;
//        self.nodeLabel.clipsToBounds = YES;
//        [self addSubview:self.nodeLabel];
        
        // Handles
        @weakify(self);
        [self.avatarButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            
            V2ProfileViewController *profileVC = [[V2ProfileViewController alloc] init];
            profileVC.member = self.model.topicCreator;
            [self.navi pushViewController:profileVC animated:YES];
            
        } forControlEvents:UIControlEventTouchUpInside];

        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    self.nodeLabel.origin = CGPointMake(310 - self.nodeLabel.width, self.height - 19);
    self.timeLabel.x       = kScreenWidth - 10 - self.timeLabel.width;
    self.timeLabel.centerY = self.height / 2;
    self.avatarImageView.x         = 10;
    self.avatarImageView.centerY   = self.height / 2;
//    self.byLabel.x         = 10;
//    self.byLabel.centerY   = self.height / 2;
    self.nameLabel.x       = 10 + self.avatarImageView.width + 7;
    self.nameLabel.centerY = self.height / 2;
    
    self.avatarButton.frame = (CGRect){0, 0, self.nameLabel.x + self.nameLabel.width + 10, self.height};
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;

}

- (void)setModel:(V2TopicModel *)model {
    _model = model;
    
    self.byLabel.text = @"by ";
    [self.byLabel sizeToFit];
    
    NSString *timeLabelString = @"";
    NSInteger replyCount = [self.model.topicReplyCount integerValue];
    if (replyCount == 1) {
        timeLabelString = [NSString stringWithFormat:@"%@ 回复", model.topicReplyCount];
    }
    if (replyCount > 1) {
        timeLabelString = [NSString stringWithFormat:@"%@ 回复", model.topicReplyCount];
    }
    if (model.topicCreated) {
        NSString *labelString = [V2Helper timeRemainDescriptionWithDateSP:model.topicCreated];
        if (replyCount > 0) {
            labelString = [labelString stringByAppendingString:@", "];
        }
        labelString = [labelString stringByAppendingString:timeLabelString];
        timeLabelString = labelString;
    } else {
//        timeLabelString = [timeLabelString stringByAppendingString:model.topicCreatedDescription];
    }
    
    self.timeLabel.text = timeLabelString;
    [self.timeLabel sizeToFit];
    
    self.nameLabel.text = model.topicCreator.memberName;
    [self.nameLabel sizeToFit];
    
    self.nodeLabel.text = model.topicNode.nodeTitle;
    [self.nodeLabel sizeToFit];
    
//    [self.avatarImageView setImageWithURL:[NSURL URLWithString:model.topicCreator.memberAvatarNormal] placeholderImage:[UIImage imageNamed:@"default_avatar"] options:0];
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:model.topicCreator.memberAvatarNormal] completed:nil];
//    [self.avatarImageView setImageWithURL:[NSURL URLWithString:model.topicCreator.memberAvatarNormal]];

}

#pragma mark - Class Methods
+ (CGFloat)getCellHeightWithTopicModel:(V2TopicModel *)model {
    if (model.topicTitle.length > 0) {
        return 28;
    } else {
        return 0;
    }
}

@end
