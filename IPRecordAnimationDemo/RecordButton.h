//
//  RecordButton.h
//  IPRecordAnimationDemo
//
//  Created by yuedongkui on 2017/10/27.
//  Copyright © 2017年 LY. All rights reserved.
//

#import "SFImageButton.h"
#import <QuartzCore/QuartzCore.h>

@interface RecordButton : SFImageButton<CAAnimationDelegate>

@property (assign) BOOL isRecording;

- (void)startAnimation;
- (void)stopAnimation;

@end
