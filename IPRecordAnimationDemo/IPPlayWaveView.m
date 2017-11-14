//
//  WaveView.m
//  IPRecordAnimationDemo
//
//  Created by yuedongkui on 2017/11/9.
//  Copyright © 2017年 LY. All rights reserved.
//


#define kWaveBottomColor  [NSColor colorWithRed:160/255.0 green:185/255.0 blue:240/255.0 alpha:1]
#define kWaveTopColor  [NSColor whiteColor]


#import "IPPlayWaveView.h"
#import "FrameAccessor.h"

@interface IPPlayWaveView ()

@end



@implementation IPPlayWaveView

- (instancetype)initWithFrame:(NSRect)frameRect audioFile:(EZAudioFile *)audioFile
{
    self = [super initWithFrame:frameRect];
    if (self) {
        self.audioFile = audioFile;
        [self loadWaveView];
    }
    return self;
}

- (void)loadWaveView
{
    self.audioPlot = [[EZAudioPlot alloc] initWithFrame:NSMakeRect(0, 0, self.width, self.height)];
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
    self.audioPlot.backgroundColor = [NSColor clearColor];
    self.audioPlot.shouldOptimizeForRealtimePlot = NO;
    [self addSubview:self.audioPlot];
    
    __weak typeof (self) weakSelf = self;
    [self.audioFile getWaveformDataWithNumberOfPoints:1024 //值越大，曲线越详细
                                           completion:^(float **waveformData, int length)
     {
         [weakSelf.audioPlot updateBuffer:waveformData[0]
                           withBufferSize:length];
         //获取波形截图
         NSImage *image = [weakSelf makeImageWithColor:kWaveTopColor];
         //
         _indicatViewWaveView = [[IndicatView alloc] initWithFrame:NSMakeRect(0, 0, 0, weakSelf.audioPlot.height)];
         [_indicatViewWaveView drawImage:image frame:weakSelf.audioPlot.frame];
         [weakSelf addSubview:_indicatViewWaveView];
         
         //重设波形的颜色
         weakSelf.audioPlot.color = kWaveBottomColor;
     }];
}

- (NSImage *)makeImageWithColor:(NSColor *)color
{
    self.audioPlot.color = color;

    NSBitmapImageRep *imageRep = [self.audioPlot bitmapImageRepForCachingDisplayInRect:self.audioPlot.bounds];
    [self.audioPlot cacheDisplayInRect:self.audioPlot.bounds toBitmapImageRep:imageRep];
    NSData *data = [imageRep representationUsingType:NSPNGFileType properties:@{}];
    NSImage *image = [[NSImage alloc] initWithData:data];
  
    return image;
}

- (void)mouseUp:(NSEvent *)event
{
    [super mouseUp:event];
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    NSLog(@"x=%f", point.x);
    [self.delegate playWaveView:self didSeekWithValue:(point.x/self.width)];
}



@end




@implementation IndicatView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [_image drawInRect:_totalFrame];
}

- (void)drawImage:(NSImage *)image frame:(NSRect)frame
{
    _image = image;
    _totalFrame = frame;
    [self setNeedsDisplay:YES];
}

@end

