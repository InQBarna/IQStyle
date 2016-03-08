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

#import "DiscoveryViewController.h"
#import "IQStyleBrowser.h"
#import "EditorViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DiscoveryViewController ()<IQStyleBrowserDelegate>
@property (nonatomic, strong, nullable) IQStyleBrowser      *browser;
@end

NS_ASSUME_NONNULL_END

@implementation DiscoveryViewController

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.browser = [[IQStyleBrowser alloc] init];
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
            EditorViewController *vc = [[EditorViewController alloc] init];
            [vc setupWithPeerID:peerID session:session];
            [self.navigationController pushViewController:vc animated:YES];
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
