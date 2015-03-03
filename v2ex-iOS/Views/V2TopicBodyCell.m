//
//  V2TopicBodyCell.m
//  v2ex-iOS
//
//  Created by Singro on 3/19/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2TopicBodyCell.h"

#import "IDMPhotoBrowser.h"
#import "V2TopicViewController.h"
#import "V2ProfileViewController.h"
#import "V2WebViewController.h"

#import "AnimatedGIFImageSerialization.h"

#import "SCQuote.h"
#import "TTTAttributedLabel.h"

#import "V2AppDelegate.h"
#import "V2RootViewController.h"

static CGFloat const kBodyFontSize = 16.0f;

#define kBodyLabelWidth (kScreenWidth - 20)

@interface V2TopicBodyCell () <TTTAttributedLabelDelegate, IDMPhotoBrowserDelegate>

@property (nonatomic, strong) TTTAttributedLabel   *bodyLabel;

@property (nonatomic, strong) UIView    *borderLineView;

@property (nonatomic, assign) NSInteger bodyHeight;

@property (nonatomic, strong) NSMutableArray *attributedLabelArray;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *imageButtonArray;
@property (nonatomic, strong) NSMutableArray *imageUrls;

@end

@implementation V2TopicBodyCell

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

        self.bodyLabel = [self createAttributedLabel];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.borderLineView.frame = (CGRect){10, self.height - 0.5, kScreenWidth - 20, 0.5};
    
    [self layoutContent];
}

- (void)setModel:(V2TopicModel *)model {
    _model = model;
    
//    [self setNeedsLayout];
}

- (void)layoutContent {
    
    
    if (!self.model.contentArray) {
        
        self.bodyLabel.attributedText = self.model.attributedString;
        
        self.bodyHeight     = [TTTAttributedLabel sizeThatFitsAttributedString:self.model.attributedString withConstraints:(CGSize){kBodyLabelWidth, 0} limitedToNumberOfLines:0].height;
        
        if (!self.bodyLabel.attributedText.length) {
            self.bodyHeight = 0;
        }
        
        self.bodyLabel.frame      = CGRectMake(10, 5, kBodyLabelWidth, self.bodyHeight);

        for (SCQuote *quote in self.model.quoteArray) {
            [self.bodyLabel addLinkToURL:[NSURL URLWithString:quote.identifier] withRange:quote.range];
        }
        
    } else {
        
        __block NSUInteger labelIndex = 0;
        __block NSUInteger imageIndex = 0;
        __block CGFloat offsetY = 10;
        
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
                
                CGFloat labelHeight = [TTTAttributedLabel sizeThatFitsAttributedString:stringModel.attributedString withConstraints:(CGSize){kBodyLabelWidth, 0} limitedToNumberOfLines:0].height;
                
                if (stringModel.attributedString.length == 0) {
                    labelHeight = 0;
                }
                label.size = (CGSize){kBodyLabelWidth, labelHeight};
                label.origin = (CGPoint){10, offsetY};
                
                for (SCQuote *quote in stringModel.quoteArray) {
                    if (stringModel.attributedString.length >= quote.range.location + quote.range.length) {
                        [label addLinkToURL:[NSURL URLWithString:quote.identifier] withRange:quote.range];
                    }
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
                imageView.origin = (CGPoint){10, offsetY};
                
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
    attributedLabel.font                 = [UIFont systemFontOfSize:kBodyFontSize];;
    attributedLabel.numberOfLines        = 0;
    attributedLabel.lineBreakMode        = NSLineBreakByWordWrapping;
    attributedLabel.delegate             = self;
    [self addSubview:attributedLabel];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8.0;
    
    attributedLabel.linkAttributes = @{
                                      NSForegroundColorAttributeName:kFontColorBlackBlue,//[UIColor colorWithRed:65.0/255.0 green:176.0/255.0 blue:235.0/255.0 alpha:1.0], //
                                      NSFontAttributeName: [UIFont systemFontOfSize:kBodyFontSize],
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

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    SCQuote *quote = [self quoteForIdentifier:url.absoluteString];
    if (quote) {
        
        if (quote.type == SCQuoteTypeUser) {
            
            V2ProfileViewController *profileVC = [[V2ProfileViewController alloc] init];
            profileVC.username = quote.identifier;
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
+ (CGFloat)getCellHeightWithTopicModel:(V2TopicModel *)model {
    
    __block NSInteger bodyHeight = 0;
    
    if (model.contentArray) {
        
        [model.contentArray enumerateObjectsUsingBlock:^(V2ContentBaseModel *contentModel, NSUInteger idx, BOOL *stop) {
            
            if (contentModel.contentType == V2ContentTypeString) {
                
                V2ContentStringModel *stringModel = (V2ContentStringModel *)contentModel;
                bodyHeight += [TTTAttributedLabel sizeThatFitsAttributedString:stringModel.attributedString withConstraints:(CGSize){kBodyLabelWidth, 0} limitedToNumberOfLines:0].height + 7;
                
            }
            
            if (contentModel.contentType == V2ContentTypeImage) {
                
                V2ContentImageModel *imageModel = (V2ContentImageModel *)contentModel;
                CGSize imageSize = [[self class] imageSizeForKey:imageModel.imageQuote.identifier];
                
                bodyHeight += (imageSize.height + 7);
                
            }
            
        }];
        
    } else {
        bodyHeight = [TTTAttributedLabel sizeThatFitsAttributedString:model.attributedString withConstraints:(CGSize){kBodyLabelWidth, 0} limitedToNumberOfLines:0].height;
    }
    
    if (!model.topicContent.length) {
        return 1;
    }
    
    return bodyHeight + 15;
    
}

+ (CGSize)imageSizeForKey:(NSString *)key {
    
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    if (!cachedImage) {
        cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    }
    if (cachedImage) {
        return [cachedImage fitWidth:kBodyLabelWidth];
    } else {
        return CGSizeMake(kBodyLabelWidth, 60);
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
