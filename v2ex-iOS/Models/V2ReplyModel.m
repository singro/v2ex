//
//  V2ReplyModel.m
//  v2ex-iOS
//
//  Created by Singro on 3/18/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2ReplyModel.h"

#import "V2MemberModel.h"

#import <HTMLParser.h>
#import <RegexKitLite.h>
#import "NSString+SCMention.h"
#import "SCQuote.h"
#import <CoreText/CoreText.h>

@implementation V2ReplyModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        
        self.replyId              = [dict objectForSafeKey:@"id"];
        self.replyThanksCount     = [dict objectForSafeKey:@"thanks"];
        self.replyModified        = [dict objectForSafeKey:@"last_modified"];
        self.replyCreated         = [dict objectForSafeKey:@"created"];
        self.replyContent         = [dict objectForSafeKey:@"content"];
        self.replyContentRendered = [dict objectForSafeKey:@"content_rendered"];

        NSDictionary *creatorDict = [dict objectForSafeKey:@"member"];
        self.replyCreator         = [[V2MemberModel alloc] initWithDictionary:creatorDict];
        
        
        self.quoteArray = [self.replyContentRendered quoteArray];
        
        NSString *mentionString = self.replyContent;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.replyContent];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kFontColorBlackDark range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, attributedString.length)];

        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 6.0;

        [attributedString addAttributes:@{
                                          NSParagraphStyleAttributeName: style,
                                          } range:NSMakeRange(0, attributedString.length)];

//        CGFloat lineSpace = 9;
//        
//        CTParagraphStyleSetting settings[] =
//        {
//            {kCTParagraphStyleSpecifierLineSpacing, sizeof(float), &lineSpace}
//        };
//        
//        CTParagraphStyleRef style;
//        style = CTParagraphStyleCreate(settings, sizeof(settings)/sizeof(CTParagraphStyleSetting));
        
//        [attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSObject*)style, (NSString*)kCTParagraphStyleAttributeName, nil]
//                                  range:NSMakeRange(0, [attributedString length])];
//        
//        CFRelease(style);
        
        // configure quotes
        
        NSMutableArray *imageURLs = [[NSMutableArray alloc] init];

        for (SCQuote *quote in self.quoteArray) {
            NSRange range = [mentionString rangeOfString:quote.string];
            if (range.location != NSNotFound) {
                mentionString = [mentionString stringByReplacingOccurrencesOfString:quote.string withString:[self spaceWithLength:range.length]];
                quote.range = range;
                if (quote.type == SCQuoteTypeUser) {
                    if (range.location > 0) {
                        [attributedString addAttribute:NSForegroundColorAttributeName value:(id)RGB(0x778087, 0.8) range:NSMakeRange(range.location - 1, 1)];
                    }
                } else {
                }
            } else {
                NSString *string = [quote.string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSRange range = [mentionString rangeOfString:string];
                if (range.location != NSNotFound) {
                    mentionString = [mentionString stringByReplacingOccurrencesOfString:quote.string withString:[self spaceWithLength:range.length]];
                    quote.range = range;
                } else {
                    quote.range = NSMakeRange(0, 0);
                }
            }
            
            if (quote.type == SCQuoteTypeImage) {
                [imageURLs addObject:quote.identifier];
            }

        }
        
        self.attributedString = attributedString;

        self.imageURLs = imageURLs;
        

        if (!kSetting.trafficSaveModeOn) {
            
            NSMutableArray *contentArray = [[NSMutableArray alloc] init];
            
            __block NSUInteger lastStringIndex = 0;
            __block NSUInteger lastImageQuoteIndex = 0;
            
            [self.quoteArray enumerateObjectsUsingBlock:^(SCQuote *quote, NSUInteger idx, BOOL *stop) {
                
                if (quote.type == SCQuoteTypeImage) {
                    
                    if (quote.range.location > lastStringIndex) {
                        
                        V2ContentStringModel *stringModel = [[V2ContentStringModel alloc] init];
                        
                        NSAttributedString *subString = [attributedString attributedSubstringFromRange:(NSRange){lastStringIndex, quote.range.location - lastStringIndex}];
                        NSAttributedString *firstString = [subString attributedSubstringFromRange:(NSRange){0, 1}];
                        NSInteger stringOffset = 0;
                        if ([firstString.string isEqualToString:@"\n"]) {
                            stringOffset = 1;
                            subString = [attributedString attributedSubstringFromRange:(NSRange){lastStringIndex + stringOffset, quote.range.location - lastStringIndex - stringOffset}];
                        }
                        stringModel.attributedString = subString;
                        
                        NSMutableArray *quotes = [[NSMutableArray alloc] init];
                        for (NSInteger i = lastImageQuoteIndex; i < idx; i ++) {
                            SCQuote *otherQuote = self.quoteArray[i];
                            otherQuote.range = (NSMakeRange(otherQuote.range.location - lastStringIndex - stringOffset, otherQuote.range.length));
                            [quotes addObject:self.quoteArray[i]];
                        }
                        if (quotes.count > 0) {
                            stringModel.quoteArray = quotes;
                        }
                        
                        [contentArray addObject:stringModel];
                        
                    }
                    
                    V2ContentImageModel *imageModel = [[V2ContentImageModel alloc] init];
                    imageModel.imageQuote = quote;
                    
                    [contentArray addObject:imageModel];
                    
                    lastImageQuoteIndex = idx + 1;
                    lastStringIndex = quote.range.location + quote.range.length;
                }
                
            }];
            
            if (lastStringIndex < attributedString.length) {
                
                V2ContentStringModel *stringModel = [[V2ContentStringModel alloc] init];
                
//                NSAttributedString *subString = [attributedString attributedSubstringFromRange:(NSRange){lastStringIndex, attributedString.length - lastStringIndex}];
//                stringModel.attributedString = subString;
                
                NSAttributedString *subString = [attributedString attributedSubstringFromRange:(NSRange){lastStringIndex, attributedString.length - lastStringIndex}];
                NSAttributedString *firstString = [subString attributedSubstringFromRange:(NSRange){0, 1}];
                NSInteger stringOffset = 0;
                if ([firstString.string isEqualToString:@"\n"]) {
                    stringOffset = 1;
                    subString = [attributedString attributedSubstringFromRange:(NSRange){lastStringIndex + stringOffset, attributedString.length - lastStringIndex - stringOffset}];
                }
                stringModel.attributedString = subString;

                NSMutableArray *quotes = [[NSMutableArray alloc] init];
                for (NSInteger i = lastImageQuoteIndex; i < self.quoteArray.count; i ++) {
                    SCQuote *otherQuote = self.quoteArray[i];
                    otherQuote.range = (NSMakeRange(otherQuote.range.location - lastStringIndex - stringOffset, otherQuote.range.length));
                    [quotes addObject:self.quoteArray[i]];
                }
                if (quotes.count > 0) {
                    stringModel.quoteArray = quotes;
                }
                
                [contentArray addObject:stringModel];
                
            }
            
            self.contentArray = contentArray;
        }
    }
    
    return self;
}

- (NSString *)spaceWithLength:(NSUInteger)length {
    
    NSString *spaceString = @"";
    
    while (spaceString.length < length) {
        spaceString = [spaceString stringByAppendingString:@" "];
    }
    
    return spaceString;
}

@end



@implementation V2ReplyList

- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in array) {
            V2ReplyModel *model = [[V2ReplyModel alloc] initWithDictionary:dict];
            [list addObject:model];
        }
        
        self.list = list;
        
    }
    
    return self;
}

@end