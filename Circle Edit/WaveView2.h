//
//  WaveView2.h
//  Circle Edit
//
//  Created by kyab on 2017/05/04.
//  Copyright © 2017年 kyab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol WaveView2Delegate <NSObject>
@optional
- (void)waveView2ZoomChanged;
- (void)waveView2SelectionUpdated:(BOOL)bSelected loopStartXRate:(double)startXRate
                     loopEndXRate:(double)endXRate currentXRate:(double)currentXRate;
@end

@interface WaveView2 : NSView
{
    CGFloat _startX;
    CGFloat _currentX;
    
    CGFloat _loopStartX;
    CGFloat _loopEndX;
    
    double _startXRate;
    double _currentXRate;
    double _loopStartXRate;
    double _loopEndXRate;
    
    BOOL _bSelected;
    
    NSBezierPath *_path1;
    NSBezierPath *_path2;
    NSBezierPath *_path3;
    NSBezierPath *_path4;
    
    BOOL _reusePaths;
    
    const float *_leftBuf;
    const float *_rightBuf;
    UInt32 _buffer_len;
    id<WaveView2Delegate> _delegate;
    
    //play cursor-----------------------
    double _playingFrameRate;
    BOOL _isPlaying;
    
    BOOL _normalDragging;
    BOOL _extendDragging;
    BOOL _extendDraggingRight;
    
}

-(void)setBuffer:(const float *)left right:(const float *)right len:(UInt32)len;
-(void)setDelegate:(id<WaveView2Delegate>)delegate;
-(void)resetPaths;

-(void)setPlayingFrameRate:(double) rate;
-(void)setIsPlaying:(BOOL) playing;

@end
