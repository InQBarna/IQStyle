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
#import "IQStyleBrowser.h"
#import "IQStyleAdvertiser.h"

@interface IQStyleBrowser()<MCNearbyServiceBrowserDelegate, MCSessionDelegate>
@property (nonatomic, strong) MCNearbyServiceBrowser    *browser;
@property (nonatomic, strong) NSMutableDictionary       *peers;
@property (nonatomic, strong) MCSession                 *session;
@property (nonatomic, copy) void(^connectionHandler)(MCPeerID *, MCSession *, NSError *);
@end

@implementation IQStyleBrowser

- (id)init
{
    self = [super init];
    if(self) {
        self.peers = [NSMutableDictionary dictionary];
        NSString *displayName = @"Editor";
        MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerID
                                                        serviceType:IQStyleServiceName];
        self.browser.delegate = self;
    }
    return self;
}

- (void)startBrowsing {
    [self.peers removeAllObjects];
    [self.delegate serviceBrowserDidUpdateList:self];
    [self.browser startBrowsingForPeers];
}

- (NSArray*)list {
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    return [self.peers.allValues sortedArrayUsingDescriptors:@[sd]];
}

- (void)stopBrowsing {
    [self.browser stopBrowsingForPeers];
}

- (void)connectToClient:(IQStyleClientInfo*)info
             completion:(void(^)(MCPeerID *peerID, MCSession *session, NSError *error))block
{
    MCPeerID *peerID;
    
    for(MCPeerID *pID in self.peers.allKeys) {
        if([self.peers objectForKey:pID] == info) {
            peerID = pID;
            break;
        }
    }
    if(peerID) {
        self.session.delegate = nil;
        self.session = nil;
        
        self.connectionHandler = block;
        self.session = [[MCSession alloc] initWithPeer:self.browser.myPeerID
                                      securityIdentity:nil
                                  encryptionPreference:MCEncryptionNone];
        self.session.delegate = self;
        [self.browser invitePeer:peerID toSession:self.session withContext:nil timeout:30.0f];
    }
}

#pragma mark -
#pragma mark MCNearbyServiceBrowserDelegate methods

- (void)        browser:(MCNearbyServiceBrowser *)browser
              foundPeer:(MCPeerID *)peerID
      withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:info];
    [d setObject:peerID.displayName forKey:@"display_name"];
    
    IQStyleClientInfo *serviceInfo = [[IQStyleClientInfo alloc] initWithDictionary:d.copy];
    if(serviceInfo.identifier) {
        [self.peers setObject:serviceInfo forKey:peerID];
        [self.delegate serviceBrowserDidUpdateList:self];
    } else {
        NSLog(@"[WARN] Got a service info without identifier");
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    [self.peers removeObjectForKey:peerID];
    [self.delegate serviceBrowserDidUpdateList:self];
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"[ERROR] Service browser did not start browsing: %@", error.localizedDescription);
}

#pragma mark -
#pragma mark MCSessionDelegate methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *name;
        
        switch (state) {
            case MCSessionStateNotConnected:
                name = @"Not Connected";
                if(self.connectionHandler) {
                    self.connectionHandler(nil, nil, [NSError errorWithDomain:@"xXx" code:0 userInfo:nil]);
                    self.connectionHandler = nil;
                }
                self.session.delegate = nil;
                self.session = nil;
                
                break;
                
            case MCSessionStateConnecting:
                name = @"Connecting…";
                break;
                
            case MCSessionStateConnected:
                name = @"Connected";
                self.session.delegate = nil;
                self.session = nil;
                
                if(self.connectionHandler) {
                    self.connectionHandler(peerID, session, nil);
                    self.connectionHandler = nil;
                }
                break;
                
            default:
                name = @"Unknown";
                break;
        }
        
        NSLog(@"Browser: %@", name);        
    });
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// Received a byte stream from remote peer.
- (void)    session:(MCSession *)session
   didReceiveStream:(NSInputStream *)stream
           withName:(NSString *)streamName
           fromPeer:(MCPeerID *)peerID
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// Start receiving a resource from remote peer.
- (void)                    session:(MCSession *)session
  didStartReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                       withProgress:(NSProgress *)progress
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// Finished receiving a resource from remote peer and saved the content
// in a temporary location - the app is responsible for moving the file
// to a permanent location within its sandbox.
- (void)                    session:(MCSession *)session
 didFinishReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                              atURL:(NSURL *)localURL
                          withError:(nullable NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

// Made first contact with peer and have identity information about the
// remote peer (certificate may be nil).
- (void)        session:(MCSession *)session
  didReceiveCertificate:(nullable NSArray *)certificate
               fromPeer:(MCPeerID *)peerID
     certificateHandler:(void (^)(BOOL accept))certificateHandler
{
    certificateHandler(YES);
    NSLog(@"%@", NSStringFromSelector(_cmd));    
}

@end
