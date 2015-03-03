//
//  SCMetionTextView.h
//  SCMetionTextView
//
//  Created by Singro on 3/14/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCQuote.h"

@interface SCMetionTextView : UITextView

@property (nonatomic, copy) UIColor *textBackgroundColor;

@property (nonatomic, readonly) UILabel *placeHolderLabel;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic, copy) BOOL (^textViewShouldBeginEditingBlock)(UITextView *textView);
@property (nonatomic, copy) BOOL (^textViewShouldChangeBlock)(UITextView *textView, NSString *text);
@property (nonatomic, copy) void (^textViewDidChangeBlock)(UITextView *textView);

@property (nonatomic, copy) void (^textViewDidAddQuoteSuccessBlock)();

// getter
@property (nonatomic, copy) NSString *renderedString;

- (void)addQuote:(SCQuote *)quote;

- (void)setNeedsRefreshQuotes;

- (void)removeAllQuotes;

@end
