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

#import <objc/runtime.h>
#import "UIView+IQStyle.h"
#import "IQStyle.h"

@implementation UIView(IQStyle)

#pragma mark -
#pragma mark Font Tag methods
@dynamic fontTag;

- (void)setFontTag:(NSString *)fontTag {
    objc_setAssociatedObject(self, @selector(fontTag), fontTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateFontFromTag];
}

- (NSString*)fontTag {
    return objc_getAssociatedObject(self, @selector(fontTag));
}

- (void)updateFontFromTag {
    NSString *tag = self.fontTag;
    if(!tag) {
        return;
    }
    if([self respondsToSelector:@selector(setFont:)]) {
        CGFloat pointSize = [[self valueForKeyPath:@"font.pointSize"] floatValue];
        UIFont *font = [IQStyle fontWithTag:self.fontTag size:pointSize];
        if(font) {
            [self setValue:font forKey:@"font"];
        }
    }
}

#pragma mark -
#pragma mark Background Color Tag methods
@dynamic backgroundColorTag;

- (void)setBackgroundColorTag:(NSString *)backgroundColorTag {
    objc_setAssociatedObject(self, @selector(backgroundColorTag), backgroundColorTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateBackgroundColorFromTag];
}

- (NSString *)backgroundColorTag {
    return objc_getAssociatedObject(self, @selector(backgroundColorTag));
}

- (void)updateBackgroundColorFromTag {
    NSString *tag = self.backgroundColorTag;
    if(!tag) {
        return;
    }
    if([self respondsToSelector:@selector(setBackgroundColor:)]) {
        UIColor *color = [IQStyle colorWithTag:tag];
        if(color) {
            [self setValue:color forKey:@"backgroundColor"];
        }
    }
}

#pragma mark -
#pragma mark Text Color Tag methods
@dynamic textColorTag;

- (void)setTextColorTag:(NSString *)textColorTag {
    objc_setAssociatedObject(self, @selector(textColorTag), textColorTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateTextColorFromTag];
}

- (NSString *)textColorTag {
    return objc_getAssociatedObject(self, @selector(textColorTag));
}

- (void)updateTextColorFromTag {
    NSString *tag = self.textColorTag;
    if(!tag) {
        return;
    }
    if([self respondsToSelector:@selector(setTextColor:)]) {
        UIColor *color = [IQStyle colorWithTag:tag];
        if(color) {
            [self setValue:color forKey:@"textColor"];
        }
    }
}

#pragma mark -
#pragma mark Border Color Tag methods
@dynamic borderColorTag;

- (void)setBorderColorTag:(NSString *)borderColorTag {
    objc_setAssociatedObject(self, @selector(borderColorTag), borderColorTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateBorderColorFromTag];
}

- (NSString*)borderColorTag {
    return objc_getAssociatedObject(self, @selector(borderColorTag));
}

- (void)updateBorderColorFromTag {
    NSString *tag = self.borderColorTag;
    if(!tag) {
        return;
    }
    
    UIColor *color = [IQStyle colorWithTag:tag];
    if(color) {
        NSNumber *alpha = self.borderAlpha;
        if(alpha) {
            self.layer.borderColor = [color colorWithAlphaComponent:alpha.floatValue].CGColor;
        } else {
            self.layer.borderColor = color.CGColor;
        }
    }
}

#pragma mark -
#pragma mark Border Alpha methods
@dynamic borderAlpha;

- (void)setBorderAlpha:(NSNumber *)borderAlpha {
    objc_setAssociatedObject(self, @selector(borderAlpha), borderAlpha, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateBorderColorFromTag];
}

- (NSString*)borderAlpha {
    return objc_getAssociatedObject(self, @selector(borderAlpha));
}

#pragma mark -
#pragma mark Tint Tag methods
@dynamic tintTag;

- (void)setTintTag:(NSString *)tintTag {
    objc_setAssociatedObject(self, @selector(tintTag), tintTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateTintFromTag];
}

- (NSString*)tintTag {
    return objc_getAssociatedObject(self, @selector(tintTag));
}

- (void)updateTintFromTag {
    NSString *tag = self.tintTag;
    if(!tag) {
        return;
    }
    if([self respondsToSelector:@selector(setTintColor:)]) {
        UIColor *color = [IQStyle colorWithTag:tag];
        if(color) {
            [self performSelector:@selector(setTintColor:) withObject:color];
        }
    }
}

#pragma mark -
#pragma mark IQStyleProtocol methods

- (void)applyStyle
{
    [self updateBackgroundColorFromTag];
    [self updateFontFromTag];
    [self updateTextColorFromTag];
    [self updateBorderColorFromTag];
    [self updateTintFromTag];
    
    for(UIView *v in self.subviews) {
        if([v respondsToSelector:@selector(applyStyle)]) {
            [v applyStyle];
        }
    }
}

@end