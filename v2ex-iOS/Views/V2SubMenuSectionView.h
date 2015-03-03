//
//  V2SubMenuSectionView.h
//  v2ex-iOS
//
//  Created by Singro on 4/10/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2SubMenuSectionView : UIView

@property (nonatomic, strong) NSArray *sectionTitleArray;
@property (nonatomic, assign, getter = isFavorite) BOOL favorite;

//@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) void (^didSelectedIndexBlock)(NSInteger index);

- (void)setDidSelectedIndexBlock:(void (^)(NSInteger index))didSelectedIndexBlock;

@end
