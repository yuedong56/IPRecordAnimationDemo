//
//  RecordButton.m
//  IPRecordAnimationDemo
//
//  Created by yuedongkui on 2017/10/27.
//  Copyright © 2017年 LY. All rights reserved.
//

#import "RecordButton.h"
#import "FrameAccessor.h"

#import <AVFoundation/AVFoundation.h>


#define kWaveMaxWidth  400
#define kSingleWaveLineWidth 1

@interface RecordButton()

@property NSRect initialFrame;
@property (strong) NSMutableArray *halfHeights;//长度的一半，中间线上半部分的长度
@property (strong) NSTimer *timer;

@property (nonatomic, strong) AVAudioRecorder *recorder;//录音器

@end




@implementation RecordButton

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _initialFrame = frame;
        [self setImage:[NSImage imageNamed:@"input_voice_n"]];
        
        [self prepareRecord];
    }
    return self;
}

- (void)prepareRecord
{
    //2.获取文件路径
    NSURL *recordFileUrl = [NSURL fileURLWithPath:@"/Users/yuedongkui/Desktop/________.wav"];
    
    //设置参数
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                                   // 音频格式
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   //采样位数  8、16、24、32 默认为16
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   // 音频通道数 1 或 2
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   //录音质量
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];
    
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:recordFileUrl settings:recordSetting error:nil];
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
}

- (void)startAnimation
{
    self.isRecording = YES;

    //将layer放到中间，去掉后动画会歪
    self.layer.anchorPoint = NSMakePoint(0.5, 0.5);
    self.layer.position = NSMakePoint(self.x+self.width/2, self.y+self.height/2);
    
    //1.缩小
    //缩小
    CABasicAnimation *small1Animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    small1Animation.toValue = @(0.9f);//缩放倍数
    small1Animation.duration = 0.1;
    //        small1Animation.duration = 1;
    small1Animation.beginTime = 0;
    small1Animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    //2.放大、上移
    //放大
    CABasicAnimation *bigAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    bigAnimation.fromValue = small1Animation.toValue;
    bigAnimation.toValue = @(1.1f);//缩放倍数
    bigAnimation.duration = 0.2;
    //        bigAnimation.duration = 2;
    bigAnimation.beginTime = small1Animation.beginTime + small1Animation.duration;
    bigAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    //位置上移，与放大动画同时进行
    CABasicAnimation *upAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    upAnimation.toValue = @(self.layer.position.y - 10);
    upAnimation.duration = bigAnimation.duration;
    upAnimation.beginTime = bigAnimation.beginTime;
    upAnimation.timingFunction = bigAnimation.timingFunction;
    
    //3.缩小、下移
    //缩小
    CABasicAnimation *small2Animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    small2Animation.fromValue = bigAnimation.toValue;
    small2Animation.toValue = @(0.7f);
    small2Animation.duration =0.25;
    //    small2Animation.duration = 2.5;
    small2Animation.beginTime = bigAnimation.beginTime + bigAnimation.duration;
    small2Animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    //位置下移，与缩小动画同时进行
    CABasicAnimation *downAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    downAnimation.fromValue = upAnimation.toValue;
    downAnimation.toValue = @(self.layer.position.y + 25);
    downAnimation.duration = small2Animation.duration;
    downAnimation.beginTime = small2Animation.beginTime;
    downAnimation.timingFunction = small2Animation.timingFunction;
    
    //添加动画组
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.delegate = self;
    animationGroup.duration = small1Animation.duration + bigAnimation.duration + small2Animation.duration;
    [animationGroup setValue:@"animationGroup" forKey:@"AnimationKey"];
    animationGroup.animations = @[small1Animation, bigAnimation, upAnimation, small2Animation, downAnimation];
    [self.layer addAnimation:animationGroup forKey:@"animationGroup"];
    
    [self startRecordAudio];
}

- (void)stopAnimation
{
    self.isRecording = NO;

    self.frame = self.initialFrame;
    [self setImage:[NSImage imageNamed:@"input_voice_n"]];
    [self.halfHeights removeAllObjects];
    
    [self.timer invalidate];
    self.timer = nil;
    
    [self stopRecordAudio];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{

}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (!self.isRecording) {
        return;
    }
    
    CAAnimationGroup *animationGroup = (CAAnimationGroup *)anim;
    CABasicAnimation *small2 = (CABasicAnimation *)animationGroup.animations[3];
    CABasicAnimation *down = (CABasicAnimation *)animationGroup.animations[4];

    //保存最终状态
    float rate = [small2.toValue floatValue];
//    self.layer.bounds = NSMakeRect(0, 0, self.layer.bounds.size.width*rate, self.layer.bounds.size.height *rate);
//    self.layer.position = NSMakePoint(self.layer.position.x, [down.toValue floatValue]);
    
    self.image = nil;
    
    int layer_w = kWaveMaxWidth;
    int layer_h = self.layer.bounds.size.height *rate;
    int layerCenterX = self.layer.position.x;
    int layerCenterY = [down.toValue floatValue];
    
    self.frame = NSMakeRect(layerCenterX-layer_w/2, layerCenterY-layer_h/2, layer_w, layer_h);
    self.layer.cornerRadius = self.height/2;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^
    {
        //定时器
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                     repeats:YES
                                                       block:^(NSTimer *timer)
        {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [_recorder updateMeters];
                  float h = ([_recorder averagePowerForChannel:0]+60)/60 *12;
//                  if (self.halfHeights.count % 2 == 0) {
//                      h =  ([_recorder peakPowerForChannel:0]+60)/60 *12;
//                  }
//                  NSLog(@"h = %f", h);
//                  NSLog(@"%f, %f", [_recorder averagePowerForChannel:0]+60, [_recorder peakPowerForChannel:0]+60);
                  if (self.halfHeights == nil) {
                      self.halfHeights = [NSMutableArray array];
                  }
                  [self.halfHeights addObject:@(h)];
                  [self setNeedsDisplay:YES];
              });
        }];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    int wave_w = self.height + self.halfHeights.count*kSingleWaveLineWidth;
    int x = (dirtyRect.size.width-wave_w)/2;

    if (self.isRecording) {
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:(NSMakeRect(x, 0, wave_w, self.height)) xRadius:self.height/2 yRadius:self.height/2];
        [[NSColor blueColor] set];
        [path fill];
        
        [[NSColor whiteColor] set];
        NSRectFill(NSMakeRect(x, (int)dirtyRect.size.height/2, wave_w, 1));
    }

    __weak typeof(self) weakSelf = self;
    [self.halfHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [[NSColor whiteColor] set];
        int h = [obj floatValue] * 2;
        int x = weakSelf.width/2 + wave_w/2 - (weakSelf.halfHeights.count-(int)idx)*kSingleWaveLineWidth;
        if (wave_w > kWaveMaxWidth) {
            x = x - (wave_w-kWaveMaxWidth)/2;
        }
        int y = weakSelf.height/2 - h/2;
        NSRectFill(NSMakeRect(x, y, 1, h));
    }];


}

#pragma mark - 录制音频
- (void)startRecordAudio
{
    if (_recorder) {
        [_recorder record];
    }
    else {
        NSLog(@"录音错误");
    }
}

- (void)stopRecordAudio
{
    NSLog(@"停止录音");
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
}


- (BOOL)isFlipped
{
    return YES;
}

@end






