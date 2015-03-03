//
//  V2SettingCell.m
//  v2ex-iOS
//
//  Created by Singro on 6/27/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2SettingCell.h"

@interface V2SettingCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *topBorderLineView;
@property (nonatomic, strong) UIView *bottomBorderLineView;

@end

@implementation V2SettingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.backgroundColor = kBackgroundColorWhite;
        
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = kFontColorBlackDark;
        self.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.titleLabel];
        
        self.topBorderLineView = [UIView new];
        self.topBorderLineView.backgroundColor = kLineColorBlackDark;
        [self addSubview:self.topBorderLineView];
        
        self.bottomBorderLineView = [UIView new];
        self.bottomBorderLineView.backgroundColor = kLineColorBlackDark;
        [self addSubview:self.bottomBorderLineView];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor = kBackgroundColorWhite;
    self.titleLabel.textColor = kFontColorBlackDark;
    self.topBorderLineView.backgroundColor = kLineColorBlackDark;
    self.bottomBorderLineView.backgroundColor = kLineColorBlackDark;
    
    self.titleLabel.frame = (CGRect){15, 10, 180, 24};
    
    self.topBorderLineView.frame = (CGRect){0, 0, kScreenWidth, 0.5};
    self.bottomBorderLineView.frame = (CGRect){15, CGRectGetHeight(self.frame) - 0.5, kScreenWidth, 0.5};
    
    self.topBorderLineView.hidden = YES;
    self.bottomBorderLineView.hidden = NO;
    
    if (self.isTop) {
        self.topBorderLineView.hidden = NO;
    }
    if (self.isBottom) {
        self.bottomBorderLineView.frame = (CGRect){0, CGRectGetHeight(self.frame) - 0.5, kScreenWidth, 0.5};
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    UIColor *backbroundColor = kBackgroundColorWhite;
    if (selected) {
        
        backbroundColor = kCellHighlightedColor;
        self.backgroundColor = backbroundColor;
        
    } else {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundColor = backbroundColor;
        } completion:^(BOOL finished) {
            [self setNeedsLayout];
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

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

@end
