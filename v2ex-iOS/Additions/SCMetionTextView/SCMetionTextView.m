//
//  SCMetionTextView.m
//  SCMetionTextView
//
//  Created by Singro on 3/14/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCMetionTextView.h"

@interface SCMetionTextView () <UITextViewDelegate>

@property (nonatomic, readwrite, strong) UILabel *placeHolderLabel;

@property (nonatomic, strong) NSMutableArray *quoteArray;

@property (nonatomic, assign) NSInteger didChangeLength;

@property (nonatomic, assign) BOOL hasChange;
@property (nonatomic, assign) BOOL isInit;

// Test
@property (nonatomic, strong) UIView *quoteView;

@end

@implementation SCMetionTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    NSTextStorage* textStorage = [[NSTextStorage alloc] init];
    NSLayoutManager* layoutManager = [NSLayoutManager new];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:frame.size];
    [layoutManager addTextContainer:textContainer];
    self = [super initWithFrame:frame textContainer:textContainer];
    
    if (self)
    {
        self.inputAccessoryView = [[UIView alloc] init];
        
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
        
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    
    // Init
    self.hasChange = NO;
    self.isInit = YES;
    
    self.delegate = self;
    
    self.quoteArray = [[NSMutableArray alloc] init];
    
    self.textBackgroundColor = [UIColor colorWithRed:0.188 green:0.662 blue:1.000 alpha:0.150];
    self.placeholderColor = [UIColor lightGrayColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods

- (NSString *)renderedString {
    
    NSString *textString = self.text;
    
    for (int i = 0; i < self.quoteArray.count; i ++) {
        
        SCQuote *quote = self.quoteArray[i];
        
        NSString *repalceString;
        if (quote.type == SCQuoteTypeUser) {
            repalceString = [NSString stringWithFormat:@"@%@ ", quote.string];
        } else if (quote.type == SCQuoteTypeImage) {
            repalceString = [NSString stringWithFormat:@"\n%@\n", quote.identifier];
        } else {
            repalceString = [NSString stringWithFormat:@"%@", quote.string];
        }
        NSInteger addedLength = repalceString.length - quote.string.length - 2;
        
        NSRange quoteStringRange = quote.range;
        quoteStringRange.location -= 1;
        quoteStringRange.length += 2;
        textString = [textString stringByReplacingCharactersInRange:quoteStringRange withString:repalceString];
        
        for (int j = i+1; j < self.quoteArray.count; j ++) {
            
            SCQuote *restQuote = self.quoteArray[j];
            restQuote.range = NSMakeRange(restQuote.range.location + addedLength, restQuote.range.length);
            
        }
        
    }
    
    return textString;
}

- (void)setNeedsRefreshQuotes {
    
    for (SCQuote *qoute in self.quoteArray) {
        [self setBackgroundFrameForQuote:qoute];
    }
    
}

#pragma mark - Quote Methods

- (void)addQuote:(SCQuote *)quote {
    
    quote.range = NSMakeRange(self.text.length, quote.string.length + 2);
    
    self.text = [self.text stringByAppendingString:[NSString stringWithFormat:@" %@  ", quote.string]];
    
    [self.quoteArray addObject:quote];
    //    [self setBackgroundFrameForQuote:quote];
    [self updateQuotes];
    
}

- (void)removeQuote:(SCQuote *)quote {
    
    if (self.text.length > 1) {
        self.text = [self.text stringByReplacingCharactersInRange:quote.range withString:@""];
    }
    [self disableQuote:quote];
    
}

- (void)disableQuote:(SCQuote *)quote {
    
    for (UIView *backgroundView in quote.backgroundArray) {
        [backgroundView removeFromSuperview];
    }
    [self.quoteArray removeObject:quote];
    
}

- (void)removeAllQuotes {
    
    for (SCQuote *quote in self.quoteArray) {
        for (UIView *quoteView in quote.backgroundArray) {
            [quoteView removeFromSuperview];
        }
    }
    [self.quoteArray removeAllObjects];
    self.text = @"";
    
}

#pragma mark - TextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.textViewShouldBeginEditingBlock) {
        return self.textViewShouldBeginEditingBlock(textView);
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //    SPLog(@"range: %@   text: %@", NSStringFromRange(range), text);
    
    if (self.textViewShouldChangeBlock) {
        if (!self.textViewShouldChangeBlock(textView, text)) {
            return NO;
        };
    }
    self.isInit = NO;
    
    //    NSLog(@"length: %d", range.length);
    
    if (range.length == 1) {
        SCQuote *quote = [self quoteInRange:range];
        if (quote) {
            if (range.length + range.location == quote.range.length + quote.range.location) {
                [self removeQuote:quote];
            }
        }
    }
    
    if (range.length == 0) {
        SCQuote *quote = [self quoteInRange:range];
        if (quote) {
            [self removeQuote:quote];
            //            self.text = [self.text stringByAppendingString:@" "];
        }
    }
    
    CGRect textRect = [textView.layoutManager usedRectForTextContainer:textView.textContainer];
    CGFloat sizeAdjustment = textView.font.lineHeight * [UIScreen mainScreen].scale;
    
    if (textRect.size.height >= textView.frame.size.height - sizeAdjustment) {
        if ([text isEqualToString:@"\n"]) {
            [UIView animateWithDuration:0.2 animations:^{
                [textView setContentOffset:CGPointMake(textView.contentOffset.x, textView.contentOffset.y + sizeAdjustment)];
            }];
        }
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (!textView.text.length) {
        for (SCQuote *quote in self.quoteArray) {
            [self removeQuote:quote];
        }
    } else {
        [self updateQuotes];
    }
    
    if (self.textViewDidChangeBlock) {
        self.textViewDidChangeBlock(textView);
    }
    
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    static NSRange lastSelectedRange = (NSRange){0, 0};
    SCQuote *quote = [self quoteInRange:self.selectedRange];
    if (quote) {
        if (lastSelectedRange.location < quote.range.location) {
            [self setSelectedRange:(NSRange){quote.range.location, 0}];
        } else {
            [self setSelectedRange:(NSRange){quote.range.location + quote.range.length, 0}];
        }
        lastSelectedRange = self.selectedRange;
    }
    
    //    [textView scrollRangeToVisible:textView.selectedRange];
    
}

#pragma mark - Placeholder Methods
- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if ( self.placeHolderLabel == nil )
        {
            self.placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(3,9,self.bounds.size.width - 16,0)];
            self.placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
            self.placeHolderLabel.numberOfLines = 0;
            self.placeHolderLabel.font = self.font;
            self.placeHolderLabel.backgroundColor = [UIColor clearColor];
            self.placeHolderLabel.textColor = self.placeholderColor;
            self.placeHolderLabel.alpha = 0;
            self.placeHolderLabel.tag = 999;
            [self addSubview:self.placeHolderLabel];
        }
        
        self.placeHolderLabel.text = self.placeholder;
        [self.placeHolderLabel sizeToFit];
        [self sendSubviewToBack:self.placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

#pragma mark - Private Methods

- (void)updateQuotes {
    
    for (SCQuote *qoute in self.quoteArray) {
        [self setBackgroundFrameForQuote:qoute];
    }
}

- (void)setBackgroundFrameForQuote:(SCQuote *)quote {
    
    if (!quote.backgroundArray.count) {
        quote.backgroundArray = [[NSMutableArray alloc] init];
        UIView *backView1 = [self createTextBackgroundView];
        UIView *backView2 = [self createTextBackgroundView];
        [quote.backgroundArray addObject:backView1];
        [quote.backgroundArray addObject:backView2];
    } else {
        for (UIView *view in quote.backgroundArray) {
            view.hidden = YES;
        }
    }
    NSArray *frameArray = [self framesOfQuote:quote];
    for (int i = 0; i < quote.backgroundArray.count; i ++) {
        UIView *quoteBackgroundView = quote.backgroundArray[i];
        quoteBackgroundView.hidden = NO;
        if (frameArray.count > i) {
            quoteBackgroundView.frame = [frameArray[i] CGRectValue];
        }
    }
    
    
}

- (SCQuote *)quoteInRange:(NSRange)range {
    
    for (SCQuote *quote in self.quoteArray) {
        NSRange quoteRange = quote.range;
        //        quoteRange.location += 1;
        //        quoteRange.length -= 2;
        if (NSIntersectionRange(quoteRange, range).length > 0) {
            return quote;
        }
        if (range.location > quoteRange.location && range.location < quoteRange.location + quoteRange.length) {
            return quote;
        }
    }
    
    return nil;
}

- (NSArray *)framesOfQuote:(SCQuote *)quote {
    return [self framesFromRange:[self rangeOfQuote:quote]];
}

- (NSRange)rangeOfQuote:(SCQuote *)quote {
    
    const NSInteger length = [self offsetFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    NSRange searchRange = NSMakeRange(0, length);
    
    NSString *string = self.text;
    NSString *quoteString = quote.string;
    NSRange returnRange = NSMakeRange(NSNotFound, 0);
    @autoreleasepool {
        NSMutableArray *ranges = [[NSMutableArray alloc] init];
        NSRange range = [string rangeOfString:quoteString options:NSCaseInsensitiveSearch range:searchRange];
        while (range.location != NSNotFound) {
            [ranges addObject:[NSValue valueWithRange:range]];
            searchRange.location = range.location + range.length;
            NSInteger searchLength = (NSInteger)length - (NSInteger)searchRange.location;
            searchRange.length = length - searchRange.location;
            //            NSLog(@"search:  %d", searchLength);
            //            NSLog(@"length:  %d", length);
            if (searchLength <= length && searchLength > 0) {
                range = [string rangeOfString:quoteString options:NSCaseInsensitiveSearch range:searchRange];
            } else {
                range.location = NSNotFound;
            }
        }
        if (ranges.count == 1) {
            returnRange = [ranges.firstObject rangeValue];
        }
        //        NSLog(@"quoteIndex:  %d", ranges.count);
        if (ranges.count > 1) {
            NSInteger quoteIndex = 0;
            NSInteger findCount = -1;
            //            NSLog(@"quoteIndex:  %d", self.quoteArray.count);
            for (int i = 0; i < self.quoteArray.count; i ++) {
                SCQuote *tempQuote = self.quoteArray[i];
                if ([tempQuote.string isEqualToString:quoteString]) {
                    findCount += 1;
                }
                if ([tempQuote isEqual:quote]) {
                    quoteIndex = findCount;
                    break;
                }
            }
            //            NSLog(@"quoteIndex:  %d", quoteIndex);
            returnRange = [ranges[quoteIndex] rangeValue];
        }
    }
    
    quote.range = returnRange;
    
    return returnRange;
}

- (NSArray *)framesFromRange:(NSRange)range
{
    NSMutableArray *frameArray = [[NSMutableArray alloc] initWithCapacity:2];
    
    CGRect firstFrame = [self frameFromRange:range];
    
    NSInteger linebreakIndex = 0;
    
    for (int i = 0; i < range.length; i ++) {
        NSRange tempRange = NSMakeRange(range.location + i, 1);
        CGRect tempFrame = [self frameFromRange:tempRange];
        if (tempFrame.origin.x < firstFrame.origin.x && !linebreakIndex) {
            linebreakIndex = i;
        }
    }
    
    if (linebreakIndex) {
        NSRange tempRange1 = NSMakeRange(range.location, linebreakIndex);
        CGRect frame1 = [self frameFromRange:tempRange1];
        frame1.origin.y += 2;
        frame1.origin.x -= 5;
        frame1.size.height -= 3;
        frame1.size.width += 8;
        
        NSRange tempRange2 = NSMakeRange(range.location + linebreakIndex, range.length - linebreakIndex);
        CGRect frame2 = [self frameFromRange:tempRange2];
        frame2.origin.y += 2;
        frame2.origin.x -= 5;
        frame2.size.height -= 3;
        frame2.size.width += 8;
        
        [frameArray addObjectsFromArray:@[[NSValue valueWithCGRect:frame1], [NSValue valueWithCGRect:frame2]]];
    } else {
        firstFrame.origin.y += 2;
        firstFrame.origin.x -= 5;
        firstFrame.size.height -= 3;
        firstFrame.size.width += 8;
        [frameArray addObject:[NSValue valueWithCGRect:firstFrame]];
    }
    
    return frameArray;
}

- (CGRect)frameFromRange:(NSRange)range {
    
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *start = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [self positionFromPosition:start offset:range.length];
    CGRect frame =[self frameFromTextPosition:start toPosition:end];
    
    return frame;
}

- (CGRect)frameFromTextPosition:(UITextPosition *)start toPosition:(UITextPosition *)end {
    
    UITextRange *textRange = [self textRangeFromPosition:start toPosition:end];
    CGRect rect = [self firstRectForRange:textRange];
    CGRect frame =[self convertRect:rect toView:self];
    //    NSLog(@"rect:   %@", NSStringFromCGRect(rect));
    
    return frame;
}

- (UIView *)createTextBackgroundView {
    
    UIView *textBackgroundView = [[UIView alloc] init];
    textBackgroundView.layer.cornerRadius = 2.0;
    textBackgroundView.clipsToBounds = YES;
    textBackgroundView.backgroundColor = self.textBackgroundColor;
    [self addSubview:textBackgroundView];
    [self sendSubviewToBack:textBackgroundView];
    
    return textBackgroundView;
}

@end
