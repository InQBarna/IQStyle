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

#import <Foundation/Foundation.h>
#import "UIView+IQStyle.h"
#import "UIColor+IQStyle.h"

NS_ASSUME_NONNULL_BEGIN

@interface IQStyle : NSObject

/**
 Returns a `NSDictionary` containging the fonts and colors that define the current style.
 @return A `NSDictionary` with fonts and colors
 */
+ (NSDictionary*)styleDictionary;

/**
 Sets the current style
 @discussion Method created for
 @see styleDictionary
 @param styleDictionary The `NSDictionary` that describes a style
 */
+ (void)setStyleWithDictionary:(NSDictionary*)styleDictionary;

/**
 Validates that a dictionary contains the expected `colorTags` and `fontTags`. This method should be used to validate style dictionaries that are to be passed to the `setStyleWithDictionary:` method
 @see setStyleWithDictionary:
 @param dictionary The `NSDictionary` that describes a style
 @param colorTags An array with all the expected color tags
 @param fontTags An array with all the expected font tags
 @return A `BOOL` indicating wheather the provided `dictionary` passed the validation
 */
+ (BOOL)validateStyleDictionary:(NSDictionary*)dictionary
                      colorTags:(NSArray<NSString*>*)colorTags
                       fontTags:(NSArray<NSString*>*)fontTags;

/**
 Returns the color for the given tag according to the current style
 @param tag The tag or name of the color
 @return A `UIColor` that corresponds to the `tag` as specified in the current style
 */
+ (nullable UIColor*)colorWithTag:(NSString*)tag;

/**
 Returns the font for the given tag according to the current style in the requested size
 @param tag The tag or name of the color
 @param size The size of the font
 @return A `UIFont` that corresponds to the `tag` as specified in the current style
 */
+ (nullable UIFont*)fontWithTag:(NSString*)tag size:(CGFloat)size;

/**
 Returns an array with all the font tags defined in the current style
 @return An `NSArray` containing font tags
 */
+ (NSArray<NSString*>*)fontTags;

/**
 Returns an array with all the color tags defined in the current style
 @return An `NSArray` containing color tags
 */
+ (NSArray<NSString*>*)colorTags;

/**
 Returns a HTML page with a visual representation of the current style
 @return An `NSString` that contains a HTML page
 */
+ (NSString*)styleSheet;

/**
 Modifies the current style by associating a color to a tag
 @param color The color to be assigned
 @param tag The tag or name of the color to be assigned to
 */
+ (void)setColor:(UIColor *_Nullable)color forTag:(NSString*)tag;

@end

/**
 `IQStyleProtocol` defines a lightweigth mechanism for the views to apply and react to style changes
 */
@protocol IQStyleProtocol <NSObject>
@optional
- (void)styleDidChange;
- (void)applyStyle;
@end

@interface NSObject(IQStyle)
- (void)registerForStyleChanges;
- (void)unregisterForStyleChanges;
@end

NS_ASSUME_NONNULL_END