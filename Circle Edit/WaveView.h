//
//  WaveView.h
//  Circle Edit
//
//  Created by kyab on 2017/04/16.
//  Copyright © 2017年 kyab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WaveView : NSView{
    
    CGFloat _startX;
    CGFloat _currentX;
        
    CGFloat _loopStartX;
    CGFloat _loopEndX;
    BOOL _bSelected;
    
    double _startXRate;
    double _currentXRate;
    double _loopStartXRate;
    double _loopEndXRate;
    
    NSBezierPath *_path1;
    NSBezierPath *_path2;
    NSBezierPath *_path3;
    NSBezierPath *_path4;
    
    BOOL _reusePaths;
    
    const float *_leftBuf;
    const float *_rightBuf;
    UInt32 _buffer_len;
    
    SEL _selectionUpdateCallback;
    id _selectionUpdateTarget;
}

-(void)setBuffer:(const float *)left right:(const float *)right len:(UInt32)len;
-(void)setSelectionUpdateNotify:(id)target action:(SEL)callback;
@end
