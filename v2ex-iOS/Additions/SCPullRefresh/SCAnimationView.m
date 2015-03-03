//
//  SCAnimationView.m
//  v2ex-iOS
//
//  Created by Singro on 4/3/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCAnimationView.h"

#import "CAAnimation+Blocks.h"

static NSString *const kInitAnimation = @"InitAnimation";
static NSString *const kGroupAnimation = @"GroupAnimation";

static NSUInteger const kBubbleCout = 5;

#define kLayerPosition ((CGPoint){arc4random() % ((NSInteger)self.width - 240) + 120, arc4random() % ((NSInteger)self.height - 30) + 15})

@interface SCAnimationView ()

//@property (nonatomic, strong) CALayer *animationLayer;

@property (nonatomic, strong) NSMutableArray *layerArray;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SCAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.backgroundColor = [UIColor whiteColor];
        self.timer = [[NSTimer alloc] init];
        [self.timer invalidate];
        
        self.layerArray = [[NSMutableArray alloc] init];

        for (int i = 0; i < kBubbleCout; i ++) {
            CALayer *animationLayer = [self createAnimationLayer];
            animationLayer.speed = 0.0;
            animationLayer.repeatCount = 1;
            animationLayer.timeOffset = 0;
            animationLayer.position = kLayerPosition;

            CAAnimationGroup *animationGroup = [self createAnimationGroup];
            animationGroup.speed = 1;
            animationGroup.repeatCount = NSIntegerMax;
            animationGroup.beginTime = i / 1.0;
            
            [animationLayer addAnimation:animationGroup forKey:kInitAnimation];
            [self.layerArray addObject:animationLayer];
        }
        
    }
    return self;
}

#pragma mark - Public Methods

- (void)setTimeOffset:(CGFloat)timeOffset {
    
    _timeOffset = timeOffset;
    
    if (!self.timer.isValid) {
//        NSLog(@"timeOffset:  %.2f", timeOffset * 2.0);
        for (int i = 0; i < self.layerArray.count; i ++) {
            CALayer *animationLayer = self.layerArray[i];
            animationLayer.timeOffset = timeOffset * 2.0;
        }
    }

}

- (void)beginRefreshing {
    
    [self beginAnimation];
    
}

- (void)endRefreshing {
    
    [self endAnimation];
    
}

#pragma mark - Private Methods

- (void)beginAnimation {
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(animateLoop) userInfo:nil repeats:YES];
    for (int i = 0; i < self.layerArray.count; i ++) {
        CALayer *animationLayer = self.layerArray[i];
        animationLayer.speed = 1.0;
//        animationLayer.repeatCount = 3;
    }
    
}

- (void)endAnimation {
    
    [self.timer invalidate];
    for (CALayer *layer in self.layerArray) {
        [layer removeAllAnimations];
    }
    
    for (int i = 0; i < kBubbleCout; i ++) {
        CALayer *animationLayer = self.layerArray[i];
        animationLayer.speed = 0.0;
        animationLayer.repeatCount = 1;
        animationLayer.timeOffset = 0;
        animationLayer.position = kLayerPosition;
        
        CAAnimationGroup *animationGroup = [self createAnimationGroup];
        animationGroup.speed = 1;
        animationGroup.repeatCount = NSIntegerMax;
        animationGroup.beginTime = i / 1.0;
        
        [animationLayer addAnimation:animationGroup forKey:kInitAnimation];
    }

    
}



- (void)animateLoop {
    static NSInteger index = 0;

    CALayer *layer = self.layerArray[index];
    CAAnimationGroup *animationGroup = [self createAnimationGroup];
    [animationGroup setValue:layer forKey:@"layer"];
    [animationGroup setCompletion:^(BOOL finished, CALayer *endLayer) {
        layer.opacity = 0.0;
        layer.position = kLayerPosition;
    }];
    
    CAAnimationGroup *initAnimation = (CAAnimationGroup *)[layer animationForKey:kInitAnimation];

    if (initAnimation) {
        [layer removeAnimationForKey:kInitAnimation];
        [layer addAnimation:animationGroup forKey:kGroupAnimation];
    }
    
    CAAnimationGroup *oldAnimation = (CAAnimationGroup *)[layer animationForKey:kGroupAnimation];
    if (!oldAnimation) {
        [layer addAnimation:animationGroup forKey:kGroupAnimation];
    }

    index = ++index >= self.layerArray.count - 1 ? 0 : index;
    
}

#pragma mark - Animations

- (CALayer *)createAnimationLayer {
    
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = (CGRect){arc4random() % ((NSInteger)self.width - 30) + 15, arc4random() % ((NSInteger)self.height - 30) + 15, 15, 15};
    layer.position = kLayerPosition;
    layer.cornerRadius = 7.5;
    layer.backgroundColor = [UIColor colorWithRed:0.333 green:0.691 blue:1.000 alpha:1.000].CGColor;
    layer.opacity = 0.0;
    [self.layer addSublayer:layer];
    
    return layer;
}

- (CAAnimationGroup *)createAnimationGroup {
    
    CAAnimation *opacityAnimation = [self createOpacityAnimationWithIndex:0];
    CAAnimation *scaleAnimation = [self createScaleAnimation];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[opacityAnimation, scaleAnimation];
    
    group.duration = 2.0;
    group.repeatCount = 1;
    group.timeOffset = 0;
    group.removedOnCompletion = YES;
    
    return group;
}

- (CAAnimation *)createOpacityAnimationWithIndex:(NSInteger)index {
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0];
    opacityAnimation.duration = 2.0f;
    opacityAnimation.repeatCount = 1;
    opacityAnimation.speed = 1.0f;
    opacityAnimation.timeOffset = 0;
    opacityAnimation.removedOnCompletion = YES;
    
    return opacityAnimation;
}

- (CAAnimation *)createScaleAnimation {
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:2];
    scaleAnimation.duration = 2.0f;
    scaleAnimation.repeatCount = 1;
    scaleAnimation.speed = 1.0f;
    scaleAnimation.timeOffset = 0;
    scaleAnimation.removedOnCompletion = YES;
    
    return scaleAnimation;
}


@end
