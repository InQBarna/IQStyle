//
// Author: David Romacho <david.romacho@inqbarna.com>
//
// Copyright (c) 2016 InQBarna Kenkyuu Jo (http://inqbarna.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIColor+IQStyle.h"
#import "IQStyle.h"

@implementation UIColor (IQStyle)

+ (UIColor*)colorWithTag:(NSString*)tag
{
    return [IQStyle colorWithTag:tag];
}

+ (UIColor*)colorWithHexString: (NSString *) stringToConvert {
    
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 8 or 10 characters
    if ([cString length] < 8) return [UIColor blackColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    
    if ([cString length] != 8) {
        return [UIColor blackColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    NSString *aString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 6;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int a,r, g, b;
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((CGFloat) r / 255.0f)
                           green:((CGFloat) g / 255.0f)
                            blue:((CGFloat) b / 255.0f)
                           alpha:((CGFloat) a / 255.0f)];
}

+ (UIColor*)randomColor {
    return [UIColor colorWithRed:(rand()%256)/255.0f
                           green:(rand()%256)/255.0f
                            blue:(rand()%256)/255.0f
                           alpha:1.0f];
    
}

- (NSString*)htmlColor {
    CGFloat r,g,b,a;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    NSString *result = [NSString stringWithFormat:@"#%02x%02x%02x",
                        (int)round(r * 255.0f),
                        (int)round(g * 255.0f),
                        (int)round(b * 255.0f)];
    
    return result;
}

- (NSString*)toString {
    CGFloat r,g,b,a;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    
    NSString *result = [NSString stringWithFormat:@"0x%02x%02x%02x%02x",
                        (int)round(a * 255.0f),
                        (int)round(r * 255.0f),
                        (int)round(g * 255.0f),
                        (int)round(b * 255.0f)];
    
    return result;
}

- (UIColor*)inverted
{
    CGFloat r,g,b,a;
    
    [self getRed:&r green:&g blue:&b alpha:&a];

    UIColor *result = [UIColor colorWithRed:(1.0f - r)
                                      green:(1.0f - g)
                                       blue:(1.0f - b)
                                      alpha:a];
    
    return result;
}

@end
