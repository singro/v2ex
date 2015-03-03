//
//  SCQuote.m
//  SCMetionTextView
//
//  Created by Singro on 3/14/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCQuote.h"

@implementation SCQuote

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        self.type = SCQuoteTypeNone;
        self.backgroundArray = [[NSMutableArray alloc] initWithCapacity:2];
        
    }
    
    return self;
}

- (NSString *)quoteString {
    
    NSString *typeString = @"";
    switch (self.type) {
        case SCQuoteTypeTopic:
            typeString = @"topic";
            break;
        case SCQuoteTypeUser:
            typeString = @"user";
            break;
        case SCQuoteTypeEmail:
            typeString = @"email";
            break;
        case SCQuoteTypeLink:
            typeString = @"link";
            break;
        case SCQuoteTypeAppStore:
            typeString = @"appStore";
            break;
        case SCQuoteTypeImage:
            typeString = @"image";
            break;
        case SCQuoteTypeVedio:
            typeString = @"vedio";
            break;
        case SCQuoteTypeNode:
            typeString = @"node";
            break;
       default:
            break;
    }
    
    return [NSString stringWithFormat:@"[%@(%@)%@]", typeString, self.identifier, self.string];
}


@end
