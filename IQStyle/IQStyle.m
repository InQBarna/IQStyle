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

#import "IQStyle.h"

static NSString *IQStyleDidChangeNotificationName = @"kIQStyleDidChangeNotificationName";

static NSDictionary         *__styleDictionary;
static NSMutableDictionary<NSString *, UIColor *>  *__colorCache;

static NSString *const IQStyleColorsKey = @"Colors";
static NSString *const IQStyleFontsKey = @"Fonts";

@implementation IQStyle

#pragma mark -
#pragma mark NSObject methods

+ (void)load {
    [super load];
    __colorCache = [NSMutableDictionary dictionary];
}

#pragma mark -
#pragma mark IQStyle methods

+ (NSDictionary *)styleDictionary
{
    return __styleDictionary;
}

+ (void)setStyleWithDictionary:(NSDictionary*)styleDictionary
{
    __styleDictionary = styleDictionary.copy;
    [[NSNotificationCenter defaultCenter] postNotificationName:IQStyleDidChangeNotificationName
                                                        object:nil];
}

+ (BOOL)validateStyleDictionary:(NSDictionary*)d
                      colorTags:(NSArray<NSString*>*)colorTags
                       fontTags:(NSArray<NSString*>*)fontTags
{
    BOOL result = YES;

    // FONTS
    NSDictionary *fonts = [d objectForKey:IQStyleFontsKey];
    
    // look for missing keys
    for(NSString *key in fontTags) {
        if(![fonts objectForKey:key]) {
            NSLog(@"Key '%@' not found in Fonts dictionary", key);
            result = NO;
        }
    }
    
    // look for unknown keys
    for(NSString *key in fonts.allKeys) {
        if(![fontTags containsObject:key]) {
            result = NO;
            NSLog(@"Unknown key '%@' in Fonts dictionary",key);
        }
    }

    // COLORS
    // look for missing keys
    NSDictionary *colors = [d objectForKey:IQStyleColorsKey];
    for(NSString *key in colorTags) {
        if(![colors objectForKey:key]) {
            NSLog(@"Key '%@' not found in Colors dictionary", key);
            result = NO;
        }
    }
    
    // look for unknown keys
    for(NSString *key in colors.allKeys) {
        if(![colorTags containsObject:key]) {
            result = NO;
            NSLog(@"Unknown key '%@' in Colors dictionary",key);
        }
    }
    
    return result;
}

+ (UIColor*)colorWithTag:(NSString*)tag {
    NSString *colorString = [[[self styleDictionary] objectForKey:IQStyleColorsKey] objectForKey:tag];
    NSAssert(colorString, @"No color defined for tag: %@", tag);
    UIColor *result;
    if(colorString) {
        result = [self cachedColorForString:colorString];
    }
    return result;
}

+ (UIFont*)fontWithTag:(NSString*)tag size:(CGFloat)size {
    NSString *fontName = [[[self styleDictionary] objectForKey:IQStyleFontsKey] objectForKey:tag];
    NSAssert(fontName, @"No font name for tag: %@", tag);
    UIFont *result;
    if(fontName) {
        result = [UIFont fontWithName:fontName size:size];
        NSAssert(result, @"Could not create font with name: %@", fontName);
    }

    return result;
    
}

+ (void)setColor:(UIColor*)color forTag:(NSString*)tag
{
    NSMutableDictionary *result = __styleDictionary.mutableCopy;
    NSDictionary *tmp = [result objectForKey:IQStyleColorsKey];
    NSMutableDictionary *colors = tmp.mutableCopy;
    
    if(color) {
        NSString *colorString = [color toString];
        [colors setObject:colorString forKey:tag];
    } else {
        [colors removeObjectForKey:tag];
    }
    
    [result setObject:colors.copy forKey:IQStyleColorsKey];
    __styleDictionary = result.copy;
    [[NSNotificationCenter defaultCenter] postNotificationName:IQStyleDidChangeNotificationName
                                                        object:nil];
}

+ (UIColor*)cachedColorForString:(NSString*)string {
    UIColor *result = [__colorCache objectForKey:string];
    if(!result) {
        result = [UIColor colorWithHexString:string];
        if(result) {
            [__colorCache setObject:result forKey:string];
        }
    }
    return result;
}

+ (NSArray<NSString *> *)fontTags
{
    NSDictionary *fonts = [__styleDictionary objectForKey:IQStyleFontsKey];
    return [NSArray arrayWithArray:fonts.allKeys];
}

+ (NSArray<NSString *> *)colorTags
{
    NSDictionary *colors = [__styleDictionary objectForKey:IQStyleColorsKey];
    return [NSArray arrayWithArray:colors.allKeys];
}

+ (NSString*)styleSheet
{
    NSMutableString *body = [NSMutableString string];
    
    NSDictionary *colors = [__styleDictionary objectForKey:IQStyleColorsKey];
    NSArray *sortedKeys = [colors.allKeys sortedArrayUsingSelector:@selector(compare:)];
    for(NSString *key in sortedKeys) {
        NSString *hex = [colors objectForKey:key];
        UIColor *color = [UIColor colorWithHexString:hex];
        NSString *html = color.htmlColor;
        
        NSString *tmp = [NSString stringWithFormat:@"\
\t\t<tr>\n\
\t\t\t<td><strong>%@</strong></br>%@</td>\n\
\t\t\t<td style='background-color:%@;'/>\n\
\t\t</tr>%@",
                         key,hex,
                         html,
                         key == sortedKeys.lastObject ? @"" : @"\n"];
        
        [body appendString:tmp];
    }
    
    NSString *result = [NSString stringWithFormat:
                        @"\
<html>\n\
\t<header>\n\
\t\t<style>\n\
\t\t\ttable, th, td {\n\
\t\t\t\tborder: 1px solid black;\n\
\t\t\t\tborder-collapse: collapse;\n\
\t\t\t}\n\
\t\t\tth, td {\n\
\t\t\t\tpadding: 10px;\n\
\t\t\t}\n\
\t\t</style>\n\
\t</header>\n\
<body>\n\
\t<table style=\"width:100%%\">\n\
%@\n\
\t</table>\n\
</body>\n\
</html>\n", body];
    
    return result;
}

@end

@implementation NSObject(C5Style)

- (void)registerForStyleChanges
{
    if([self respondsToSelector: @selector(styleDidChange)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(styleDidChange)
                                                     name:IQStyleDidChangeNotificationName
                                                   object:nil];
    }
}

- (void)unregisterForStyleChanges
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IQStyleDidChangeNotificationName
                                                  object:nil];
}

@end
