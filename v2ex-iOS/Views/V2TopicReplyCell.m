//
//  V2TopicReplyCell.m
//  v2ex-iOS
//
//  Created by Singro on 3/20/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2TopicReplyCell.h"

#import "V2ProfileViewController.h"
#import "IDMPhotoBrowser.h"
#import "V2TopicViewController.h"
#import "V2WebViewController.h"

#import "TTTAttributedLabel.h"
#import "SCQuote.h"
#import "UIImage+Cache.h"

#import "V2AppDelegate.h"
#import "V2RootViewController.h"

static CGFloat const kAvatarHeight = 30.0f;
static CGFloat const kNameFontSize = 15.0f;
static CGFloat const kContentFontSize = 15.0f;
#define kNameLabelWidth (kScreenWidth - 76)
#define kContentLabelWidth (kScreenWidth - 60)

@interface V2TopicReplyCell () <TTTAttributedLabelDelegate, IDMPhotoBrowserDelegate>

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton    *avatarButton;
@property (nonatomic, strong) TTTAttributedLabel     *contentLabel;

@property (nonatomic, strong) NSMutableArray *attributedLabelArray;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *imageButtonArray;
@property (nonatomic, strong) NSMutableArray *imageUrls;

@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UILabel     *timeLabel;

@property (nonatomic, strong) UIView      *borderLineView;

@property (nonatomic, assign) NSInteger   titleHeight;
@property (nonatomic, assign) NSInteger   descriptionHeight;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;

@property (nonatomic, strong) UIColor *highlightedColorLightBlue;
@property (nonatomic, strong) UIColor *highlightedColorLightBlack;

@end

@implementation V2TopicReplyCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.backgroundColor = kBackgroundColorWhite;

        self.attributedLabelArray = [[NSMutableArray alloc] init];
        self.imageArray = [[NSMutableArray alloc] init];
        self.imageButtonArray = [[NSMutableArray alloc] init];
        self.imageUrls = [[NSMutableArray alloc] init];

        self.avatarImageView                    = [[UIImageView alloc] init];
        self.avatarImageView.contentMode        = UIViewContentModeScaleAspectFill;
//        self.avatarImageView.layer.cornerRadius = 3;//kAvatarHeight/2.0;
//        self.avatarImageView.clipsToBounds      = YES;
        [self addSubview:self.avatarImageView];

        self.avatarButton                       = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.avatarButton];

        self.nameLabel                          = [[UILabel alloc] init];
        self.nameLabel.backgroundColor          = [UIColor clearColor];
        self.nameLabel.textColor                = kFontColorBlackDark;
        self.nameLabel.font                     = [UIFont boldSystemFontOfSize:kNameFontSize];;
//        self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail|NSLineBreakByCharWrapping;
        [self addSubview:self.nameLabel];

        self.contentLabel  = [self createAttributedLabel];

        self.timeLabel                          = [[UILabel alloc] init];
        self.timeLabel.backgroundColor          = [UIColor clearColor];
        self.timeLabel.textColor                = kFontColorBlackLight;
//        self.timeLabel.font                     = [UIFont systemFontOfSize:12.0];;
        self.timeLabel.font                     = [UIFont systemFontOfSize:13];;
        self.timeLabel.textAlignment            = NSTextAlignmentRight;
        self.timeLabel.alpha = 0.6;
        [self addSubview:self.timeLabel];

        self.highlightedColorLightBlue = [UIColor colorWithRed:0.055 green:0.597 blue:1.000 alpha:0.015];
        self.highlightedColorLightBlack = [UIColor colorWithRed:0.102 green:0.665 blue:0.971 alpha:0.080];
        
