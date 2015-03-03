//
//  NSString+SCMention.m
//  newSponia
//
//  Created by Singro on 3/26/14.
//  Copyright (c) 2014 Sponia. All rights reserved.
//

#import "NSString+SCMention.h"

#import "SCQuote.h"
#import <RegexKitLite.h>
#import <HTMLParser.h>

@implementation NSString (SCMention)

- (NSString *)enumerateMetionObjectsUsingBlock:(void (^)(id object, NSRange range))block {
    
    NSString *regex1 = @"\\[(.*?)\\]";
    
    NSMutableArray *ranges = [[NSMutableArray alloc] init];
    
    [self enumerateStringsMatchedByRegex:regex1 usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        [ranges addObject:[NSValue valueWithRange:*capturedRanges]];
        
    }];
    
    NSString *plainString = @"";
    
    if (ranges.count) {
        NSUInteger rangeIndex = 0;
        for (NSValue *value in ranges) {
            
            NSRange range = [value rangeValue];
            
            if (rangeIndex < range.location) {
                NSRange stringRange = (NSRange){rangeIndex, range.location - rangeIndex};
                NSString *normalString = [self substringWithRange:stringRange];
                stringRange.location = plainString.length;
                plainString = [plainString stringByAppendingString:normalString];
                block(normalString, stringRange);
                
            }
            
            NSString *quoteString = [self substringWithRange:range];
            
            NSArray *quoteArray = [quoteString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[()]"]];
            
            if (quoteArray.count == 5) {

                SCQuote *quote = [[SCQuote alloc] init];
                quote.string = @"";

                if ([quoteArray[1] isEqualToString:@"user"]) {
                    quote.type = SCQuoteTypeUser;
                    quote.identifier = quoteArray[2];
                    quote.string = quoteArray[3];
                } else if ([quoteArray[1] isEqualToString:@"url"]) {
                    quote.type = SCQuoteTypeLink;
                    quote.identifier = quoteArray[2];
                    quote.string = quoteArray[3];
                } else if ([quoteArray[1] isEqualToString:@"image"]) {
                    quote.type = SCQuoteTypeImage;
                    quote.identifier = quoteArray[2];
                    quote.string = quoteArray[3];
                }
                
                else {
                    quote.type = SCQuoteTypeNone;
                    quote.string = quoteString;
                }

                NSRange quoteRange = NSMakeRange(plainString.length, quote.string.length);
                quote.range = quoteRange;
                plainString = [plainString stringByAppendingString:quote.string];
                block(quote, quoteRange);
            } else {
                NSRange stringRange = NSMakeRange(plainString.length, plainString.length);
                plainString = [plainString stringByAppendingString:quoteString];
                block(quoteString, stringRange);
            }
            
            rangeIndex = range.location + range.length;
            
        }
        
        NSRange lastRange = [ranges.lastObject rangeValue];
        
        if (lastRange.location + lastRange.length < self.length && ranges.count) {
            
            NSRange lastStringRange = (NSRange){lastRange.location + lastRange.length, self.length - lastRange.location - lastRange.length};
            NSString *lastString = [self substringWithRange:lastStringRange];
            plainString = [plainString stringByAppendingString:lastString];
            block(lastString, NSMakeRange(plainString.length - lastString.length, lastString.length));
            
        }
        
    } else {
        block(self, NSMakeRange(0, plainString.length));
    }

    return plainString;
}

