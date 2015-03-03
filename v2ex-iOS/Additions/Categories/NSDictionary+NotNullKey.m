//
//  NSDictionary+NSDictionary_NotNullKey.m
//  HeadLine
//
//  Created by Ohw Althrun on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+NotNullKey.h"

@implementation NSDictionary (NotNullKey)

//把 NSObject 转为 NSDictionary
+(NSDictionary *) dictionaryWithPropertiesOfObject:(id)obj
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        Class classObject = NSClassFromString([key capitalizedString]);
        if (classObject) {
            id subObj = [self dictionaryWithPropertiesOfObject:[obj valueForKey:key]];
            [dict setObject:subObj forKey:key];
        }
        else
        {
            id value = [obj valueForKey:key];
            if(value) [dict setObject:value forKey:key];
        }
    }
    
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

// in case of [NSNull null] values a nil is returned ...
- (id)objectForSafeKey:(id)key {
    id object = [self objectForKey:key];
    
    if ([object isEqual:[NSNull null]])
        return nil;
    
    return object;
}

@end
