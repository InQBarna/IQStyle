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

#import <HRColorPickerView.h>
#import <HRColorMapView.h>
#import <HRBrightnessSlider.h>
#import "PickerViewController.h"

NS_ASSUME_NONNULL_BEGIN
@interface PickerViewController ()
@property (nonatomic, strong, nullable) UIColor     *color;
@property (nonatomic, copy, nullable) void(^handler)(UIColor *);
@property (nonatomic, weak, nullable) HRColorPickerView     *colorPickerView;
@end
NS_ASSUME_NONNULL_END

@implementation PickerViewController

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    HRColorPickerView *colorPickerView = [[HRColorPickerView alloc] init];
    colorPickerView.color = _color;
    colorPickerView.colorMapView.saturationUpperLimit = @(1.0f);
    colorPickerView.brightnessSlider.brightnessLowerLimit = @(0);
    
    [colorPickerView addTarget:self
                        action:@selector(action:)
              forControlEvents:UIControlEventValueChanged];
    
    colorPickerView.frame = self.view.bounds;
    colorPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:colorPickerView];
    self.colorPickerView = colorPickerView;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismiss:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(done:)];
}

#pragma mark -
#pragma mark PickerViewController methods

- (void)setupWithColor:(UIColor*)color completion:(void(^)(UIColor *color))block
{
    self.color = color;
    self.handler = block;
}

- (void)action:(id)sender
{
    self.color = self.colorPickerView.color;
}

- (void)done:(id)sender
{
    if(self.handler) {
        self.handler(self.color);
        self.handler = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
