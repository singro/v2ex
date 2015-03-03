//
//  V2NodesViewCell.h
//  v2ex-iOS
//
//  Created by Singro on 5/8/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2NodesViewCell : UITableViewCell

@property (nonatomic, strong) NSArray *nodesArray;
@property (nonatomic, assign) UINavigationController *navi;

+ (CGFloat)getCellHeightWithNodesArray:(NSArray *)nodes;

@end
