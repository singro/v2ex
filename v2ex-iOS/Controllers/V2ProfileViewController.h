//
//  V2ProfileViewController.h
//  v2ex-iOS
//
//  Created by Singro on 4/7/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCPullRefreshViewController.h"

@interface V2ProfileViewController : SCPullRefreshViewController

@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, strong) V2MemberModel *member;

@end
