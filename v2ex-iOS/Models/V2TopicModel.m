//
//  V2TopicModel.m
//  v2ex-iOS
//
//  Created by Singro on 3/17/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2TopicModel.h"

#import "V2NodeModel.h"
#import "V2MemberModel.h"

#import "V2TopicStateManager.h"

#import <HTMLParser.h>
#import <RegexKitLite.h>
#import "NSString+SCMention.h"
#import "SCQuote.h"
#import <CoreText/CoreText.h>

#import "V2TopicListCell.h"

@implementation V2TopicModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        
        self.topicId              = [dict objectForSafeKey:@"id"];
        self.topicTitle           = [dict objectForSafeKey:@"title"];
        self.topicReplyCount      = [NSString stringWithFormat:@"%@", [dict objectForSafeKey:@"replies"]];
        self.topicUrl             = [dict objectForSafeKey:@"url"];
        self.topicContent         = [dict objectForSafeKey:@"content"];
        self.topicContentRendered = [dict objectForSafeKey:@"content_rendered"];
        self.topicCreated         = [dict objectForSafeKey:@"created"];
        self.topicModified        = [dict objectForSafeKey:@"last_modified"];
        self.topicTouched         = [dict objectForSafeKey:@"last_touched"];

        NSDictionary *nodeDict    = [dict objectForSafeKey:@"node"];
        self.topicNode            = [[V2NodeModel alloc] initWithDictionary:nodeDict];

        NSDictionary *creatorDict = [dict objectForSafeKey:@"member"];
        self.topicCreator         = [[V2MemberModel alloc] initWithDictionary:creatorDict];

        self.state                = [[V2TopicStateManager manager] getTopicStateWithTopicModel:self];
        
        
        self.topicContent = [self.topicContent stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
        while ([self.topicContent rangeOfString:@"\n\n"].location != NSNotFound) {
            self.topicContent = [self.topicContent stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
        }

//        self.topicContent = [self.topicContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];

        if (self.topicCreated) {
            self.topicCreatedDescription = [V2Helper timeRemainDescriptionWithDateSP:self.topicCreated];
        }
        
        self.quoteArray = [self.topicContentRendered quoteArray];
        
        NSString *mentionString = self.topicContent;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.topicContent];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kFontColorBlackDark range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, attributedString.length)];

        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 8.0;
        
        [attributedString addAttributes:@{
                                          NSParagraphStyleAttributeName: style,
                                          } range:NSMakeRange(0, attributedString.length)];
        
        NSMutableArray *imageURLs = [[NSMutableArray alloc] init];
        
        for (SCQuote *quote in self.quoteArray) {
            NSRange range = [mentionString rangeOfString:quote.string];
            if (range.location != NSNotFound) {
                mentionString = [mentionString stringByReplacingOccurrencesOfString:quote.string withString:[self spaceWithLength:range.length]];
                quote.range = range;
                if (quote.type == SCQuoteTypeUser) {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:(id)RGB(0x778087, 0.8) range:NSMakeRange(range.location - 1, 1)];
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
        
        self.imageURLs = imageURLs;
        self.attributedString = attributedString;

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
                            otherQuote.range = (NSMakeRange(otherQuote.range.location - lastStringIndex, otherQuote.range.length));
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
                    NSInteger location = otherQuote.range.location - lastStringIndex - stringOffset;
                    if (location >= 0) {
                        otherQuote.range = NSMakeRange(location, otherQuote.range.length);
                    } else {
                        otherQuote.range = NSMakeRange(0, 0);
                    }
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


@implementation V2TopicList

- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in array) {
            V2TopicModel *model = [[V2TopicModel alloc] initWithDictionary:dict];
            [list addObject:model];
        }
        
        self.list = list;
        
    }
    
    return self;
}

- (void)dealloc {
    _list = nil;
}

