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

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <Foundation/Foundation.h>
#import "IQStyleClientInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IQStyleBrowserDelegate;

@interface IQStyleBrowser : NSObject
@property (nullable, nonatomic, weak) id<IQStyleBrowserDelegate>  delegate;

- (void)startBrowsing;
- (NSArray<IQStyleClientInfo*>*)list;
- (void)stopBrowsing;

- (void)connectToClient:(IQStyleClientInfo*)info completion:(void(^)(MCPeerID *peerID, MCSession *session, NSError *error))block;
@end

@protocol IQStyleBrowserDelegate <NSObject>
@required
- (void)serviceBrowserDidUpdateList:(IQStyleBrowser*)browser;
@end

NS_ASSUME_NONNULL_END