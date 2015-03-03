//
//  WBHttpRequest+Block.h
//  newSponia
//
//  Created by Singro on 5/31/14.
//  Copyright (c) 2014 Sponia. All rights reserved.
//

#import "WeiboSDK.h"


@interface WBHttpRequest (block)

@property (nonatomic, copy) void (^successBlock)(WBHttpRequest *reuqest, id responseObject);
@property (nonatomic, copy) void (^failureBlock)(NSError *error);

@end

@interface WBBaseRequest (block)

@property (nonatomic, copy) void (^successBlock)(WBBaseResponse *response);
@property (nonatomic, copy) void (^failureBlock)(NSError *error);

@end