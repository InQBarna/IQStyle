//
//  EditViewController.h
//  IQRemoteStyle
//
//  Created by David Romacho on 08/03/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface EditorViewController : UITableViewController

- (void)setupWithPeerID:(MCPeerID*)peerID session:(MCSession*)session;
@end
