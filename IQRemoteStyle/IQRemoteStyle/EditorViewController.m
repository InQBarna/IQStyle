//
//  EditViewController.m
//  IQRemoteStyle
//
//  Created by David Romacho on 08/03/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "EditorViewController.h"
#import "IQStyle.h"

@interface EditorViewController ()<MCSessionDelegate>
@property (nonatomic, strong, nullable) MCSession       *session;
@property (nonatomic, strong, nullable) MCPeerID        *peerID;
@property (nonatomic, strong, nullable) NSDictionary    *colors;
@property (nonatomic, strong, nullable) NSArray         *tags;
@end

@implementation EditorViewController

#pragma mark -
#pragma mark NSObject methods

- (void)dealloc
{
    _session.delegate = nil;
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
    NSError *error;
    if(![self.session sendData:data
                       toPeers:@[self.peerID]
                      withMode:MCSessionSendDataReliable error:&error]) {
        NSLog(@"[ERROR] %@", error.localizedDescription);
    } else {
        NSLog(@"Sent initial data");
    }
}

#pragma mark -
#pragma mark EditorViewController methods

- (void)setupWithPeerID:(MCPeerID*)peerID session:(MCSession*)session
{
    self.peerID = peerID;
    self.session = session;
    self.session.delegate = self;
}

- (void)editColorAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *tag = [self.tags objectAtIndex:indexPath.row];
    NSString *text = [self.colors objectForKey:tag];
    
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Enter new color"
                                                               message:nil
                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    __block __weak UITextField *tf;
    [a addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        tf = textField;
        textField.delegate = nil;
        textField.text = text;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.spellCheckingType = UITextSpellCheckingTypeNo;
    }];
    
    __weak typeof(self) welf = self;
    [a addAction:[UIAlertAction actionWithTitle:@"Ok"
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action)
                  {
                      UIColor *newColor = [UIColor colorWithHexString:tf.text];
                      if(newColor) {
                          [welf sendColor:tf.text forTag:tag];
                      }
                  }]];
    
    [a addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                          style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction *action)
                  {
                  }]];
    
    [self presentViewController:a animated:YES completion:nil];
}

- (void)sendColor:(NSString*)color forTag:(NSString*)tag
{
    NSError *error;
    NSDictionary *d = @{tag : color};
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
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuserIdentifier = @"cell";
    
    UITableViewCell *result = [tableView dequeueReusableCellWithIdentifier:reuserIdentifier];
    if(!result) {
        result = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                        reuseIdentifier:reuserIdentifier];
    }
    
    NSString *tag = [self.tags objectAtIndex:indexPath.row];
    result.textLabel.text = tag;
    result.detailTextLabel.text = [self.colors objectForKey:tag];
    return result;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self editColorAtIndexPath:indexPath];
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
        self.colors = style;
        self.tags = [style.allKeys sortedArrayUsingSelector:@selector(compare:)];
        
        [self.tableView reloadData];
        NSLog(@"Did get style. Reloading table");
    });
}

- (void)        session:(MCSession *)session
  didReceiveCertificate:(nullable NSArray *)certificate
               fromPeer:(MCPeerID *)peerID
     certificateHandler:(void (^)(BOOL accept))certificateHandler
{
    certificateHandler(NO);
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
@end
