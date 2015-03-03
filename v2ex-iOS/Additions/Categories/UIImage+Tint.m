//
//  UIImage+Tint.m
//
//  Created by Matt Gemmell on 04/07/2010.
//  Copyright 2010 Instinctive Code.
//

#import "UIImage+Tint.h"


@implementation UIImage (MGTint)


- (UIImage *)imageTintedWithColor:(UIColor *)color
{
	if (color) {
		// Construct new image the same size as this one.
		UIImage *image;
		UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
		CGRect rect = CGRectZero;
		rect.size = [self size];
		
		// tint the image
		[self drawInRect:rect];
		[color set];
		UIRectFillUsingBlendMode(rect, kCGBlendModeColor);
		
		// restore alpha channel
		[self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
		
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return image;
	}
	
	return self;
	
}



@end
