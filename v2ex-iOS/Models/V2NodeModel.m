//
//  V2NodeModel.m
//  v2ex-iOS
//
//  Created by Singro on 3/17/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2NodeModel.h"

@implementation V2NodeModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        
        self.nodeId               = [dict objectForSafeKey:@"id"];
        self.nodeName             = [dict objectForSafeKey:@"name"];
        self.nodeUrl              = [dict objectForSafeKey:@"url"];
        self.nodeTitle            = [dict objectForSafeKey:@"title"];
        self.nodeTitleAlternative = [dict objectForSafeKey:@"title_alternative"];
        self.nodeTopicCount       = [dict objectForSafeKey:@"topics"];
        self.nodeHeader           = [dict objectForSafeKey:@"header"];
        self.nodeFooter           = [dict objectForSafeKey:@"footer"];
        self.nodeCreated          = [dict objectForSafeKey:@"created"];

    }
    
    return self;
}

@end


@implementation V2NodeList

- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in array) {
            V2NodeModel *model = [[V2NodeModel alloc] initWithDictionary:dict];
            [list addObject:model];
        }
        
        self.list = list;
        
    }
    
    return self;
}

@end