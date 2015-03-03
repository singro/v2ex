//
//  SCImageUploader.m
//  v2ex-iOS
//
//  Created by Singro on 8/6/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCImageUploader.h"

static const CGFloat kImageHeight = 90;

@interface SCImageUploader ()

@property (nonatomic, strong) UIView *containView;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIImageView             *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIButton                *cancelButton;

@property (nonatomic, strong) UIImage                 *uploadImage;

@end

@implementation SCImageUploader

- (instancetype)initWithImage:(UIImage *)image compelete:(void (^)(NSURL *url, BOOL finished))block {
    
    self = [super init];
    if (self) {
        
        [self configureViews];
        [self layoutViews];
        
        self.imageView.image = image;
        [self.activityIndicatorView startAnimating];
        
        self.uploadImage = image;
        
        // handle
        @weakify(self);
        [self.cancelButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            
            if (block) {
                block(nil, NO);
            }
            
            [self sc_hide:YES];
            
        } forControlEvents:UIControlEventTouchUpInside];
        
        [[SCWeiboManager manager] uploadImage:self.uploadImage Success:^(NSURL *url) {
            @strongify(self);
            
            if (block && url) {
                block(url, YES);
            } else {
                if (block) {
                    block(nil, NO);
                }
            }
            
            [self sc_hide:YES];
            
        } failure:^(NSError *error) {
            ;
        }];

    }
    return self;

}

- (void)configureViews {
    
    self.containView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.containView.alpha = 0.0;
    self.containView.userInteractionEnabled = NO;
    
    
    self.backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundView.backgroundColor = kFontColorBlackDark;
    self.backgroundView.alpha = 0.3;
    [self.containView addSubview:self.backgroundView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, kImageHeight}];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.containView addSubview:self.imageView];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.containView addSubview:self.activityIndicatorView];
    
    self.cancelButton = [[UIButton alloc] initWithFrame:(CGRect){0, 0, 100, 36}];
    self.cancelButton.backgroundColor = kFontColorBlackDark;
    self.cancelButton.alpha = 0.3;
    self.cancelButton.layer.cornerRadius = 3;
    self.cancelButton.clipsToBounds = YES;
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:kBackgroundColorWhite forState:UIControlStateNormal];
    [self.containView addSubview:self.cancelButton];

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    [window addSubview:self.containView];
    
}

- (void)layoutViews {
    
    self.activityIndicatorView.centerY = kScreenHeight / 2;
    self.imageView.y = self.activityIndicatorView.centerY - kImageHeight - 40;
    self.cancelButton.centerX = 160;
    self.activityIndicatorView.centerX = 160;
    self.cancelButton.y = self.activityIndicatorView.centerY + 40;
    
}

#pragma mark - Public Methods

- (void)sc_show:(BOOL)animated {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.containView.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.containView.userInteractionEnabled = YES;
    }];
    
}

- (void)sc_hide:(BOOL)animated {
    
    self.containView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.containView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.containView removeFromSuperview];
    }];
    
}


+ (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    //    int kMaxResolution = 640;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    //    if (width > kMaxResolution || height > kMaxResolution) {
    //        CGFloat ratio = width/height;
    //        if (ratio > 1) {
    //            bounds.size.width = kMaxResolution;
    //            bounds.size.height = bounds.size.width / ratio;
    //        }
    //        else {
    //            bounds.size.height = kMaxResolution;
    //            bounds.size.width = bounds.size.height * ratio;
    //        }
    //    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

@end