//        self.borderLineView                     = [[UIView alloc] init];
//        self.borderLineView.backgroundColor     = kLineColorBlackDark;
//        [self addSubview:self.borderLineView];
        
        // Handles
        @weakify(self);
        [self.avatarButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            
            V2ProfileViewController *profileVC = [[V2ProfileViewController alloc] init];
            profileVC.member = self.model.replyCreator;
            [self.navi pushViewController:profileVC animated:YES];
            
        } forControlEvents:UIControlEventTouchUpInside];
        
        // Gesture
//        self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
//            @strongify(self);
//            
//            [[UIPasteboard generalPasteboard] setString:[self.contentLabel.attributedText string]];
//
//            if (self.longPressedBlock) {
//                self.longPressedBlock();
//            }
//            
//        }];
//        
//        [self addGestureRecognizer:self.longPressRecognizer];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSelectMemberNotification:) name:kSelectMemberNotification object:nil];
        
        // test
//        self.avatarButton.backgroundColor = [UIColor colorWithRed:1.000 green:1.000 blue:0.000 alpha:0.310];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarImageView.frame = (CGRect){10, 12, kAvatarHeight, kAvatarHeight};
    self.avatarButton.frame = (CGRect){0, 0, kAvatarHeight + 15, kAvatarHeight + 20};

    self.nameLabel.origin      = CGPointMake(50, 10);
    self.contentLabel.frame    = CGRectMake(50, 8 + self.titleHeight + 8, kContentLabelWidth, self.descriptionHeight);

//    self.timeLabel.origin      = CGPointMake(305 - self.timeLabel.width, self.nameLabel.y);
    self.timeLabel.origin      = CGPointMake(self.nameLabel.x + self.nameLabel.width + 8, self.nameLabel.y + 2);

//    self.borderLineView.frame  = CGRectMake(50, self.height-0.5, 260, 0.5);
    self.borderLineView.frame  = CGRectMake(0, self.height-0.5, kScreenWidth, 0.5);
    
    if ([self.model.replyCreator.memberName isEqualToString:self.selectedReplyModel.replyCreator.memberName]) {
        self.backgroundColor = self.highlightedColorLightBlack;
    } else {
        self.backgroundColor = kBackgroundColorWhite;
    }
    
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    
    @weakify(self);
    if (self.model.contentArray) {
        [self.imageArray enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop) {
            @strongify(self);
            if (idx < self.model.imageURLs.count) {
                imageView.hidden = NO;
            } else {
                imageView.hidden = YES;
            }
        }];
        [self.imageButtonArray enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
            @strongify(self);
            if (idx < self.model.imageURLs.count) {
                button.hidden = NO;
            } else {
                button.hidden = YES;
            }
        }];
        [self.attributedLabelArray enumerateObjectsUsingBlock:^(TTTAttributedLabel *label, NSUInteger idx, BOOL *stop) {
//            if (idx < self.model.imageURLs.count) {
                label.hidden = NO;
//            } else {
//                label.hidden = YES;
//            }
        }];
        
        [self layoutContent];
    }
    
    
//    if ([self.model isEqual:self.replyList.list.lastObject]) {
//        self.borderLineView.hidden = NO;
//    } else {
//        self.borderLineView.hidden = YES;
//    }
    
}

