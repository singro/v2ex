//
//  V2TopicCreateViewController.h
//  v2ex-iOS
//
//  Created by Singro on 5/1/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2TopicCreateViewController : UIViewController

@property (nonatomic, copy) NSString *nodeName;

@end


static NSString * const kTopicCreateSuccessNotification = @"TopicCreateSuccessNotification";
