//
//  WBHttpRequest+Block.m
//  newSponia
//
//  Created by Singro on 5/31/14.
//  Copyright (c) 2014 Sponia. All rights reserved.
//


#import "WBRequest+Block.h"
#import <objc/runtime.h>

static char const * const kHttpRequestSuccessBlock = "kHttpRequestSuccessBlock";
static char const * const kHttpRequestFailureBlock = "kHttpRequestFailureBlock";

@implementation  WBHttpRequest (block)

@dynamic successBlock;
@dynamic failureBlock;

- (void)setSuccessBlock:(void (^)(WBHttpRequest *, id))successBlock {
    objc_setAssociatedObject(self, kHttpRequestSuccessBlock, successBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(WBHttpRequest *reuqest, id responseObject))successBlock {
    return objc_getAssociatedObject(self, kHttpRequestSuccessBlock);
}

- (void)setFailureBlock:(void (^)(NSError *))failureBlock {
    objc_setAssociatedObject(self, kHttpRequestFailureBlock, failureBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSError *error))failureBlock {
    return objc_getAssociatedObject(self, kHttpRequestFailureBlock);
}

@end


static char const * const kBaseRequestSuccessBlock = "kBaseRequestSuccessBlock";
static char const * const kBaseRequestFailureBlock = "kBaseRequestFailureBlock";

@implementation  WBBaseRequest (block)

@dynamic successBlock;
@dynamic failureBlock;

- (void)setSuccessBlock:(void (^)(WBBaseResponse *))successBlock {
    objc_setAssociatedObject(self, kBaseRequestSuccessBlock, successBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(WBBaseResponse *response))successBlock {
    return objc_getAssociatedObject(self, kBaseRequestSuccessBlock);
}

- (void)setFailureBlock:(void (^)(NSError *))failureBlock {
    objc_setAssociatedObject(self, kBaseRequestFailureBlock, failureBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSError *error))failureBlock {
    return objc_getAssociatedObject(self, kBaseRequestFailureBlock);
}

@end
