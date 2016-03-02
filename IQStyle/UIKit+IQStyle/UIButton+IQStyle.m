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
#import "UIButton+IQStyle.h"

@implementation UIButton (IQStyle)

#pragma mark -
#pragma mark Title Color Tag methods
@dynamic titleColorTag;

- (void)setTitleColorTag:(NSString *)titleColorTag {
    objc_setAssociatedObject(self, @selector(titleColorTag), titleColorTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateTitleColorFromTag];
}

- (NSString *)titleColorTag {
    return objc_getAssociatedObject(self, @selector(titleColorTag));
}

- (void)updateTitleColorFromTag {
    NSString *tag = self.titleColorTag;
    if(!tag) {
        return;
    }
    if([self respondsToSelector:@selector(setTitleColor:forState:)]) {
        UIColor *color = [IQStyle colorWithTag:tag];
        if(color) {
            [(UIButton*)self setTitleColor:color forState:UIControlStateNormal];
        }
    }
}

- (void)applyStyle
{
    [self updateTitleColorFromTag];
    [super applyStyle];
}
@end
