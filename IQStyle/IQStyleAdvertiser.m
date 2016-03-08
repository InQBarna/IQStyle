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

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "IQStyleAdvertiser.h"
#import "IQStyle.h"

@interface IQStyleAdvertiser ()<MCNearbyServiceAdvertiserDelegate, MCSessionDelegate>
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong, nullable) MCSession       *session;
@property (nonatomic, strong, nullable) MCPeerID        *remotePeerID;
@end

@implementation IQStyleAdvertiser

#pragma mark -
#pragma mark NSOBject methods

- (void)dealloc
{
    _session.delegate = nil;
    _session = nil;
    [_advertiser stopAdvertisingPeer];
    _advertiser.delegate = nil;
    _advertiser = nil;
}

#pragma mark -
#pragma mark Advertiser methods

- (id)initWithServiceType:(NSString*)serviceType
               identifier:(NSString*)identifier
              displayName:(NSString*)displayName
{
    NSParameterAssert(serviceType);
    NSParameterAssert(identifier);
    NSParameterAssert(displayName);
    
    self = [self init];
    if(self) {
        MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
        NSMutableDictionary *discoveryInfo = [NSMutableDictionary dictionary];
        
        [discoveryInfo setObject:identifier forKey:@"id"];
        [discoveryInfo setObject:[UIDevice currentDevice].name forKey:@"device_name"];
        [discoveryInfo setObject:[UIDevice currentDevice].model forKey:@"device_model"];
        
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID
                                                            discoveryInfo:discoveryInfo.copy
                                                              serviceType:serviceType];
        self.advertiser.delegate = self;
    }
    return self;
}

- (void)startAdvertising
{
    [_advertiser startAdvertisingPeer];
}

- (void)stopAdvertising {
    [_advertiser stopAdvertisingPeer];
}
- (void)sendStyle
{
    NSError *error;
    NSDictionary *colors = [[IQStyle styleDictionary] objectForKey:@"Colors"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:colors
                                                   options:0
                                                     error:&error];
    
    if(data && self.remotePeerID) {
        [self.session sendData:data
                       toPeers:@[self.remotePeerID]
                      withMode:MCSessionSendDataReliable
                         error:&error];
    }
}

#pragma mark -
#pragma mark MCNearbyServiceAdvertiserDelegate methods

// Incoming invitation request.  Call the invitationHandler block with YES
// and a valid session to connect the inviting peer to the session.
- (void)            advertiser:(MCNearbyServiceAdvertiser *)advertiser
  didReceiveInvitationFromPeer:(MCPeerID *)peerID
                   withContext:(nullable NSData *)context
             invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler
{
    MCSession *session = [[MCSession alloc] initWithPeer:advertiser.myPeerID
                                        securityIdentity:nil
                                    encryptionPreference:MCEncryptionNone];
    session.delegate = self;
    self.session = session;
    self.remotePeerID = peerID;
    
    invitationHandler(YES, session);
}

// Advertising did not start due to an error.
- (void)        advertiser:(MCNearbyServiceAdvertiser *)advertiser
didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"[ERROR] didNotStartAdvertisingPeer: %@", error.localizedDescription);
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
                self.session.delegate = nil;
                self.session = nil;
                self.remotePeerID = nil;
                break;
                
            case MCSessionStateConnecting:
                name = @"Connecting…";
                break;
                
            case MCSessionStateConnected:
                name = @"Connected";
                break;
                
            default:
                name = @"Unknown";
                break;
        }
        
        NSLog(@"Advertiser: %@", name);        
    });
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSError *error;
    NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:0
                                                        error:&error];
    
    if(d) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for(NSString *key in d.allKeys) {
                NSString *color = [d objectForKey:key];
                UIColor *c = [UIColor colorWithHexString:color];
                if(key && c) {
                    [IQStyle setColor:c forTag:key];
                }
            }
            [self sendStyle];
        });
    }
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

