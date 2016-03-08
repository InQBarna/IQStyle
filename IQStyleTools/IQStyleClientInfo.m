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

#import "IQStyleClientInfo.h"

@implementation IQStyleClientInfo

#pragma mark -
#pragma mark NSObject methods

- (NSString*)description {
    NSMutableString *result = [NSMutableString string];
    
    [result appendFormat:@"  id: %@\n", _identifier];
    [result appendFormat:@"  display_name: %@\n", _displayName];
    [result appendFormat:@"  device_name: %@\n", _deviceName];
    [result appendFormat:@"  device_model: %@\n", _deviceModel];
    
    return result.copy;
}

#pragma mark -
#pragma mark ServiceInfo methods

- (id)initWithDictionary:(NSDictionary*)d {
    self = [self init];
    if(self) {
        _identifier = [d objectForKey:@"id"];
        _displayName = [d objectForKey:@"display_name"];
        _deviceName = [d objectForKey:@"device_name"];
        _deviceModel = [d objectForKey:@"device_model"];
        
        // since we cannot send [NSNull null] through the Bonjour discovery info, assume an empty string is nil
        
        _identifier = _identifier.length ? _identifier : nil;
        _displayName = _displayName.length ? _displayName : nil;
        _deviceName = _deviceName.length ? _deviceName : nil;
        _deviceModel = _deviceModel.length ? _deviceModel : nil;
    }
    return self;
}

@end
