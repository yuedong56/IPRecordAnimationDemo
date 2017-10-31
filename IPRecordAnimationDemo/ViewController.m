//
//  ViewController.m
//  IPRecordAnimationDemo
//
//  Created by yuedongkui on 2017/10/27.
//  Copyright © 2017年 LY. All rights reserved.
//

#import "ViewController.h"
#import "RecordButton.h"
#import "FrameAccessor.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    float view_w = self.view.bounds.size.width;
    float view_h = self.view.bounds.size.height;
    float button_w = 60;
    RecordButton *button = [[RecordButton alloc] initWithFrame:NSMakeRect((view_w-button_w)/2, (view_h-button_w)/2, button_w, button_w)];
    [self.view addSubview:button];
    
    button.target = self;
    button.action = @selector(recordButtonAction:);
}

- (void)recordButtonAction:(RecordButton *)button
{
    if (button.isRecording) {
        [button stopAnimation];
    }
    else {
        [button startAnimation];
    }
}


@end
