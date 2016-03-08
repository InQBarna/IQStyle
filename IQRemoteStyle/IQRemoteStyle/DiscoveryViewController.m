//
//  DiscoveryViewController.m
//  IQRemoteStyle
//
//  Created by David Romacho on 08/03/16.
//  Copyright © 2016 InQBarna. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "IQStyleBrowser.h"
#import "EditorViewController.h"

@interface DiscoveryViewController ()<IQStyleBrowserDelegate>
@property (nonatomic, strong, nullable) IQStyleBrowser      *browser;
@end

@implementation DiscoveryViewController

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.browser = [[IQStyleBrowser alloc] initWithServiceType:@"CSD" displayName:@"Editor"];
    self.browser.delegate = self;
    [self.browser startBrowsing];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"editShow"]) {
        EditorViewController *vc = (EditorViewController*)segue.destinationViewController;
        NSDictionary *d = (NSDictionary*)sender;
        MCSession *session = [d objectForKey:@"session"];
        MCPeerID *peerID = [d objectForKey:@"peerID"];
        [vc setupWithPeerID:peerID session:session];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.browser.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuserIdentifier = @"cell";
    
    UITableViewCell *result = [tableView dequeueReusableCellWithIdentifier:reuserIdentifier];
    if(!result) {
        result = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                        reuseIdentifier:reuserIdentifier];
    }
    
    IQStyleClientInfo *info = [self.browser.list objectAtIndex:indexPath.row];
    result.textLabel.text = info.displayName;
    result.detailTextLabel.text = info.deviceName;
    return result;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    IQStyleClientInfo *info = [self.browser.list objectAtIndex:indexPath.row];
    [self.browser connectToClient:info
                       completion:^(MCPeerID * _Nonnull peerID, MCSession * _Nonnull session, NSError * _Nonnull error)
    {
        if(session) {
            [self performSegueWithIdentifier:@"editShow" sender:@{@"session" : session, @"peerID" : peerID}];
        } else {
            
        }
    }];
}

#pragma mark -
#pragma mark IQStyleBrowserDelegate methods

- (void)serviceBrowserDidUpdateList:(IQStyleBrowser*)browser
{
    [self.tableView reloadData];
}
@end
