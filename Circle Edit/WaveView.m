//
//  WaveView.m
//  Circle Edit
//
//  Created by kyab on 2017/04/16.
//  Copyright © 2017年 kyab. All rights reserved.
//

#import "WaveView.h"
#import "NSColor+CoolEdit.h"
#include <objc/message.h>

@implementation WaveView

- (BOOL)preservesContentDuringLiveResize{
    return YES;
}

- (void)drawRect__:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor blackColor] set];
    NSRectFill([self bounds]);
    
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];
    
    if(_bSelected){

        NSRect rect = [self bounds];

        rect.origin.x = _loopStartX;
        rect.size.width = _loopEndX - _loopStartX;

        [[NSColor ceWaveColor] set];

        NSRectFill(rect);
    }else{
        [[NSColor yellowColor] set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(_currentX, 0)];
        [path lineToPoint:NSMakePoint(_currentX, self.bounds.size.height)];
        [path setLineWidth:0.5];
        CGFloat pat[] = {1.0, 3.0};
        [path setLineDash:pat count:2 phase:0.0];
        [path stroke];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSLog(@"waveview redrawing [%f x %f]" , dirtyRect.size.width, dirtyRect.size.height);
    
    [[NSColor ceBGColor] set];
    NSRectFill([self bounds]);
    
    if (_leftBuf){
        [self drawSample];
    }
    
}

