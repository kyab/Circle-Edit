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
    Boolean _bSelected;
    
    float *_leftBuf;
    float *_rightBuf;
    UInt32 _buffer_len;
}

-(void)setBuffer:(float *)left right:(float *)right len:(UInt32)len;

@end