- (void)setModel:(V2ReplyModel *)model {
    _model = model;
    
    @weakify(self);
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:model.replyCreator.memberAvatarNormal] placeholderImage:[UIImage imageNamed:@"default_avatar"] options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        @strongify(self);
        if (!image.cached) {
            
            UIImage *cornerRadiusImage = [image imageWithCornerRadius:3];
            cornerRadiusImage.cached = YES;
            
            [[SDWebImageManager sharedManager].imageCache storeImage:cornerRadiusImage
                                                              forKey:model.replyCreator.memberAvatarNormal];
            self.avatarImageView.image = cornerRadiusImage;
        }
        
    }];


    self.nameLabel.text    = model.replyCreator.memberName;

    self.timeLabel.text    = [V2Helper timeRemainDescriptionWithDateSP:model.replyCreated];
    [self.timeLabel sizeToFit];

    self.nameLabel.text    = model.replyCreator.memberName;
    [self.nameLabel sizeToFit];

    self.titleHeight       = [V2Helper getTextHeightWithText:model.replyCreator.memberName Font:[UIFont systemFontOfSize:kNameFontSize] Width:kNameLabelWidth] + 1;

    if (!model.contentArray) {

        self.descriptionHeight = [TTTAttributedLabel sizeThatFitsAttributedString:model.attributedString withConstraints:(CGSize){kContentLabelWidth, 0} limitedToNumberOfLines:0].height;
        
        self.contentLabel.text = model.attributedString;

        for (SCQuote *quote in model.quoteArray) {
            [self.contentLabel addLinkToURL:[NSURL URLWithString:quote.identifier] withRange:quote.range];
        }
        
    } else {
        
        
    }
}

- (void)layoutContent {
    
    
    __block NSUInteger labelIndex = 0;
    __block NSUInteger imageIndex = 0;
    __block CGFloat offsetY = 8 + self.titleHeight + 8;
    
    @weakify(self);
    [self.model.contentArray enumerateObjectsUsingBlock:^(V2ContentBaseModel *baseModel, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        
        if (baseModel.contentType == V2ContentTypeString) {
            V2ContentStringModel *stringModel = (V2ContentStringModel *)baseModel;
            
            TTTAttributedLabel *label;
            
            if (self.attributedLabelArray.count <= labelIndex) {
                label = [self createAttributedLabel];
            } else {
                label = self.attributedLabelArray[labelIndex];
            }
            
            label.attributedText = stringModel.attributedString;
            
            CGFloat labelHeight = [TTTAttributedLabel sizeThatFitsAttributedString:stringModel.attributedString withConstraints:(CGSize){kContentLabelWidth, 0} limitedToNumberOfLines:0].height;
            
            if (stringModel.attributedString.length == 0) {
                labelHeight = 0;
            }
            label.size = (CGSize){kContentLabelWidth, labelHeight};
            label.origin = (CGPoint){50, offsetY};
            
            for (SCQuote *quote in stringModel.quoteArray) {
                [label addLinkToURL:[NSURL URLWithString:quote.identifier] withRange:quote.range];
            }
            
            labelIndex ++;
            offsetY += (label.height + 7);
        }
        
        if (baseModel.contentType == V2ContentTypeImage) {
            V2ContentImageModel *imageModel = (V2ContentImageModel *)baseModel;
            
            UIImageView *imageView;
            if (self.imageArray.count <= imageIndex) {
                imageView = [self createImageView];
            } else {
                imageView = self.imageArray[imageIndex];
            }
            
            CGSize imageSize = [[self class] imageSizeForKey:imageModel.imageQuote.identifier];
            imageView.size = imageSize;
            imageView.origin = (CGPoint){50, offsetY};
            
            UIImage *cachedImage = [[self class] imageForKey:imageModel.imageQuote.identifier];
            if (cachedImage) {
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.image = cachedImage;
                imageView.backgroundColor = [UIColor clearColor];
            } else {
                
                imageView.backgroundColor = kBackgroundColorWhiteDark;
                imageView.contentMode = UIViewContentModeCenter;
                imageView.image = [UIImage imageNamed:@"topic_placeholder"];
                [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:imageModel.imageQuote.identifier] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                    @strongify(self);
                    
                    if (cacheType == SDImageCacheTypeNone && self.reloadCellBlock && finished) {
                        imageView.image = nil;
                        self.reloadCellBlock();
                    } else {
                    }
                    
                }];
                
            }
            
            offsetY += (imageView.height + 7);
            
            UIButton *button = self.imageButtonArray[imageIndex];
            button.frame = imageView.frame;
            
            NSUInteger imageIndexNoneBlock = imageIndex;
            
            [button bk_removeAllBlockObservers];
            [button bk_whenTapped:^{
                @strongify(self);
                
                NSArray *photos = [IDMPhoto photosWithURLs:self.model.imageURLs];
                
                IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos animatedFromView:imageView];
                browser.delegate = self;
                browser.displayActionButton = NO;
                browser.displayArrowButton = NO;
                browser.displayCounterLabel = YES;
                [browser setInitialPageIndex:imageIndexNoneBlock];
                
                [[AppDelegate rootViewController] presentViewController:browser animated:YES completion:nil];
                
                
            }];
            
            imageIndex ++;
            
        }
    }];
    
}

