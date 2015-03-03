//
//  V2MemberTopicsViewController.h
//  v2ex-iOS
//
//  Created by Singro on 5/12/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCPullRefreshViewController.h"

@interface V2MemberTopicsViewController : SCPullRefreshViewController

//@property (nonatomic, copy) NSString *memberName;
@property (nonatomic, strong) V2MemberModel *model;

@end
