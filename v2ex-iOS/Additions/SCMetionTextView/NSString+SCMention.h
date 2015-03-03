//
//  NSString+SCMention.h
//  newSponia
//
//  Created by Singro on 3/26/14.
//  Copyright (c) 2014 Sponia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SCMention)

- (NSString *)enumerateMetionObjectsUsingBlock:(void (^)(id object, NSRange range))block;

- (NSString *)metionPlainString;

- (NSString *)mentionStringFromHtmlString:(NSString *)htmlString;

- (NSArray *)quoteArray;

@end


