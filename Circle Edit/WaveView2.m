//
//  WaveView2.m
//  Circle Edit
//
//  Created by kyab on 2017/05/04.
//  Copyright © 2017年 kyab. All rights reserved.
//

#import "WaveView2.h"
#import "NSColor+CoolEdit.h"

@implementation WaveView2


- (void)awakeFromNib{
    NSLog(@"WaveView2 awaken");
    [self setFrame:self.superview.bounds];
    NSRect rect = [self frame];
    //rect.size.width = rect.size.width * 3;
    [self setFrame:rect];
    [_delegate waveView2ZoomChanged];
    [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor ceBGColor] set];
    NSRectFill([self bounds]);
    
    if (_leftBuf){
        [self drawSample];
        if (_isPlaying){
            [self drawPlayCursor];
        }
    }
    

    
}

-(void)drawSample{
    if ([self inLiveResize]){
        NSLog(@"isInLiveResize");
    }else{

    }
    
    
    NSRect bounds = self.bounds;
    float y_addition = bounds.size.height / 2.0f;
    float y_ratio = bounds.size.height / 2.0f;

    _currentX = _currentXRate * self.bounds.size.width;
    _loopStartX = _loopStartXRate * self.bounds.size.width;
    _loopEndX = _loopEndXRate * self.bounds.size.width;
    
    
    if (_bSelected) {
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
                if (max-min < 0.0001) max = 0.0001;   //avoid looks like no data.
                
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
                if (max-min < 0.0001) max = 0.0001;   //avoid looks like no data.
                
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
                if (max-min < 0.0001) max = 0.0001;   //avoid looks like no data.
                
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
                if (max-min < 0.0001) max = 0.0001;   //avoid looks like no data.
                
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


-(void)drawPlayCursor
{
    if (!_isPlaying) return;
    
    
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];
    [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositingOperationXOR];
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line setLineWidth:1.0f];
    
    [line moveToPoint:NSMakePoint(self.bounds.size.width*_playingFrameRate
                                  ,0)];
    [line lineToPoint:NSMakePoint(self.bounds.size.width*_playingFrameRate,
                                  self.bounds.size.height)];
    
    [[NSColor whiteColor] set];
    [line stroke];
    
    [[NSGraphicsContext currentContext] setShouldAntialias:YES];
    
}

-(NSPoint)eventLocation:(NSEvent *) theEvent{
    return [self convertPoint:theEvent.locationInWindow fromView:nil];
}

-(NSString *)eventLocationStr:(NSEvent *)theEvent{
    return NSStringFromPoint([self eventLocation:theEvent]);
}

-(void)mouseDown:(NSEvent *)theEvent{
    
    _normalDragging = NO;
    _extendDragging = NO;
    _extendDraggingRight = NO;
    if ((theEvent.modifierFlags & NSEventModifierFlagShift) ||
        //shift + click / right click
        ([NSEvent pressedMouseButtons] & (1<<1)) ){
        _extendDragging = YES;
        [self extendMouseDown:theEvent];
    }else{
        //normal left click
        _normalDragging = YES;
        [self normalMouseDown:theEvent];
    }
}

-(void)rightMouseDown:(NSEvent *)theEvent{
    NSLog(@"mouse down(right)");
    [self extendMouseDown:theEvent];
}


