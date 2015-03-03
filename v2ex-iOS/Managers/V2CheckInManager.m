//
//  V2CheckInManager.m
//  v2ex-iOS
//
//  Created by Singro on 7/6/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2CheckInManager.h"

#define userDefaults [NSUserDefaults standardUserDefaults]

static NSString *const kLastCheckInDate = @"lastCheckInDate";
static NSString *const kCheckInCount    = @"checkInCount";

@interface V2CheckInManager () {
    BOOL _expired;
}

@property (nonatomic, strong) NSDate *lastCheckInDate;

@end

@implementation V2CheckInManager

- (instancetype)init {
    if (self = [super init]) {
        
        [self updateStatus];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];

    }
    return self;
}

+ (instancetype)manager {
    static V2CheckInManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[V2CheckInManager alloc] init];
    });
    return manager;
}

#pragma mark - Handle Status

- (void)updateStatus {
    
    _lastCheckInDate = [userDefaults objectForKey:kLastCheckInDate];
    _checkInCount = [[userDefaults objectForKey:kCheckInCount] integerValue];
    
    [self updateExpired];
    
    id checkInCountObject = [userDefaults objectForKey:kCheckInCount];
    if (!checkInCountObject) {
        [self updateCheckInCount];
    }
    
    if (_expired) {
        [self updateIsCheckIn];
    }

}

- (void)removeStatus {
    
    [userDefaults removeObjectForKey:kLastCheckInDate];
    [userDefaults removeObjectForKey:kCheckInCount];
    _lastCheckInDate = nil;
    _checkInCount = 0;
    _expired = YES;

}

- (void)resetStatus {
    [self removeStatus];
    [self updateStatus];
}

#pragma mark - Getter

- (BOOL)isExpired {
    return _expired;
}

#pragma mark - Setters

- (void)setExpired:(BOOL)expired {
    _expired = expired;
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCheckInBadgeNotification object:nil];
}

- (void)setCheckInCount:(NSInteger)checkInCount {
    _checkInCount = checkInCount;
    
    [userDefaults setObject:@(checkInCount) forKey:kCheckInCount];
    
}

- (void)setLastCheckInDate:(NSDate *)lastCheckInDate {
    
    _lastCheckInDate = lastCheckInDate;
    
    [self updateExpired];
    [userDefaults setObject:lastCheckInDate forKey:kLastCheckInDate];

}

#pragma mark - Data Methods

- (void)updateIsCheckIn {
    
    @weakify(self);
    [[V2DataManager manager] getCheckInURLSuccess:^(NSURL *URL) {
        @strongify(self);
        
        if ([URL.absoluteString rangeOfString:@"mission/daily/redeem"].location != NSNotFound) {
            self.expired = YES;
        } else {
            self.lastCheckInDate = [NSDate date];
            self.expired = NO;
        }
        
    } failure:^(NSError *error) {
        ;
    }];
    
}

- (void)updateCheckInCount {
    
    @weakify(self);
    [[V2DataManager manager] getCheckInCountSuccess:^(NSInteger count) {
        @strongify(self);
        self.checkInCount = count;
    } failure:^(NSError *error) {
        ;
    }];
    
}

- (void)updateExpired {
    
    if (!self.lastCheckInDate) {
        _expired = YES;
        return;
    }
    
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [utcDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [utcDateFormatter stringFromDate:[NSDate date]];
    dateString = [dateString stringByAppendingString:@" 00:00:00"];
    
    [utcDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *startDate = [utcDateFormatter dateFromString:dateString];
    
    NSTimeInterval interval = [self.lastCheckInDate timeIntervalSinceDate:startDate];
    if (interval > 0) {
        _expired = NO;
        return;
    }
    
    _expired = YES;

}

- (NSURLSessionDataTask *)checkInSuccess:(void (^)(NSInteger count))success
                                 failure:(void (^)(NSError *error))failure {
    
    @weakify(self);
    [[V2DataManager manager] getCheckInURLSuccess:^(NSURL *URL) {
        @strongify(self);
        
        if ([URL.absoluteString rangeOfString:@"/balance"].location != NSNotFound) {
            [[V2DataManager manager] getCheckInCountSuccess:^(NSInteger count) {
                @strongify(self);
                self.checkInCount = count;
                success(count);
            } failure:^(NSError *error) {
                failure(error);
            }];
        } else {
            [[V2DataManager manager] checkInWithURL:URL Success:^(NSInteger count) {
                @strongify(self);
                self.lastCheckInDate = [NSDate date];
                self.checkInCount = count;
                success(count);
            } failure:^(NSError *error) {
                failure(error);
            }];
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return nil;
}

#pragma mark - Notifications

- (void)didReceiveEnterForegroundNotification {
    
    [self updateExpired];
    
    if (self.isExpired) {
        [self updateIsCheckIn];
    }
    
}

@end
