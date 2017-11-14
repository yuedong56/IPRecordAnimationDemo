//
//  WaveView.h
//  IPRecordAnimationDemo
//
//  Created by yuedongkui on 2017/11/9.
//  Copyright © 2017年 LY. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EZAudio/EZAudio.h"


@class IPPlayWaveView;
@protocol IPPlayWaveViewDelegate <NSObject>

- (void)playWaveView:(IPPlayWaveView *)playWaveView didSeekWithValue:(float)value;

@end

@class IndicatView;
@interface IPPlayWaveView : NSView

@property (weak) id <IPPlayWaveViewDelegate> delegate;

@property (nonatomic,strong) EZAudioFile *audioFile;
@property (strong) EZAudioPlot *audioPlot;
@property (strong) IndicatView *indicatViewWaveView;

- (instancetype)initWithFrame:(NSRect)frameRect audioFile:(EZAudioFile *)audioFile;


@end



@interface IndicatView : NSView

@property (strong) NSImage *image;
@property (assign) NSRect totalFrame;

- (void)drawImage:(NSImage *)image frame:(NSRect)frame;

@end
