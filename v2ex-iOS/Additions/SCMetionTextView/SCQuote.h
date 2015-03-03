//
//  SCQuote.h
//  SCMetionTextView
//
//  Created by Singro on 3/14/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SCQuoteType) {
    SCQuoteTypeNone,
    SCQuoteTypeUser,
    SCQuoteTypeEmail,
    SCQuoteTypeLink,
    SCQuoteTypeAppStore,
    SCQuoteTypeImage,
    SCQuoteTypeVedio,
    SCQuoteTypeTopic,
    SCQuoteTypeNode,
};

@interface SCQuote : NSObject

@property (nonatomic, copy) NSString *string;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign)  SCQuoteType type;

@property (nonatomic, assign) NSRange range;
@property (nonatomic, strong) NSMutableArray *backgroundArray;

- (NSString *)quoteString;

@end