- (void)drawSample{
    
    NSRect bounds = self.bounds;
    float y_addition = bounds.size.height / 2.0f;
    float y_ratio = bounds.size.height / 2.0f;
    
    _currentX = _currentXRate * self.bounds.size.width;
    _loopStartX = _loopStartXRate * self.bounds.size.width;
    _loopEndX = _loopEndXRate * self.bounds.size.width;
    
    
    if (_bSelected){
        NSRect rect = bounds;
        rect.origin.x = _loopStartX;
        rect.size.width = _loopEndX - _loopStartX;
        
        [[NSColor ceHighlightBGColor] set];
        NSRectFill(rect);
    }
    
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];
    
    float samples_per_pixel = (float)_buffer_len / bounds.size.width;
    
    UInt32 sample_from = 1;
    UInt32 sample_to = 0;
    
    if (_bSelected){
        if (!_reusePaths){

            _path1 = [NSBezierPath bezierPath];
            [_path1 setLineWidth:1.0f];
            
            //draw pre selection
            for (UInt32 pixel = 1; pixel < _loopStartX ; pixel++){
                sample_to = (UInt32)floor(pixel * samples_per_pixel);
                
                float max = _leftBuf[sample_from];
                float min = max;
                for(int i =sample_from; i < sample_to; i++){
                    float val = _leftBuf[i];
                    if (val > 0.9) continue;
                    if (val < -0.9) continue;
                    if (val > max) max = val;
                    if (val < min) min = val;
                }
                
                min = (min*y_ratio*1.0) + y_addition;
                max = (max*y_ratio*1.0) + y_addition;
                [_path1 moveToPoint:NSMakePoint(pixel, min)];
                [_path1 lineToPoint:NSMakePoint(pixel, max)];
                
                sample_from = sample_to;
            }
            
        }
        [[NSColor ceWaveColor] set];
        [_path1 stroke];
        
        //draw selection
        if (!_reusePaths){
            _path2 = [NSBezierPath bezierPath];
            [_path2 setLineWidth:1.0f];
            for (UInt32 pixel = _loopStartX; pixel< _loopEndX ; pixel++){
                sample_to = (UInt32)floor(pixel * samples_per_pixel);
                
                float max = _leftBuf[sample_from];
                float min = max;
                for(int i = sample_from; i < sample_to; i++){
                    float val = _leftBuf[i];
                    if (val > 0.9) continue;
                    if (val < -0.9) continue;
                    if (val > max) max = val;
                    if (val < min) min = val;
                }
                
                min = (min*y_ratio*1.0) + y_addition;
                max = (max*y_ratio*1.0) + y_addition;
                [_path2 moveToPoint:NSMakePoint(pixel, min)];
                [_path2 lineToPoint:NSMakePoint(pixel, max)];
                
                sample_from = sample_to;
            }
            
        }
        [[NSColor ceHighlightWaveColor] set];
        [_path2 stroke];
        
        if (!_reusePaths){

            //draw post selection
            _path3 = [NSBezierPath bezierPath];
            [_path3 setLineWidth:1.0f];
            for (SInt32 pixel = _loopEndX; pixel< bounds.size.width ; pixel++){
                sample_to = (UInt32)floor(pixel * samples_per_pixel);
                
                float max = _leftBuf[sample_from];
                float min = max;
                for(int i = sample_from; i < sample_to; i++){
                    float val = _leftBuf[i];
                    if (val > 0.9) continue;
                    if (val < -0.9) continue;
                    if (val > max) max = val;
                    if (val < min) min = val;
                }
                
                min = (min*y_ratio*1.0) + y_addition;
                max = (max*y_ratio*1.0) + y_addition;
                [_path3 moveToPoint:NSMakePoint(pixel, min)];
                [_path3 lineToPoint:NSMakePoint(pixel, max)];
                
                sample_from = sample_to;
            }
            
        }
        [[NSColor ceWaveColor] set];
        [_path3 stroke];
        
    }else{
        if (!_reusePaths){
            
            _path4 = [NSBezierPath bezierPath];
            [_path4 setLineWidth:1.0f];
            
            UInt32 sample_from = 1;
            UInt32 sample_to = 0;
            
            for (UInt32 pixel = 1; pixel < bounds.size.width ; pixel++){
                sample_to = (UInt32)floor(pixel * samples_per_pixel);
                
                float max = _leftBuf[sample_from];
                float min = max;
                for(int i =sample_from; i < sample_to; i++){
                    float val = _leftBuf[i];
                    if (val > 0.9) continue;
                    if (val < -0.9) continue;
                    if (val > max) max = val;
                    if (val < min) min = val;
                }
                
                min = (min*y_ratio*1.0) + y_addition;
                max = (max*y_ratio*1.0) + y_addition;
                [_path4 moveToPoint:NSMakePoint(pixel, min)];
                [_path4 lineToPoint:NSMakePoint(pixel, max)];
                
                sample_from = sample_to;
            }
            
            
        }
        [[NSColor ceWaveColor] set];
        [_path4 stroke];
        
        
        [[NSGraphicsContext currentContext] setShouldAntialias:NO];
        //start cursor
        [[NSColor yellowColor] set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:NSMakePoint(_currentX, 0)];
        [path lineToPoint:NSMakePoint(_currentX, self.bounds.size.height)];
        [path setLineWidth:1.0];
        CGFloat pat[] = {1.0, 3.0};
        [path setLineDash:pat count:2 phase:0.0];
        [path stroke];
        
        
        
    }
    
    _reusePaths = YES;

    [[NSGraphicsContext currentContext] setShouldAntialias:YES];
    


    

}

- (void)drawSample_simple{
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSRect bounds = [self bounds];
    float samples_per_pixel = (float)_buffer_len/bounds.size.width;
    [path setLineWidth:1.0f];
    
    
    float y_addition = bounds.size.height / 2.0f;
    float y_ratio = bounds.size.height / 2.0f;
    
    
    UInt32 sample_from = 1;
    UInt32 sample_to = 0;
    
    for (UInt32 pixel = 1; pixel < bounds.size.width ; pixel++){
        sample_to = (UInt32)floor(pixel * samples_per_pixel);
        
        float max = _leftBuf[sample_from];
        float min = max;
        for(int i =sample_from; i < sample_to; i++){
            float val = _leftBuf[i];
            if (val > 0.9) continue;
            if (val < -0.9) continue;
            if (val > max) max = val;
            if (val < min) min = val;
        }
        
        min = (min*y_ratio*1.0) + y_addition;
        max = (max*y_ratio*1.0) + y_addition;
        [path moveToPoint:NSMakePoint(pixel, min)];
        [path lineToPoint:NSMakePoint(pixel, max)];
        
        sample_from = sample_to;
    }
    
    [[NSColor ceWaveColor] set];
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];
    [path stroke];
    [[NSGraphicsContext currentContext] setShouldAntialias:YES];

}


