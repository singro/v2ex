//
//  V2NodesViewCell.m
//  v2ex-iOS
//
//  Created by Singro on 5/8/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2NodesViewCell.h"

#import "V2NodeViewController.h"

#import <objc/runtime.h>

@interface UIButton (V2NodeModel)

@property (nonatomic, strong) V2NodeModel *model;

@end

static CGFloat const kFontSize     = 16;
static CGFloat const kButtonInsert = 10;
//static CGFloat const kButtonSpace  = 5;
static CGFloat const kButtonHeight = 28;

static NSMutableDictionary *frameCacheDict;

@interface V2NodesViewCell ()

@property (nonatomic, strong) NSMutableArray *buttonArray;

@property (nonatomic, strong) UIImage *imageNormal;
@property (nonatomic, strong) UIImage *imageHighlighted;

@property (nonatomic, strong) UIView *topBorderLineView;
@property (nonatomic, strong) UIView *bottomBorderLineView;

@end

@implementation V2NodesViewCell

+ (void)load {
    if (nil == frameCacheDict) {
        frameCacheDict = [NSMutableDictionary new];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = kBackgroundColorWhite;
        
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        

        self.buttonArray = [[NSMutableArray alloc] init];
        
        self.imageNormal = [V2Helper getImageWithColor:[UIColor colorWithWhite:0.951 alpha:1.000] size:(CGSize){200, kButtonHeight}];
        self.imageHighlighted = [V2Helper getImageWithColor:kColorBlue size:(CGSize){200, kButtonHeight}];
        
//        self.topBorderLineView                    = [UIView new];
//        self.topBorderLineView.backgroundColor    = kLineColorBlackDark;
//        [self addSubview:self.topBorderLineView];
        
        self.bottomBorderLineView                 = [UIView new];
        self.bottomBorderLineView.backgroundColor = kLineColorBlackDark;
        [self.contentView addSubview:self.bottomBorderLineView];

    }
    return self;
}

