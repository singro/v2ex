//
//  KSActionShareView.h
//  KeyShare
//
//  Created by Singro on 12/29/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCActionSheet.h"

@interface V2ActionCellView : UIView

@property (nonatomic, weak) SCActionSheet *actionSheet;

- (instancetype)initWithTitles:(NSArray *)titles imageNames:(NSArray *)imageNames;

- (void)sc_setButtonHandler:(void (^)(void))block forIndex:(NSInteger)index;

@end