- (NSString *)metionPlainString {
    
    NSString *regex1 = @"\\[(.*?)\\]";
    
    NSMutableArray *ranges = [[NSMutableArray alloc] init];
    
    [self enumerateStringsMatchedByRegex:regex1 usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        
        [ranges addObject:[NSValue valueWithRange:*capturedRanges]];
        
    }];
    
    NSString *plainString = @"";
    
    if (ranges) {
        NSUInteger rangeIndex = 0;
        for (NSValue *value in ranges) {
            
            NSRange range = [value rangeValue];
            
            if (rangeIndex < range.location) {
                NSRange rangeString = (NSRange){rangeIndex, range.location - rangeIndex};
                NSString *normalString = [self substringWithRange:rangeString];
                plainString = [plainString stringByAppendingString:normalString];
                
            }
            
            NSString *quoteString = [self substringWithRange:range];
            
            NSArray *quoteArray = [quoteString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[()]"]];
            
            if (quoteArray.count == 5) {
                
                NSString *quoteString = @"";
                
                if ([quoteArray[1] isEqualToString:@"user"]) {
                    quoteString = quoteArray[3];
                } else {
                    quoteString = @"";
                }
                
                plainString = [plainString stringByAppendingString:quoteString];
            }
            
            rangeIndex = range.location + range.length;
            
        }
        
        NSRange lastRange = [ranges.lastObject rangeValue];
        
        if (lastRange.location + lastRange.length < self.length) {
            
            NSRange lastStringRange = (NSRange){lastRange.location + lastRange.length, self.length - lastRange.location - lastRange.length};
            NSString *lastString = [self substringWithRange:lastStringRange];
            plainString = [plainString stringByAppendingString:lastString];
            
        }
        
    } else {
        plainString = self;
    }
    
    return plainString;
}