- (void)prepareForReuse{
    self.nodesArray = nil;
    for (UIButton *button in self.buttonArray) {
        button.hidden = YES;
        button.selected = NO;
        [button setTitle:nil forState:UIControlStateNormal];
        if (button.superview) {
            [button removeFromSuperview];
        }
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.topBorderLineView.frame = (CGRect){0, 0, 320, 0.5};
    self.bottomBorderLineView.frame = (CGRect){0, CGRectGetHeight(self.frame) - 0.5, kScreenWidth, 0.5};

}

- (void)layoutButtons {
    
    CGFloat originX = 10;
    CGFloat originY = 10;
    
    /* 把frame保存起来的想法很好，但行不通，一旦某node在nodesArray的位置发生改变，则布局就乱套了 */
    for (int i = 0; i < self.nodesArray.count; i ++) {
        UIButton *button = self.buttonArray[i];
        
//        id frameCacheObject = frameCacheDict[keyForObject(button.model)];
//        if (frameCacheObject) {
//            button.frame = [frameCacheObject CGRectValue];
//        } else {
            if (button.width + 10 + originX < kScreenWidth) {
                button.origin = (CGPoint){originX, originY};
                originX = button.x + 10 + button.width;
                originY = button.y;
            } else {
                button.origin = (CGPoint){10, originY + 5 + kButtonHeight};
                originX = button.x + 10 + button.width;
                originY = button.y;
            }
//            frameCacheDict[keyForObject(button.model)] = [NSValue valueWithCGRect:button.frame];
//        }

        
        button.hidden = NO;
        if (!button.superview) {
            [self.contentView addSubview:button];
        }
    }
    
}

#pragma mark - Setters

- (void)setNodesArray:(NSArray *)nodesArray {
    _nodesArray = nodesArray;
    
    if (_nodesArray == nil) {
        return;
    }
    
    /* FIX: 要是nodesArray.count < buttonArray.count? */
    if (self.buttonArray.count > self.nodesArray.count) {
        NSRange range = (NSRange){self.nodesArray.count, self.buttonArray.count - self.nodesArray.count};
        [self.buttonArray enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        [self.buttonArray removeObjectsInRange:range];
    }
    
    for (int i = 0; i < self.nodesArray.count; i ++) {
        UIButton *button;
        if (i < self.buttonArray.count) {
            button = self.buttonArray[i];
        } else {
            button = [self createButton];

            [self.buttonArray addObject:button];
        }
        
        V2NodeModel *model = self.nodesArray[i];
        button.model = model;
        
        [self configureButton:button withModel:model];
    }
    
    [self layoutButtons];

}

#pragma mark - Configure Button

- (UIButton *)createButton {
    
    UIButton *nodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nodeButton.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [nodeButton setTitleColor:kFontColorBlackBlue forState:UIControlStateNormal];
    [nodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [nodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//    [nodeButton setBackgroundColor:[UIColor colorWithWhite:0.951 alpha:1.000]];
//    [nodeButton setBackgroundImage:self.imageNormal forState:UIControlStateNormal];
//    [nodeButton setBackgroundImage:self.imageHighlighted forState:UIControlStateHighlighted];
//    [nodeButton setBackgroundImage:self.imageHighlighted forState:UIControlStateSelected];
//    nodeButton.clipsToBounds = YES;
//    nodeButton.layer.cornerRadius = 4.0f;
    
    @weakify(self);
    [nodeButton bk_addEventHandler:^(UIButton *sender) {
        @strongify(self);
        
        sender.selected = YES;
        [sender setBackgroundColor:kColorBlue];
        V2NodeViewController *nodeVC = [[V2NodeViewController alloc] init];
        nodeVC.model = sender.model;
        
        [self.navi pushViewController:nodeVC animated:YES];
        [self bk_performBlock:^(id obj) {
            sender.selected = NO;
            [sender setBackgroundColor:[UIColor clearColor]];
        } afterDelay:1.0];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    [nodeButton bk_addEventHandler:^(id sender) {
        [sender setBackgroundColor:kColorBlue];
    } forControlEvents:UIControlEventTouchDown];
    [nodeButton bk_addEventHandler:^(id sender) {
        [sender setBackgroundColor:[UIColor clearColor]];
    } forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpOutside|UIControlEventTouchDragOutside];
    
    return nodeButton;
}

- (UIButton *)configureButton:(UIButton *)button withModel:(V2NodeModel *)model {
    
    NSInteger buttonWidth = [V2NodesViewCell buttonWidthWithTitle:model.nodeTitle];
    
    button.size = (CGSize){buttonWidth, kButtonHeight};
    button.model = model;
    
    [button setTitle:model.nodeTitle forState:UIControlStateNormal];

    return button;
}

#pragma mark - Private Methods

+ (CGFloat)buttonWidthWithTitle:(NSString *)title {
    
    return [V2Helper getTextWidthWithText:title Font:[UIFont systemFontOfSize:kFontSize]] + kButtonInsert;
}

#pragma mark - Class Methods

+ (CGFloat)getCellHeightWithNodesArray:(NSArray *)nodesArray {
    
    if (nodesArray.count == 0) {
        return 0;
    }
    
    id heightCacheObject = frameCacheDict[keyForObject(nodesArray)];
    if (heightCacheObject && [heightCacheObject isKindOfClass:[NSNumber class]]) {
        return [heightCacheObject floatValue];
    }
    
    CGFloat originX = 10;
    CGFloat originY = 10;
    
    CGPoint origin;
    
    for (int i = 0; i < nodesArray.count; i ++) {
        V2NodeModel *model = nodesArray[i];
        CGFloat width = [V2NodesViewCell buttonWidthWithTitle:model.nodeTitle];
        if (width + 10 + originX < kScreenWidth) {
            origin = (CGPoint){originX, originY};
            originX = origin.x + 10 + width;
            originY = origin.y;
        } else {
            origin = (CGPoint){10, originY + 5 + kButtonHeight};
            originX = origin.x + 10 + width;
            originY = origin.y;
        }
    }
    
    CGFloat height = originY + kButtonHeight + 10;
    frameCacheDict[keyForObject(nodesArray)] = @(height);
    
    return height;

}

static NSString * keyForObject(id object) {
    return [NSString stringWithFormat:@"%p", object];
}

@end


@implementation UIButton (V2NodeModel)

- (V2NodeModel *)model {
    return objc_getAssociatedObject(self, @selector(model));
}

- (void)setModel:(V2NodeModel *)model {
    objc_setAssociatedObject(self, @selector(model), model, OBJC_ASSOCIATION_RETAIN);
}

@end