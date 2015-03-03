//
//  V2NotificationModel.m
//  v2ex-iOS
//
//  Created by Singro on 4/5/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2NotificationModel.h"

#import <HTMLParser.h>
#import <RegexKitLite.h>

@import CoreText;

@implementation V2NotificationModel

@end

@implementation V2NotificationList


+ (V2NotificationList *)getNotificationFromResponseObject:(id)responseObject {
    
    NSMutableArray *notificationArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        
        
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
        
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
        }
        
        HTMLNode *bodyNode = [parser body];
        
        //-(HTMLNode*)findChildWithAttribute:(NSString*)attribute matchingName:(NSString*)className allowPartial:(BOOL)partial
        
        NSArray *cellNodes = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"cell" allowPartial:YES];
        
        for (HTMLNode *cellNode in cellNodes) {
            
            NSArray *tdNodes = [cellNode findChildTags:@"td"];
            if (tdNodes.count == 2) {
                
                V2NotificationModel *model = [[V2NotificationModel alloc] init];
                
                // memeber
                HTMLNode *firstNode = tdNodes[0];
                V2MemberModel *member = [[V2MemberModel alloc] init];
                NSString *avatarUrl = [(HTMLNode *)[firstNode findChildOfClass:@"avatar"] getAttributeNamed:@"src"];
                if ([avatarUrl hasPrefix:@"//"]) {
                    avatarUrl = [@"http:" stringByAppendingString:avatarUrl];
                }
                member.memberAvatarNormal = avatarUrl;
                NSString *userUrl = [(HTMLNode *)[firstNode findChildTag:@"a"] getAttributeNamed:@"href"];
                member.memberName = [userUrl stringByReplacingOccurrencesOfString:@"/member/" withString:@""];
                
                HTMLNode *secondNode = tdNodes[1];
                
                // notification id
                //                deleteNotification(1126188,
                NSString *idRegex = @"deleteNotification\\((.*?),";
                NSString *idString = [secondNode.rawContents stringByMatching:idRegex];
                idString = [idString stringByReplacingOccurrencesOfString:@"deleteNotification(" withString:@""];
                idString = [idString stringByReplacingOccurrencesOfString:@"," withString:@""];
                model.notificationId = idString;
                
                // topic
                V2TopicModel *topic = [[V2TopicModel alloc] init];
//                topic.topicCreator = member;
                NSArray *aNotes = [secondNode findChildTags:@"a"];
                for (HTMLNode *aNode in aNotes) {
                    if ([aNode.rawContents rangeOfString:@"reply"].location != NSNotFound) {
                        topic.topicTitle = aNode.contents;
                        
                        NSString *topicURLString = [aNode getAttributeNamed:@"href"];
                        topicURLString = [topicURLString stringByReplacingOccurrencesOfString:@"/t/" withString:@""];
                        topic.topicId = [topicURLString componentsSeparatedByString:@"#"].firstObject;
                        NSString *replyCountString = [topicURLString componentsSeparatedByString:@"#"].lastObject;
                        replyCountString = [replyCountString stringByReplacingOccurrencesOfString:@"reply" withString:@""];
                        topic.topicReplyCount = replyCountString;
                        
                    }
                    
                }
                
                NSString *dateString = ((HTMLNode *)[secondNode findChildOfClass:@"snow"]).contents;
                //                NSArray *stringArray = [dateString componentsSeparatedByString:@" "];
                //                if (stringArray.count > 1) {
                //                    NSString *unitString = @"";
                //                    NSString *subString = [(NSString *)stringArray[1] substringToIndex:1];
                //                    if ([subString isEqualToString:@"分"]) {
                //                        unitString = @"m";
                //                    }
                //                    if ([subString isEqualToString:@"小"]) {
                //                        unitString = @"h";
                //                    }
                //                    if ([subString isEqualToString:@"天"]) {
                //                        unitString = @"d";
                //                    }
                //                    dateString = [NSString stringWithFormat:@"%@%@", stringArray[0], unitString];
                //                }
                model.notificationCreatedDescription = dateString;
                
                // description
                model.notificationContent = ((HTMLNode *)[secondNode findChildOfClass:@"payload"]).contents;
                
                if ([secondNode.rawContents rangeOfString:@"里提到了你"].location != NSNotFound) {
                    model.notificationDescriptionBefore = @" 在 ";
                    model.notificationDescriptionAfter = @" 里提到了你";
                }
                if ([secondNode.rawContents rangeOfString:@"里回复了你"].location != NSNotFound) {
                    model.notificationDescriptionBefore = @" 在 ";
                    model.notificationDescriptionAfter = @" 里回复了你";
                }
                if ([secondNode.rawContents rangeOfString:@"时提到了你"].location != NSNotFound) {
                    model.notificationDescriptionBefore = @" 在回复 ";
                    model.notificationDescriptionAfter = @" 时提到了你";
                }
                if ([secondNode.rawContents rangeOfString:@"感谢了你发布的主题"].location != NSNotFound) {
                    model.notificationDescriptionBefore = @" 感谢了你发布的主题 ";
                    model.notificationDescriptionAfter = @"";
                }
                if ([secondNode.rawContents rangeOfString:@"感谢了你在主题"].location != NSNotFound) {
                    model.notificationDescriptionBefore = @" 感谢了你在主题 ";
                    model.notificationDescriptionAfter = @" 里的回复";
                }
                if ([secondNode.rawContents rangeOfString:@"收藏了你发布的主题"].location != NSNotFound) {
                    model.notificationDescriptionBefore = @" 收藏了你发布的主题 ";
                    model.notificationDescriptionAfter = @"";
                }
                model.notificationMember = member;
                model.notificationTopic = topic;
                
                if (!model.notificationDescriptionBefore) {
                    model.notificationDescriptionBefore = @" ";
                }
                if (!model.notificationDescriptionAfter) {
                    model.notificationDescriptionAfter = @"";
                }
                
                // AttributedString
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
                
                NSAttributedString *nameAttributedString = [[NSAttributedString alloc] initWithString:model.notificationMember.memberName attributes:@{NSForegroundColorAttributeName: kFontColorBlackBlue, NSFontAttributeName: [UIFont boldSystemFontOfSize:15]}];
                [attributedString appendAttributedString:nameAttributedString];
                
                NSAttributedString *beforeAttributedString = [[NSAttributedString alloc] initWithString:model.notificationDescriptionBefore attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.700 alpha:1.000], NSFontAttributeName: [UIFont systemFontOfSize:15]}];
                [attributedString appendAttributedString:beforeAttributedString];
                
                NSString *topicTitleString = model.notificationTopic.topicTitle;
                if (topicTitleString.length > 25) {
                    topicTitleString = [topicTitleString substringToIndex:25];
                    topicTitleString = [topicTitleString stringByAppendingString:@"..."];
                }
                
                NSAttributedString *topicAttributedString = [[NSAttributedString alloc] initWithString:topicTitleString attributes:@{NSForegroundColorAttributeName: kFontColorBlackBlue, NSFontAttributeName: [UIFont systemFontOfSize:15]}];
                [attributedString appendAttributedString:topicAttributedString];
                
                NSAttributedString *afterAttributedString = [[NSAttributedString alloc] initWithString:model.notificationDescriptionAfter attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.700 alpha:1.000], NSFontAttributeName: [UIFont systemFontOfSize:15]}];
                [attributedString appendAttributedString:afterAttributedString];
                
                //                [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, attributedString.length)];
                
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
                
                model.notificationTopAttributedString = attributedString;
                
                if (model.notificationContent) {
                    NSAttributedString *descriptionAttributedString = [[NSAttributedString alloc] initWithString:model.notificationContent attributes:@{NSForegroundColorAttributeName: kFontColorBlackDark, NSFontAttributeName: [UIFont systemFontOfSize:15]}];
                    model.notificationDescriptionAttributedString = descriptionAttributedString;
                }
                
                [notificationArray addObject:model];
            }
            
        }
        
    }
    
    V2NotificationList *list;
    
    if (notificationArray.count) {
        list = [[V2NotificationList alloc] init];
        list.list = notificationArray;
    }
    
    return list;
}

@end