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

#import "ViewController.h"
#import "IQStyle.h"
#import "IQStyleEditorViewController.h"
#import "IQStyleAdvertiser.h"

NS_ASSUME_NONNULL_BEGIN
@interface ViewController ()<IQStyleEditorViewControllerDelegate>
@property (nonatomic, strong, nullable) IQStyleAdvertiser   *advertiser;
@end
NS_ASSUME_NONNULL_END

@implementation ViewController

#pragma mark -
#pragma mark NSObject methods

- (void)dealloc {
    [self unregisterForStyleChanges];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForStyleChanges];
    self.title = @"MOVIES";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Enable"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(toggleRemote:)];
}

#pragma mark -
#pragma mark ViewController methods

- (IBAction)changeAction:(id)sender
{
    IQStyleEditorViewController *vc = [[IQStyleEditorViewController alloc] init];
    vc.delegate = self;
    vc.styleDictionary = [[IQStyle styleDictionary] objectForKey:@"Colors"];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)toggleRemote:(id)sender
{
    if(self.advertiser) {
        [self.advertiser stopAdvertising];
        self.advertiser = nil;
        self.navigationItem.rightBarButtonItem.title = @"Eanble";
    } else {
        self.advertiser = [[IQStyleAdvertiser alloc] init];
        [self.advertiser startAdvertising];
        self.navigationItem.rightBarButtonItem.title = @"Disable";
    }
}

#pragma mark -
#pragma mark IQStyleProtocol methods

- (void)styleDidChange {
    if(self.navigationController) {
        [self.navigationController.navigationBar performSelector:@selector(applyStyle)];
    }
    [self.view performSelector:@selector(applyStyle)];
}

#pragma mark -
#pragma mark IQStyleEditorViewControllerDelegate methods

- (void)styleEditor:(IQStyleEditorViewController*)editor
     didSelectColor:(UIColor*)color
             forTag:(NSString*)tag
{
    [IQStyle setColor:color forTag:tag];
    editor.styleDictionary = [[IQStyle styleDictionary] objectForKey:@"Colors"];
}

@end