+ (V2TopicList *)getTopicListFromResponseObject:(id)responseObject {
    
    NSMutableArray *topicArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        
        
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
            return nil;
        }
        
        HTMLNode *bodyNode = [parser body];
        
        NSArray *cellNodes = [bodyNode findChildTags:@"div"];
        
        for (HTMLNode *cellNode in cellNodes) {
            if ([[cellNode getAttributeNamed:@"class"] isEqualToString:@"cell item"]) {
                
                //                NSLog(@"%@", cellNode.rawContents);
                
                V2TopicModel *model = [[V2TopicModel alloc] init];
                model.topicCreator = [[V2MemberModel alloc] init];
                model.topicNode = [[V2NodeModel alloc] init];
                
                NSArray *tdNodes = [cellNode findChildTags:@"td"];
                
                NSInteger index = 0;
                for (HTMLNode *tdNode in tdNodes) {
                    
//                    NSLog(@"td:\n%@", tdNode.rawContents);
                    NSString *content = tdNode.rawContents;

//                    if (index == 0) {
                    if ([content rangeOfString:@"class=\"avatar\""].location != NSNotFound) {

                        HTMLNode *userIdNode = [tdNode findChildTag:@"a"];
                        if (userIdNode) {
                            NSString *idUrlString = [userIdNode getAttributeNamed:@"href"];
                            model.topicCreator.memberName = [[idUrlString componentsSeparatedByString:@"/"] lastObject];
                        }
                        
                        HTMLNode *avatarNode = [tdNode findChildTag:@"img"];
                        if (avatarNode) {
                            NSString *avatarString = [avatarNode getAttributeNamed:@"src"];
                            if ([avatarString hasPrefix:@"//"]) {
                                avatarString = [@"http:" stringByAppendingString:avatarString];
                            }
                            model.topicCreator.memberAvatarNormal = avatarString;
                        }
                    }
                    
//                    if (index == 2) {
                        //                        NSLog(@"td:\n%@", tdNode.rawContents);
                    if ([content rangeOfString:@"class=\"item_title\""].location != NSNotFound) {

                        NSArray *aNodes = [tdNode findChildTags:@"a"];
                        
                        for (HTMLNode *aNode in aNodes) {
                            if ([[aNode getAttributeNamed:@"class"] isEqualToString:@"node"]) {
                                NSString *nodeUrlString = [aNode getAttributeNamed:@"href"];
                                model.topicNode.nodeName = [[nodeUrlString componentsSeparatedByString:@"/"] lastObject];
                                model.topicNode.nodeTitle = aNode.allContents;
                                
                            } else {
                                if ([aNode.rawContents rangeOfString:@"reply"].location != NSNotFound) {
                                    model.topicTitle = aNode.allContents;
                                    
                                    NSString *topicIdString = [aNode getAttributeNamed:@"href"];
                                    NSArray *subArray = [topicIdString componentsSeparatedByString:@"#"];
                                    model.topicId = [(NSString *)subArray.firstObject stringByReplacingOccurrencesOfString:@"/t/" withString:@""];
                                    model.topicReplyCount = [(NSString *)subArray.lastObject stringByReplacingOccurrencesOfString:@"reply" withString:@""];
                                    
                                    
                                }
                            }
                        }
                        
                        NSArray *spanNodes = [tdNode findChildTags:@"span"];
                        for (HTMLNode *spanNode in spanNodes) {
                            if ([spanNode.rawContents rangeOfString:@"href"].location == NSNotFound) {
                                model.topicCreatedDescription = spanNode.allContents;
                            }

                            if ([spanNode.rawContents rangeOfString:@"最后回复"].location != NSNotFound || [spanNode.rawContents rangeOfString:@"前"].location != NSNotFound) {
                                
                                NSString *contentString = spanNode.allContents;
                                NSArray *components = [contentString componentsSeparatedByString:@"  •  "];
                                NSString *dateString;
                                
                                if (components.count > 2) {
                                    dateString = components[2];
                                } else {
                                    dateString = [contentString stringByReplacingOccurrencesOfRegex:@"  •  (.*?)$" withString:@""];
                                }
                                
                                NSArray *stringArray = [dateString componentsSeparatedByString:@" "];
                                if (stringArray.count > 1) {
                                    NSString *unitString = @"";
                                    NSString *subString = [(NSString *)stringArray[1] substringToIndex:1];
                                    if ([subString isEqualToString:@"分"]) {
                                        unitString = @"分钟前";
                                    }
                                    if ([subString isEqualToString:@"小"]) {
                                        unitString = @"小时前";
                                    }
                                    if ([subString isEqualToString:@"天"]) {
                                        unitString = @"天前";
                                    }
//                                    unitString = stringArray[1];
                                    dateString = [NSString stringWithFormat:@"%@%@", stringArray[0], unitString];
                                } else {
                                    //                                    dateString = @"just now";
                                    dateString = @"刚刚";
                                }
                                model.topicCreatedDescription = dateString;
                            }
                        }
                        
                    }
                    
                    
                    index ++;
                }
                
                model.state = [[V2TopicStateManager manager] getTopicStateWithTopicModel:model];
                model.cellHeight = [V2TopicListCell heightWithTopicModel:model];
                
                [topicArray addObject:model];
            }
        }
        
    }
    
    V2TopicList *list;
    
    if (topicArray.count) {
        list = [[V2TopicList alloc] init];
        list.list = topicArray;
    }
    
    return list;

}

@end


@implementation V2ContentBaseModel

- (instancetype)init {
    
    if (self = [super init]) {
        
        
    }
    
    return self;

}

@end


@implementation V2ContentStringModel

- (instancetype)init {
    
    if (self = [super init]) {
        
        self.contentType = V2ContentTypeString;

    }
    
    return self;
    
}

@end


@implementation V2ContentImageModel

- (instancetype)init {
    
    if (self = [super init]) {
        
        self.contentType = V2ContentTypeImage;
        
    }
    
    return self;
    
}

@end
