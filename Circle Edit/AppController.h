//
//  ViewController.h
//  Circle Edit
//
//  Created by kyab on 2017/04/12.
//  Copyright © 2017年 kyab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WaveView.h"
#import "WaveView2.h"
#import "OutlineView.h"
#import "OverlayView.h"
#import "AudioEngine.h"

#define BUFFER_SIZE_SAMPLE 44100*10*60

@interface AppController : NSViewController{
    
    __weak IBOutlet WaveView *_waveView;
    __weak IBOutlet OverlayView *_overlayView;
    __weak IBOutlet NSScrollView *_scrollView;
    __weak IBOutlet WaveView2 *_waveView2;
    __weak IBOutlet OutlineView *_outlineView;
    __weak IBOutlet NSButton *_btnStartStop;
    float _leftBuf[BUFFER_SIZE_SAMPLE];
    float _rightBuf[BUFFER_SIZE_SAMPLE];
    UInt32 _buffer_len;
    
    NSTimer *_timer;
    
    UInt32 _loopStartFrame;
    UInt32 _loopEndFrame;
    UInt32 _noLoopStartFrame;
    UInt32 _playingFrame;
    BOOL _bSelected;
    
    BOOL _scrollingByOutline;
    
    AudioEngine *ae;
    
}

-(BOOL)loadFile:(NSString *)path;

@end

