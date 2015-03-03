
#import <Foundation/Foundation.h>

@interface V2Helper : NSObject

/**
 *  Time & date
 */
+ (NSArray *)localDateStringWithUTCString:(NSString *)dateString;

+ (NSArray *)localDateStringWithUTCString:(NSString *)dateString Separation:(NSString *)separation;

+ (NSTimeInterval)timeIntervalWithUTCString:(NSString *)dateString;

+ (NSString *)timeRemainDescriptionWithTimeInterval:(NSTimeInterval)interval;

+ (NSString *)timeRemainDescriptionWithUTCString:(NSString *)dateString;

+ (NSString *)timeRemainDescriptionWithDateSP:(NSNumber *)dateSP;

+ (CGFloat)getTextWidthWithText:(NSString *)text Font:(UIFont *)font;

+ (CGFloat)getTextHeightWithText:(NSString *)text Font:(UIFont *)font Width:(CGFloat)width;


/**
 *  Other
 */

+ (NSString *)encodeUrlString:(NSString *)urlString;

+ (UIImage *)getImageFromView:(UIView *)view;

+ (UIImage *)getImageWithColor:(UIColor *)color;

+ (UIImage *)getImageWithColor:(UIColor *)color size:(CGSize)size;


/**
 *  Setting
 */

+ (UIImage *)getUserAvatarDefaultFromGender:(NSInteger)gender;


@end



