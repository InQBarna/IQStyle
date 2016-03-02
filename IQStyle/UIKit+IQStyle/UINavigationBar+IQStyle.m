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
#import "IQStyle.h"
#import "UINavigationBar+IQStyle.h"

@implementation UINavigationBar (IQStyle)

#pragma mark -
#pragma mark BarTint Tag methods
@dynamic barTintTag;

- (void)setBarTintTag:(NSString *)barTintTag {
    objc_setAssociatedObject(self, @selector(barTintTag), barTintTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateBarTintFromTag];
}

- (NSString*)barTintTag {
    return objc_getAssociatedObject(self, @selector(barTintTag));
}

- (void)updateBarTintFromTag {
    NSString *tag = self.barTintTag;
    if(!tag) {
        return;
    }
    if([self respondsToSelector:@selector(setBarTintColor:)]) {
        UIColor *color = [IQStyle colorWithTag:tag];
        if(color) {
            [self performSelector:@selector(setBarTintColor:) withObject:color];
        }
    }
}

#pragma mark -
#pragma mark Title Text Color methods

- (void)setTitleTextColorTag:(NSString *)titleTextColorTag
{
    objc_setAssociatedObject(self, @selector(titleTextColorTag), titleTextColorTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateTitleTextColorFromTag];
}

- (NSString*)titleTextColorTag
{
    return objc_getAssociatedObject(self, @selector(titleTextColorTag));
}

- (void)updateTitleTextColorFromTag
{
    NSString *tag = self.titleTextColorTag;
    if(!tag) {
        return;
    }
    
    UIColor *color = [IQStyle colorWithTag:tag];
    if(color) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.titleTextAttributes];
        
        [tmp setObject:color forKey:NSForegroundColorAttributeName];
        self.titleTextAttributes = tmp;
    }
}

- (void)applyStyle
{
    [self updateBarTintFromTag];
    [self updateTitleTextColorFromTag];
    [super applyStyle];
}
@end
