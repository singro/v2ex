//
//  V2MemberReplyModel.m
//  v2ex-iOS
//
//  Created by Singro on 5/14/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2MemberReplyModel.h"

#import "HTMLParser.h"
#import <RegexKitLite.h>

@import CoreText;

@implementation V2MemberReplyModel

@end

@implementation V2MemberReplyList

+ (V2MemberReplyList *)getMemberReplyListFromResponseObject:(id)responseObject {
    
    __block NSMutableArray *notificationArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        
        
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
        
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
        }
        
        HTMLNode *bodyNode = [parser body];

        
        NSArray *contentNodes = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"reply_content" allowPartial:YES];
        
        for (int i = 0; i < contentNodes.count; i ++) {
            V2MemberReplyModel *model = [[V2MemberReplyModel alloc] init];
            V2TopicModel *topicModel = [[V2TopicModel alloc] init];
            model.memberReplyTopic = topicModel;
            [notificationArray addObject:model];
        }
        
        // Content
        [contentNodes enumerateObjectsUsingBlock:^(HTMLNode *contentNode, NSUInteger idx, BOOL *stop) {
            V2MemberReplyModel *model = notificationArray[idx];
            model.memberReplyContent = contentNode.allContents;
        }];
        
        // time
        NSArray *timeNodes = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"fade" allowPartial:YES];
        
        [timeNodes enumerateObjectsUsingBlock:^(HTMLNode *timeNode, NSUInteger idx, BOOL *stop) {
            if (idx != timeNodes.count - 1) {
                V2MemberReplyModel *model = notificationArray[idx];
                model.memberReplyCreatedDescription = timeNode.allContents;
            }
        }];
        
        // reply
        NSArray *grayNodes = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"gray" allowPartial:YES];
        [grayNodes enumerateObjectsUsingBlock:^(HTMLNode *grayNode, NSUInteger idx, BOOL *stop) {
            if (idx != 0) {
                V2MemberReplyModel *model = notificationArray[idx - 1];
                
                HTMLNode *aNode = [grayNode findChildTag:@"a"];
                if (!aNode) {
                    return ;
                }
                model.memberReplyTopic.topicTitle = aNode.allContents;
                
                NSString *topicURLString = [aNode getAttributeNamed:@"href"];
                topicURLString = [topicURLString stringByReplacingOccurrencesOfString:@"/t/" withString:@""];
                model.memberReplyTopic.topicId = [topicURLString componentsSeparatedByString:@"#"].firstObject;
                
                NSString *topString = grayNode.allContents;
                topString = [topString stringByReplacingOccurrencesOfString:aNode.allContents withString:@""];
                
                NSArray *topArray = [topString componentsSeparatedByString:@" "];
                
                if (topArray.count >= 3) {
                    
                    // AttributedString
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
                    
                    NSAttributedString *beforeAttributedString = [[NSAttributedString alloc] initWithString:topArray[0] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.700 alpha:1.000], NSFontAttributeName: [UIFont systemFontOfSize:15]}];
                    [attributedString appendAttributedString:beforeAttributedString];

                    NSString *nameString = [NSString stringWithFormat:@" %@ " , topArray[1]];
                    NSAttributedString *nameAttributedString = [[NSAttributedString alloc] initWithString:nameString attributes:@{NSForegroundColorAttributeName: kFontColorBlackBlue, NSFontAttributeName: [UIFont boldSystemFontOfSize:15]}];
                    [attributedString appendAttributedString:nameAttributedString];
                    
                    NSAttributedString *afterAttributedString = [[NSAttributedString alloc] initWithString:topArray[2] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.700 alpha:1.000], NSFontAttributeName: [UIFont systemFontOfSize:15]}];
                    [attributedString appendAttributedString:afterAttributedString];
                    
                    NSString *topicTitleString = [NSString stringWithFormat:@" %@" , model.memberReplyTopic.topicTitle];
                    NSAttributedString *topicAttributedString = [[NSAttributedString alloc] initWithString:topicTitleString attributes:@{NSForegroundColorAttributeName: kFontColorBlackBlue, NSFontAttributeName: [UIFont systemFontOfSize:15]}];
                    [attributedString appendAttributedString:topicAttributedString];

                    CGFloat lineSpace=  2.5;
                    
                    CTParagraphStyleSetting settings[] =
                    {
                        {kCTParagraphStyleSpecifierLineSpacing, sizeof(float), &lineSpace}
                    };
                    
                    CTParagraphStyleRef style;
                    style = CTParagraphStyleCreate(settings, sizeof(settings)/sizeof(CTParagraphStyleSetting));
                    
                    [attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSObject*)style, (NSString*)kCTParagraphStyleAttributeName, nil]
                                              range:NSMakeRange(0, [attributedString length])];
                    
                    CFRelease(style);
                    
                    model.memberReplyTopAttributedString = attributedString;
                    
                    if (model.memberReplyContent) {
                        NSAttributedString *descriptionAttributedString = [[NSAttributedString alloc] initWithString:model.memberReplyContent attributes:@{NSForegroundColorAttributeName: kFontColorBlackDark, NSFontAttributeName: [UIFont systemFontOfSize:15]}];
                        model.memberReplyContentAttributedString = descriptionAttributedString;
                    }

                }

            }
        }];

        
    }
    
    V2MemberReplyList *list;
    
    if (notificationArray.count) {
        list = [[V2MemberReplyList alloc] init];
        list.list = notificationArray;
    }
    
    return list;
}

@end