-(NSPoint)eventLocation:(NSEvent *) theEvent{
    return [self convertPoint:theEvent.locationInWindow fromView:nil];
}

-(NSString *)eventLocationStr:(NSEvent *)theEvent{
    return NSStringFromPoint([self eventLocation:theEvent]);
}

-(void)mouseDown:(NSEvent *)theEvent{
  
    _bSelected = NO;
    _startX = [self eventLocation:theEvent].x;
    _currentX = _startX;
    _loopStartX = _startX;
    _loopEndX = _startX;
    
    _currentXRate = _currentX/self.bounds.size.width;
    _loopStartXRate = _loopStartX/self.bounds.size.width;
    _loopEndXRate = _loopEndX/self.bounds.size.width;
    
    [self selectionUpdated];
    _reusePaths = NO;
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    
    
    CGFloat x = [self eventLocation:theEvent].x;
    if (x < _startX){
        _loopStartX = x;
        if (_loopStartX < 0) _loopStartX = 0;
        _loopEndX = _startX;
    }else{
        if (_startX < x){
            _loopStartX = _startX;
        }
        _loopEndX = x;
    }
    if (fabs(_loopEndX - _loopStartX) <= 1.0f){
        _bSelected = NO;
    }else{
        _bSelected = YES;
    }
    
    _loopStartXRate = _loopStartX/self.bounds.size.width;
    _loopEndXRate = _loopEndX/self.bounds.size.width;
    
    [self selectionUpdated];
    _reusePaths = NO;
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent{
    
    CGFloat x = [self eventLocation:theEvent].x;
    if (x < _startX){
        _loopStartX = x;
        if (_loopStartX < 0) _loopStartX = 0;
        _loopEndX = _startX;
    }else{
        if (_startX < x){
            _loopStartX = _startX;
        }
        _loopEndX = x;
    }
    if (fabs(_loopEndX - _loopStartX) <= 1.0f){
        _bSelected = NO;
    }else{
        _bSelected = YES;
    }
    
    _loopStartXRate = _loopStartX/self.bounds.size.width;
    _loopEndXRate = _loopEndX/self.bounds.size.width;
    
    [self selectionUpdated];
    _reusePaths = NO;
    [self setNeedsDisplay:YES];
    
}

-(BOOL)acceptsFirstResponder{
    return YES;
}



- (void)scrollWheel:(NSEvent *)event{
}

-(void)setBuffer:(const float *)left right:(const float *)right len:(UInt32)len{
    _leftBuf = left;
    _rightBuf = right;
    _buffer_len = len;
    
    
    _startX = 0;
    _currentX = 0;
    
    _loopStartX = 0;
    _loopEndX = 0;
    _bSelected = NO;
    
    _startXRate = 0;
    _currentXRate = 0;
    _loopStartXRate = 0;
    _loopEndXRate = 0;
    
    _reusePaths = NO;
    [self setNeedsDisplay:YES];
}

-(void)setSelectionUpdateNotify:(id)target action:(SEL)callback{
    _selectionUpdateTarget = target;
    _selectionUpdateCallback = callback;
}

-(void)selectionUpdated{
     ((void(*)(id, SEL, BOOL, double ,double, double ))objc_msgSend)(_selectionUpdateTarget,
                 _selectionUpdateCallback,
                 _bSelected,
                 _loopStartXRate,
                 _loopEndXRate,
                 _currentXRate);
}


@end
