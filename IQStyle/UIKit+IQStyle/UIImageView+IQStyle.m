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
#import "UIImageView+IQStyle.h"

@implementation UIImageView (IQStyle)
@dynamic useImageAsTemplate;

- (void)setUseImageAsTemplate:(BOOL)useImageAsTemplate
{
    objc_setAssociatedObject(self, @selector(useImageAsTemplate), @(useImageAsTemplate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateUseImageAsTemplate];
}

- (BOOL)useImageAsTemplate
{
    NSNumber *result = objc_getAssociatedObject(self, @selector(useImageAsTemplate));
    return result.boolValue;
}

- (void)updateUseImageAsTemplate {
    if(self.useImageAsTemplate && self.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
        UIImage *img = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.image = img;
    }
}

@end