#pragma mark - View Creator

- (UIImageView *)createImageView {
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = kBackgroundColorWhiteDark;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.clipsToBounds = YES;
    [self addSubview:imageView];
    
    UIButton *button = [[UIButton alloc] init];
    [self addSubview:button];
    
    [self.imageButtonArray addObject:button];
    [self.imageArray addObject:imageView];
    
    return imageView;
}

- (TTTAttributedLabel *)createAttributedLabel {
    
    TTTAttributedLabel *attributedLabel = [[TTTAttributedLabel alloc] init];
    attributedLabel.backgroundColor      = [UIColor clearColor];
    attributedLabel.textColor            = kFontColorBlackDark;
    attributedLabel.font                 = [UIFont systemFontOfSize:kContentFontSize];;
    attributedLabel.numberOfLines        = 0;
    attributedLabel.lineBreakMode        = NSLineBreakByWordWrapping;
    attributedLabel.delegate             = self;
    [self addSubview:attributedLabel];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    
    attributedLabel.linkAttributes = @{
                                         NSForegroundColorAttributeName:kFontColorBlackBlue, //[UIColor colorWithRed:65.0/255.0 green:176.0/255.0 blue:235.0/255.0 alpha:1.0], //
                                         NSFontAttributeName: [UIFont systemFontOfSize:kContentFontSize],
                                         NSParagraphStyleAttributeName: style
                                         };
    
    attributedLabel.activeLinkAttributes = @{
                                               (NSString *)kCTUnderlineStyleAttributeName: [NSNumber numberWithBool:NO],
                                               NSForegroundColorAttributeName: kBackgroundColorWhite,
                                               (NSString *)kTTTBackgroundFillColorAttributeName: (__bridge id)[kColorBlue CGColor],
                                               (NSString *)kTTTBackgroundCornerRadiusAttributeName:[NSNumber numberWithFloat:4.0f]
                                               };

    
    [self.attributedLabelArray addObject:attributedLabel];
    
    return attributedLabel;
}


#pragma mark - Notifications

