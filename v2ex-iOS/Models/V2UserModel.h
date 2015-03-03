//
//  V2UserModel.h
//  v2ex-iOS
//
//  Created by Singro on 4/6/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface V2UserModel : NSObject

@property (nonatomic, strong) V2MemberModel *member;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSURL *feedURL;

@property (nonatomic, assign, getter = isLogin) BOOL login;

@end
