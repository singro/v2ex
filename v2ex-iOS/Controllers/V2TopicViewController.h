//
//  V2TopicViewController.h
//  v2ex-iOS
//
//  Created by Singro on 3/18/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCPullRefreshViewController.h"

@interface V2TopicViewController : SCPullRefreshViewController

@property (nonatomic, assign, getter = isCreate) BOOL create;
@property (nonatomic, assign, getter = isPreview) BOOL preview;

@property (nonatomic, strong) V2TopicModel *model;

@end
