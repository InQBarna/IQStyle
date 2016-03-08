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

#import "EditorViewController.h"
#import "IQStyle.h"

NS_ASSUME_NONNULL_BEGIN
@interface EditorViewController ()<MCSessionDelegate, IQStyleEditorViewControllerDelegate>
@property (nonatomic, strong, nullable) MCSession       *session;
@property (nonatomic, strong, nullable) MCPeerID        *peerID;
@end
NS_ASSUME_NONNULL_END

@implementation EditorViewController

#pragma mark -
#pragma mark NSObject methods

- (void)dealloc
{
    _session.delegate = nil;
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self sendColor:nil forTag:nil];
    self.title = _peerID.displayName;
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark -
#pragma mark EditorViewController methods

- (void)setupWithPeerID:(MCPeerID*)peerID session:(MCSession*)session
{
    self.peerID = peerID;
    self.session = session;
    self.session.delegate = self;
    self.delegate = self;
}

- (void)sendColor:(NSString*)hex forTag:(NSString*)tag
{
    NSError *error;
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    if(hex && tag) {
        [d setObject:hex forKey:tag];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:d options:0 error:&error];
    
    if(data) {
        [self.session sendData:data
                       toPeers:@[self.peerID]
                      withMode:MCSessionSendDataReliable
                         error:&error];
    }
    
    if(error) {
        NSLog(@"[ERROR] %@", error.localizedDescription);
    }
}

#pragma mark -
#pragma mark IQStyleEditorViewControllerDelegate methods

- (void)styleEditor:(IQStyleEditorViewController*)editor didSelectColor:(UIColor*)color forTag:(NSString*)tag
{
    [self sendColor:color.toString forTag:tag];
}

#pragma mark -
#pragma mark MCSessionDelegate methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if(state != MCSessionStateConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Got disconnected");
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    
    NSDictionary *style = [NSJSONSerialization JSONObjectWithData:data
                                                          options:0
                                                            error:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.styleDictionary = style;
        NSLog(@"Did get style.");
    });
}

- (void)        session:(MCSession *)session
  didReceiveCertificate:(nullable NSArray *)certificate
               fromPeer:(MCPeerID *)peerID
     certificateHandler:(void (^)(BOOL accept))certificateHandler
{
    certificateHandler(NO);
}

- (void)    session:(MCSession *)session
   didReceiveStream:(NSInputStream *)stream
           withName:(NSString *)streamName
           fromPeer:(MCPeerID *)peerID
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)                    session:(MCSession *)session
  didStartReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                       withProgress:(NSProgress *)progress
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)                    session:(MCSession *)session
 didFinishReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                              atURL:(NSURL *)localURL
                          withError:(nullable NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
