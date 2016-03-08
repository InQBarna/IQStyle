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

#import "IQStyleSettingsViewController.h"
#import "IQStyle.h"
#import "IQStyleAdvertiser.h"

static IQStyleAdvertiser        *__advertiser;

@interface IQStyleSettingsViewController()
@end

@implementation IQStyleSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 48.0f;
    self.title = @"Style Settings";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *result;
    
    switch (indexPath.row) {
        case 0: {
            static NSString *reuseIdentifier = @"invertCell";
            result = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if(!result) {
                result = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                reuseIdentifier:reuseIdentifier];
            }
            
            result.textLabel.text = @"Invert colors";
            
        } break;
            
        case 1: {
            static NSString *reuseIdentifier = @"debugCell";
            result = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if(!result) {
                result = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                reuseIdentifier:reuseIdentifier];
            }
            
            result.textLabel.text = @"Remote Debug";
            
            if(__advertiser) {
                result.detailTextLabel.text = @"ENABLED";
            } else {
                result.detailTextLabel.text = @"DISABLED";
            }
        } break;
            
        default:
            break;
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            [self invertColors];
        } break;
            
        case 1: {
            if(__advertiser) {
                [__advertiser stopAdvertising];
                __advertiser = nil;
            } else {
                __advertiser = [[IQStyleAdvertiser alloc] initWithServiceType:@"CSD"
                                                                   identifier:[UIDevice currentDevice].identifierForVendor.UUIDString
                                                                  displayName:[UIDevice currentDevice].localizedModel];
                [__advertiser startAdvertising];
            }
        } break;
            
        default:
            break;
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)invertColors
{
    NSMutableDictionary *result = [IQStyle styleDictionary].mutableCopy;
    NSDictionary *colors = [result objectForKey:@"Colors"];
    NSMutableDictionary *newColors = [NSMutableDictionary dictionary];
    
    for(NSString *key in colors.allKeys) {
        NSString *hex = [colors objectForKey:key];
        UIColor *color = [UIColor colorWithHexString:hex];
        color = [color inverted];
        hex = color.toString;
        [newColors setObject:hex forKey:key];
    }
    
    [result setObject:newColors.copy forKey:@"Colors"];
    
    [IQStyle setStyleWithDictionary:result];
}

@end