-(void)normalMouseDown:(NSEvent *)theEvent{
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

-(void)extendMouseDown:(NSEvent *)theEvent{
    _bSelected = YES;
    CGFloat x = [self eventLocation:theEvent].x;
    if (x > _currentX){
        _startX = _currentX;
        _loopStartX = _currentX;
        _loopEndX = x;
        _extendDraggingRight = YES;
    }else{
        _startX = _loopEndX;
        _currentX = x;
        _loopStartX = x;
        _extendDraggingRight = NO;
        
    }
    
    _currentXRate = _currentX/self.bounds.size.width;
    _loopStartXRate = _loopStartX/self.bounds.size.width;
    _loopEndXRate = _loopEndX/self.bounds.size.width;
    
    [self selectionUpdated];
    _reusePaths = NO;
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    if (_normalDragging){
        [self normalMouseDragged:theEvent];
    }else{
        [self extendMouseDragged:theEvent];
    }
}

- (void)rightMouseDragged:(NSEvent *)theEvent{
    [self extendMouseDragged:theEvent];
}

- (void)normalMouseDragged:(NSEvent *)theEvent{

    CGFloat x = [self eventLocation:theEvent].x;
    if (x < _startX){
        _loopStartX = x;
        if (_loopStartX < 0) _loopStartX = 0;
        _currentX = _loopStartX;
        _loopEndX = _startX;
    }else{
        if (_startX < x){
            _loopStartX = _startX;
            _currentX = _loopStartX;
        }
        _loopEndX = x;
    }
    if (fabs(_loopEndX - _loopStartX) <= 1.0f){
        _bSelected = NO;
    }else{
        _bSelected = YES;
    }
    
    _currentXRate = _currentX/self.bounds.size.width;
    _loopStartXRate = _loopStartX/self.bounds.size.width;
    _loopEndXRate = _loopEndX/self.bounds.size.width;
    
    [self selectionUpdated];
    _reusePaths = NO;
    [self setNeedsDisplay:YES];
}

- (void)extendMouseDragged:(NSEvent *)theEvent{
    
    CGFloat x = [self eventLocation:theEvent].x;
    
    if (_extendDraggingRight){
        if (x > _startX){
            _loopStartX = _startX;
            _currentX = _loopStartX;
            _loopEndX = x;
        }else{
            _loopStartX = x;
            if (_loopStartX < 0) _loopStartX = 0;
            _currentX = _loopStartX;
            _loopEndX = _startX;
        }
    }else{
        if (x > _startX){
            _loopStartX =  _startX;
            _currentX = _loopStartX;
            _loopEndX = x;
        }else{
            _loopStartX = x;
            if (_loopStartX < 0) _loopStartX = 0;
            _currentX = _loopStartX;
            _loopEndX = _startX;
        }
    }
    
    if (fabs(_loopEndX - _loopStartX) <= 1.0f){
        _bSelected = NO;
    }else{
        _bSelected = YES;
    }
    
    _currentXRate = _currentX/self.bounds.size.width;
    _loopStartXRate = _loopStartX/self.bounds.size.width;
    _loopEndXRate = _loopEndX/self.bounds.size.width;
    
    [self selectionUpdated];
    _reusePaths = NO;
    [self setNeedsDisplay:YES];
}






-(void)mouseUp:(NSEvent *)theEvent{
    [self normalMouseUp:theEvent];
}

-(void)rightMouseUp:(NSEvent *)theEvent{
    [self normalMouseUp:theEvent];
}

- (void)normalMouseUp:(NSEvent *)theEvent{
    
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

#define KEY_LEFT_ARROW 123
#define KEY_RIGHT_ARROW 124

- (void)keyDown:(NSEvent *)theEvent{
    
    _currentX = _currentXRate * self.bounds.size.width;
    _loopStartX = _loopStartXRate * self.bounds.size.width;
    _loopEndX = _loopEndXRate * self.bounds.size.width;
    
    BOOL processed = NO;
    if (theEvent.modifierFlags & NSEventModifierFlagShift){
        
        if (theEvent.keyCode == KEY_LEFT_ARROW){
            if (_bSelected){
                _loopEndX -= 1;
                if (_loopEndX <= _loopStartX){
                    _bSelected = NO;
                    _currentX = _loopStartX;
                }
            }else{
                _currentX -= 1;
                if (_currentX < 0) _currentX = 0;
            }
            processed = YES;
        }else if (theEvent.keyCode == KEY_RIGHT_ARROW){
            if (_bSelected){
                _loopEndX += 1;
            }else{
                _loopStartX = _currentX;
                _loopEndX = _loopStartX+1;
                _bSelected = YES;
            }
            processed = YES;
        }
    }else{
        if (theEvent.keyCode == KEY_LEFT_ARROW){
            if (_bSelected){
                _loopStartX -= 1;
                if (_loopStartX < 0) _loopStartX = 0;
            }else{
                _loopStartX = _currentX - 1;
                if (_loopStartX < 0 ) _loopStartX = 0;
                _loopEndX = _currentX;
                _bSelected = YES;
            }
            processed = YES;
        }else if (theEvent.keyCode == KEY_RIGHT_ARROW){
            if (_bSelected){
                _loopStartX += 1;
                if (_loopEndX <= _loopStartX ){
                    _bSelected = NO;
                    _currentX = _loopEndX;
                }
            }else{
                _currentX += 1;
            }
            processed = YES;
            
        }
    }
    if (processed){
        _currentXRate = _currentX/self.bounds.size.width;
        _loopStartXRate = _loopStartX/self.bounds.size.width;
        _loopEndXRate = _loopEndX/self.bounds.size.width;
        [self selectionUpdated];
        _reusePaths = NO;
        [self setNeedsDisplay:YES];
    }else{
        [self.nextResponder keyDown:theEvent];
    }
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


-(void)setDelegate:(id<WaveView2Delegate>)delegate{
    _delegate = delegate;
}

-(void)resetPaths{
    _reusePaths = NO;
}


- (void)scrollWheel:(NSEvent *)event{
    //NSLog(@"Scroll wheel scrollingDeltaY:%f , deltaY:%f",  event.scrollingDeltaY, event.deltaY);
    
    if (fabs(event.deltaY) > fabs(event.deltaX)){
        NSRect rect = [self frame];
        float alpha = 0.01;
        rect.size.width = rect.size.width * (1.0 + alpha * event.deltaY);
        if (rect.size.width < self.superview.bounds.size.width){
            rect.size.width = self.superview.bounds.size.width;
        }
        [self setFrame:rect];
        [_delegate waveView2ZoomChanged];
        
        [self setNeedsDisplay:YES];
    }else if (fabs(event.deltaX) > fabs(event.deltaY)){
        NSPoint currentPoint = self.superview.bounds.origin;
        currentPoint.x -= event.deltaX*5;
        [self scrollPoint:currentPoint];
        
    }
    
}

-(void)selectionUpdated{
    [_delegate waveView2SelectionUpdated:_bSelected loopStartXRate:_loopStartXRate loopEndXRate:_loopEndXRate currentXRate:_currentXRate];
}

-(void)setPlayingFrameRate:(double) rate{
    _playingFrameRate = rate;
    //[self setNeedsDisplayInRect:_prevRect];
    [self setNeedsDisplay:YES];
}

-(void)setIsPlaying:(BOOL) playing{
    _isPlaying = playing;
    [self setNeedsDisplay:YES];
}




@end
