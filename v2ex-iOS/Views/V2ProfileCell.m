//
//  V2ProfileCell.m
//  v2ex-iOS
//
//  Created by Singro on 5/4/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2ProfileCell.h"

@interface V2ProfileCell ()

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *rightMoreImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *topBorderLineView;
@property (nonatomic, strong) UIView *bottomBorderLineView;

@end

@implementation V2ProfileCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.clipsToBounds = YES;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.isTop = NO;
        self.isBottom = NO;
        
        self.leftImageView = [UIImageView new];
        [self addSubview:self.leftImageView];
        
        self.rightMoreImageView = [UIImageView new];
        self.rightMoreImageView.image = [UIImage imageNamed:@"Arrow"];
        [self addSubview:self.rightMoreImageView];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.titleLabel];
        
        self.topBorderLineView = [UIView new];
        [self addSubview:self.topBorderLineView];
        
        self.bottomBorderLineView = [UIView new];
        [self addSubview:self.bottomBorderLineView];

//        // test
//        self.titleLabel.backgroundColor = [UIColor redColor];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    UIColor *backbroundColor = kBackgroundColorWhite;
    if (selected) {
        
        backbroundColor = kCellHighlightedColor;
        self.backgroundColor = backbroundColor;
        
    } else {
        
        [UIView animateWithDuration:0.5 animations:^{
            self.backgroundColor = backbroundColor;
        }];
        
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    UIColor *backbroundColor = kBackgroundColorWhite;
    if (highlighted) {
        backbroundColor = kCellHighlightedColor;
    }
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor = backbroundColor;
    }];
    
}

- (void)setType:(V2ProfileCellType)type {
    _type = type;
    
    switch (type) {
        case V2ProfileCellTypeTopic:
            self.leftImageView.image = [UIImage imageNamed:@"profile_topic"];
            break;
        case V2ProfileCellTypeReply:
            self.leftImageView.image = [UIImage imageNamed:@"profile_reply"];
            break;
        case V2ProfileCellTypeTwitter:
            self.leftImageView.image = [UIImage imageNamed:@"profile_twitter"];
            break;
        case V2ProfileCellTypeLocation:
            self.leftImageView.image = [UIImage imageNamed:@"profile_location"];
            break;
        case V2ProfileCellTypeWebsite:
            self.leftImageView.image = [UIImage imageNamed:@"profile_link"];
            break;
        default:
            break;
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor = kBackgroundColorWhite;
    self.titleLabel.textColor = kFontColorBlackDark;
    self.topBorderLineView.backgroundColor = kLineColorBlackLight;
    self.bottomBorderLineView.backgroundColor = kLineColorBlackDark;

    self.leftImageView.image = self.leftImageView.image.imageForCurrentTheme;
    self.rightMoreImageView.image = self.rightMoreImageView.image.imageForCurrentTheme;
    if (self.type == V2ProfileCellTypeReply || self.type == V2ProfileCellTypeTopic) {
    } else {
        self.leftImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    }
    
    self.leftImageView.frame = (CGRect){15, 13, 18, 18};
    self.rightMoreImageView.frame = (CGRect){kScreenWidth - 20, (44-10.5)/2.0, 5.5, 10.5};
    
    self.titleLabel.frame = (CGRect){40, 0, kScreenWidth - 80, 44};
    
    self.topBorderLineView.hidden = NO;
    self.bottomBorderLineView.hidden = YES;

    self.topBorderLineView.frame = (CGRect){40, 0, kScreenWidth, 0.5};
    self.bottomBorderLineView.frame = (CGRect){0, CGRectGetHeight(self.frame) - 0.5, kScreenWidth, 0.5};
    
    if (self.isTop) {
        self.topBorderLineView.hidden = YES;
        self.bottomBorderLineView.hidden = NO;
        self.topBorderLineView.frame = (CGRect){0, 0, kScreenWidth, 0.5};
        self.bottomBorderLineView.frame = (CGRect){0, 0, kScreenWidth, 0.5};
    }
    
    if (self.isBottom) {
        self.bottomBorderLineView.hidden = NO;
        self.topBorderLineView.frame = (CGRect){40, 0, kScreenWidth, 0.5};
        self.bottomBorderLineView.frame = (CGRect){0, CGRectGetHeight(self.frame) - 0.5, kScreenWidth, 0.5};
    }
    
    if (self.isTop && self.isBottom) {
        self.topBorderLineView.hidden = NO;
        self.bottomBorderLineView.hidden = NO;
        self.topBorderLineView.backgroundColor = kLineColorBlackDark;
        self.topBorderLineView.frame = (CGRect){0, 0, kScreenWidth, 0.5};
        self.bottomBorderLineView.frame = (CGRect){0, CGRectGetHeight(self.frame) - 0.5, kScreenWidth, 0.5};
    }
    
    self.rightMoreImageView.hidden = NO;
    if (self.type == V2ProfileCellTypeLocation) {
        self.rightMoreImageView.hidden = YES;
    }
    
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    if (title) {
        self.titleLabel.text = title;
    } else {
        self.titleLabel.text = @"-";
    }
    
}


#pragma mark - Class Methods

+ (CGFloat)getCellHeight {
    return 44.0;
}


@end