- (void)didReceiveSelectMemberNotification:(NSNotification *)notification {
    
    self.selectedReplyModel = notification.object;
    [self setNeedsLayout];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    SCQuote *quote = [self quoteForIdentifier:url.absoluteString];
    self.longPressRecognizer.enabled = NO;
    if (quote) {
        
        if (quote.type == SCQuoteTypeUser) {
            
            V2ReplyModel *replyModel;
            for (V2ReplyModel *model in self.replyList.list) {
                if ([model.replyCreator.memberName isEqualToString:quote.identifier]) {
                    replyModel = model;
                    break;
                }
            }
            
            V2ProfileViewController *profileVC = [[V2ProfileViewController alloc] init];
            
            if (replyModel) {
                profileVC.member = replyModel.replyCreator;
            } else {
                profileVC.username = quote.identifier;
            }
            
            [self.navi pushViewController:profileVC animated:YES];
            
        }
        
        if (quote.type == SCQuoteTypeImage) {
            
            IDMPhoto *photo = [IDMPhoto photoWithURL:url];
            
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo] animatedFromView:nil];
            browser.delegate = self;
            browser.displayActionButton = NO;
            browser.displayArrowButton = YES;
            browser.displayCounterLabel = YES;
            
            [[AppDelegate rootViewController] presentViewController:browser animated:YES completion:nil];

        }
        
        if (quote.type == SCQuoteTypeTopic) {
            
            V2TopicViewController *topicVC = [[V2TopicViewController alloc] init];
            V2TopicModel *topicModel = [[V2TopicModel alloc] init];
            topicModel.topicId = quote.identifier;
            topicVC.model = topicModel;
            [self.navi pushViewController:topicVC animated:YES];
            
        }
        
        if (quote.type == SCQuoteTypeAppStore) {
            
            NSURL *URL = [NSURL URLWithString:quote.identifier];
            
            if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                [[UIApplication sharedApplication] openURL:URL];
            }
            
        }
        
        if (quote.type == SCQuoteTypeEmail) {
            
            NSString *urlString = [NSString stringWithFormat:@"mailto:%@", quote.identifier];
            
            NSURL *URL = [NSURL URLWithString:urlString];
            
            if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                [[UIApplication sharedApplication] openURL:URL];
            }
            
        }
        
        if (quote.type == SCQuoteTypeLink) {
            
            NSURL *URL = [NSURL URLWithString:quote.identifier];
            
            V2WebViewController *webVC = [[V2WebViewController alloc] init];
            webVC.url = URL;
            [self.navi pushViewController:webVC animated:YES];
            
        }

    }
    
}

- (SCQuote *)quoteForIdentifier:(NSString *)identifier {
    for (SCQuote *quote in self.model.quoteArray) {
        if ([quote.identifier isEqualToString:identifier]) {
            return quote;
        }
    }
    return nil;
}

#pragma mark - Class Methods
+ (CGFloat)getCellHeightWithReplyModel:(V2ReplyModel *)model {

    NSInteger titleHeight       = [V2Helper getTextHeightWithText:model.replyCreator.memberName Font:[UIFont systemFontOfSize:kNameFontSize] Width:kNameLabelWidth] + 1;

    __block NSInteger bodyHeight = 0;
    
    if (model.contentArray) {
        
        [model.contentArray enumerateObjectsUsingBlock:^(V2ContentBaseModel *contentModel, NSUInteger idx, BOOL *stop) {
            
            if (contentModel.contentType == V2ContentTypeString) {
                
                V2ContentStringModel *stringModel = (V2ContentStringModel *)contentModel;
                bodyHeight += [TTTAttributedLabel sizeThatFitsAttributedString:stringModel.attributedString withConstraints:(CGSize){kContentLabelWidth, 0} limitedToNumberOfLines:0].height + 7;
                
            }
            
            if (contentModel.contentType == V2ContentTypeImage) {
                
                V2ContentImageModel *imageModel = (V2ContentImageModel *)contentModel;
                CGSize imageSize = [[self class] imageSizeForKey:imageModel.imageQuote.identifier];
                
                bodyHeight += (imageSize.height + 7);
                
            }
            
        }];
        
    } else {
        bodyHeight = [TTTAttributedLabel sizeThatFitsAttributedString:model.attributedString withConstraints:(CGSize){kContentLabelWidth, 0} limitedToNumberOfLines:0].height;
        bodyHeight += 8;
    }
    
    if (!model.replyContent.length) {
        return 1;
    }
    
    CGFloat cellHeight          = 8*2 + titleHeight + bodyHeight;
    
    if (cellHeight < 60) {
        return 60;
    } else {
        return cellHeight;
    }
    
}

+ (CGSize)imageSizeForKey:(NSString *)key {
    
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    if (!cachedImage) {
        cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    }
    if (cachedImage) {
        return [cachedImage fitWidth:kContentLabelWidth];
    } else {
        return CGSizeMake(kContentLabelWidth, 60);
    }
    
}

+ (UIImage *)imageForKey:(NSString *)key {
    
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    if (!cachedImage) {
        cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    }
    
    return cachedImage;
}

@end