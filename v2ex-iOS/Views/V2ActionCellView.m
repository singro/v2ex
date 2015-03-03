//
//  KSActionShareView.m
//  KeyShare
//
//  Created by Singro on 12/29/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2ActionCellView.h"

#import "V2ActionItemView.h"

@interface V2ActionCellView ()

@property (nonatomic, strong) NSArray *itemArray;

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *imageNames;

@end

@implementation V2ActionCellView

- (instancetype)initWithTitles:(NSArray *)titles imageNames:(NSArray *)imageNames {
    
    if (self = [super initWithFrame:(CGRect){0, 0, kScreenWidth, kItemHeight}]) {
        
        if (titles.count) {
            self.height = kItemHeightTitle;
        } else {
            self.height = kItemHeight;
        }

        CGFloat startX = 15;
        CGFloat space = (kScreenWidth - 2 * startX - kItemWidth * 4) / 5;
        
        NSMutableArray *itemArray = [NSMutableArray new];
        for (NSInteger i = 0; i < imageNames.count; i ++) {
            NSString *title;
            if (i < titles.count) {
                title = titles[i];
            }
            V2ActionItemView *itemView = [[V2ActionItemView alloc] initWithTitle:title imageName:imageNames[i]];
            [self addSubview:itemView];
            [itemArray addObject:itemView];
            itemView.x = startX + space + (space + kItemWidth) * i;
        }
        
        self.itemArray = itemArray;
    }
    
    return self;

}

//- (instancetype)initWithFrame:(CGRect)frame {
//}
//
- (void)sc_setButtonHandler:(void (^)(void))block forIndex:(NSInteger)index {
    
    if (index >= self.itemArray.count || !block) {
        return;
    }
    
    V2ActionItemView *itemView = self.itemArray[index];
    
    [itemView setActionBlock:^(UIButton *button, UILabel *item) {
        if (self.actionSheet) {
            [self.actionSheet sc_hide:YES];
        }
        block();
    }];
    
}

@end