- (NSString *)mentionStringFromHtmlString:(NSString *)htmlString {
    
    NSString *mentionString;
    
    @autoreleasepool {
        
        mentionString = [htmlString stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
        while ([mentionString rangeOfString:@"\n\n"].location != NSNotFound) {
            mentionString = [mentionString stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
        }
        
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:[NSString stringWithFormat:@"<body>%@</body>", htmlString] error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
        }
        
        HTMLNode *bodyNode = [parser body];
        mentionString = bodyNode.allContents;

        NSArray *aNodes = [bodyNode findChildTags:@"a"];
        
        for (HTMLNode *aNode in aNodes) {
            
            NSString *hrefString = [aNode getAttributeNamed:@"href"];
            NSLog(@"href:  %@", hrefString);
            
            if ([hrefString hasPrefix:@"/member/"]) {
                NSString *identifier = [hrefString stringByReplacingOccurrencesOfString:@"/member/" withString:@""];
                mentionString = [mentionString stringByReplacingOccurrencesOfString:aNode.allContents withString:[NSString stringWithFormat:@"[user(%@)%@]", identifier, identifier]];
            }
            
            if ([hrefString hasSuffix:@"jpeg"] ||
                [hrefString hasSuffix:@"png"] ||
                [hrefString hasSuffix:@"jpg"] ||
                [hrefString hasSuffix:@"gif"]) {
                
                NSString *identifier = hrefString;
                
                HTMLNode *imageNode = [aNode findChildTag:@"img"];
                identifier = [imageNode getAttributeNamed:@"src"];
                
                NSLog(@"raw:%@", aNode.rawContents);

                mentionString = [mentionString stringByReplacingOccurrencesOfString:aNode.allContents withString:[NSString stringWithFormat:@"[image(%@)%@]", identifier, hrefString]];
            }
            
            if ([hrefString hasPrefix:@"/t/"]) {
                NSString *identifier = [hrefString stringByReplacingOccurrencesOfString:@"/t/" withString:@""];
                mentionString = [mentionString stringByReplacingOccurrencesOfString:aNode.allContents withString:[NSString stringWithFormat:@"[topic(%@)%@]", identifier, hrefString]];
            }

        }

    }
    
    
    return mentionString;
}

- (NSArray *)quoteArray {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        
        NSString *mentionString = self;

//        mentionString = [self stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
//        while ([mentionString rangeOfString:@"\n\n"].location != NSNotFound) {
//            mentionString = [mentionString stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
//        }
        
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:[NSString stringWithFormat:@"<body>%@</body>", self] error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
        }
        
        HTMLNode *bodyNode = [parser body];
        mentionString = bodyNode.allContents;
        
        NSArray *aNodes = [bodyNode findChildTags:@"a"];
        
        for (HTMLNode *aNode in aNodes) {
            
            NSString *hrefString = [aNode getAttributeNamed:@"href"];
            
            SCQuote *quote = [[SCQuote alloc] init];
            
            if ([hrefString hasPrefix:@"/member/"]) {
                NSString *identifier = [hrefString stringByReplacingOccurrencesOfString:@"/member/" withString:@""];
                quote.identifier = identifier;
                quote.string = identifier;
                quote.type = SCQuoteTypeUser;
                
            }
            
            if ([hrefString hasPrefix:@"/t/"]) {
                NSString *identifier = [hrefString stringByReplacingOccurrencesOfString:@"/t/" withString:@""];
                quote.identifier = identifier;
                quote.string = aNode.allContents;
                quote.type = SCQuoteTypeTopic;
                
            }

            if ([hrefString hasPrefix:@"mailto:"]) {
                NSString *identifier = [hrefString stringByReplacingOccurrencesOfString:@"mailto:" withString:@""];
                quote.identifier = identifier;
                quote.string = identifier;
                quote.type = SCQuoteTypeEmail;
                
            }
            
            if ([hrefString hasSuffix:@"jpeg"] ||
                [hrefString hasSuffix:@"png"] ||
                [hrefString hasSuffix:@"jpg"] ||
                [hrefString hasSuffix:@"gif"]) {
                
                NSString *identifier = hrefString;
                
                HTMLNode *imageNode = [aNode findChildTag:@"img"];
                identifier = [imageNode getAttributeNamed:@"src"];
                
                if (!identifier) {
                    identifier = hrefString;
                }
                
                quote.string = identifier;

                if ([identifier rangeOfString:@"http://www.v2ex.com/i/"].location != NSNotFound) {
                    identifier = [identifier stringByReplacingOccurrencesOfString:@"http://www.v2ex.com/i/" withString:@"http://i.v2ex.co/"];
                }
                
                quote.identifier = identifier;
                quote.type = SCQuoteTypeImage;

            }
            
            if ([hrefString rangeOfString:@"v2ex.com/t/"].location != NSNotFound) {
                NSString *identifier = [hrefString componentsSeparatedByString:@"v2ex.com/t/"].lastObject;
                identifier = [identifier componentsSeparatedByString:@"#"].firstObject;
                
                quote.identifier = identifier;
                quote.string = aNode.allContents;
                quote.type = SCQuoteTypeTopic;

            }
            
//            if ([hrefString rangeOfString:@"v2ex.com/go/"].location != NSNotFound) {
//                NSString *identifier = [hrefString componentsSeparatedByString:@"v2ex.com/go/"].lastObject;
//                
//                quote.identifier = identifier;
//                quote.string = [NSString stringWithFormat:@"/go/%@", identifier];
//                quote.type = SCQuoteTypeNode;
//                
//            }
//
            if ([hrefString rangeOfString:@"itunes.apple.com"].location != NSNotFound) {
                quote.identifier = hrefString;
                quote.string = hrefString;
                quote.type = SCQuoteTypeAppStore;
            }

            if (quote.type == SCQuoteTypeNone) {
                quote.identifier = hrefString;
                quote.string = hrefString;
                quote.type = SCQuoteTypeLink;
            }
            
            quote.identifier = [quote.identifier stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            quote.string = [quote.string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (!quote.identifier) {
                quote.identifier = hrefString;
            }
            if (!quote.string) {
                quote.string = hrefString;
            }
            [array addObject:quote];
            
        }
        
//        NSArray *embedNodes = [bodyNode findChildTags:@"embed"];
//
//        for (HTMLNode *embedNode in embedNodes) {
//            
//            NSString *srcString = [embedNode getAttributeNamed:@"src"];
//            srcString = [srcString componentsSeparatedByString:@"?"].firstObject;
//            
//            SCQuote *quote = [[SCQuote alloc] init];
//            
//            if (srcString.length >  0) {
//                quote.identifier = srcString;
//                quote.string = srcString;
//                quote.type = SCQuoteTypeVedio;
//                
//            }
//            
//            if (quote.type == SCQuoteTypeNone) {
//                quote.identifier = srcString;
//                quote.string = srcString;
//                quote.type = SCQuoteTypeLink;
//            }
//            
//            quote.identifier = [quote.identifier stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            quote.string = [quote.string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            [array addObject:quote];
//            
//        }
        
    }
    
    
    return array;
    
}



@end
