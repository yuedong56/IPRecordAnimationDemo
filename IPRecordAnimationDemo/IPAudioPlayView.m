//
//  IPAudioPlayView.m
//  IPRecordAnimationDemo
//
//  Created by yuedongkui on 2017/11/14.
//  Copyright © 2017年 LY. All rights reserved.
//

#import "IPAudioPlayView.h"
#import "FrameAccessor.h"
#import "SFImageButton.h"
#import "EZAudio/EZAudio.h"
#import "IPPlayWaveView.h"

@interface IPAudioPlayView ()<EZAudioPlayerDelegate, IPPlayWaveViewDelegate>

@property (strong) SFImageButton *playButton;

@property (strong) EZAudioPlayer *player;
@property (nonatomic, strong) EZAudioFile *audioFile;

@property (strong) IPPlayWaveView *waveView;

@end




@implementation IPAudioPlayView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        float playButtonW = 20;
        _playButton = [[SFImageButton alloc] initWithFrame:NSMakeRect(6, (self.height-playButtonW)/2, playButtonW, playButtonW)];
        self.playButton.image = [NSImage imageNamed:@"input_voice"];
        self.playButton.target = self;
        self.playButton.action = @selector(playButtonAction:);
        [self addSubview:_playButton];
        
        
        _audioFile = [EZAudioFile audioFileWithURL:[NSURL fileURLWithPath:@"/Users/yuedongkui/Desktop/1_38.mp3"]];

        
        _player = [EZAudioPlayer audioPlayerWithDelegate:self];
        self.player.audioFile = _audioFile;
        
        
        float gap = 4;
        _waveView = [[IPPlayWaveView alloc] initWithFrame:NSMakeRect(_playButton.right+gap, 0, self.width-_playButton.right-gap, self.height) audioFile:_audioFile];
        self.waveView.delegate = self;
        [self addSubview:_waveView];
    }
    return self;
}

- (void)playButtonAction:(NSButton *)button
{
    if (![self.player isPlaying]) {
        [self.player play];
    }
    else {
        [self.player pause];
    }
}

#pragma mark - EZAudioPlayerDelegate
- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
    updatedPosition:(SInt64)framePosition
        inAudioFile:(EZAudioFile *)audioFile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        float value = (float)framePosition/audioFile.totalFrames;
        self.waveView.indicatViewWaveView.width =  _waveView.indicatViewWaveView.totalFrame.size.width * value;
    });
}


#pragma mark - IPPlayWaveViewDelegate
- (void)playWaveView:(IPPlayWaveView *)playWaveView didSeekWithValue:(float)value
{
    [self.player seekToFrame:(value*self.audioFile.totalFrames)];
}


@end
