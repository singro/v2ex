//
//  CAAnimation+Blocks.h
//  CAAnimationBlocks
//
//  Created by xissburg on 7/7/11.
//  Copyright 2011 xissburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (BlocksAddition)

@property (nonatomic, copy) void (^completion)(BOOL finished, CALayer *layer);
@property (nonatomic, copy) void (^start)(void);

- (void)setCompletion:(void (^)(BOOL finished, CALayer *layer))completion; // Forces auto-complete of setCompletion: to add the name 'finished' in the block parameter

@end
