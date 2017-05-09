//
//  OutlineView.m
//  Circle Edit
//
//  Created by kyab on 2017/05/04.
//  Copyright © 2017年 kyab. All rights reserved.
//

#import "OutlineView.h"
#import "NSColor+CoolEdit.h"

@implementation OutlineView

- (void)awakeFromNib{
    NSLog(@"OutlineView awaken");
    
    
    [self setNeedsDisplay:YES];
    
    
    
    
}

-(void)setDelegate:(id<OutlineViewDelegate>)delegate{
    _delegate = delegate;
}

-(void)setPosition:(CGFloat)currentXRate width:(double)currentWidthRate
{
    _currentX = currentXRate * self.bounds.size.width;
    _currentWidth = currentWidthRate * self.bounds.size.width;
    [self setNeedsDisplay:YES];
    
    [self resetTrackingArea];
    
}

-(void)resetTrackingArea{
    //update tracking area
    if (_trackingArea != nil){
        [self removeTrackingArea:_trackingArea];
    }
    
    int opts = NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways ;
    
    NSRect rect = self.bounds;
    rect.origin.x = _currentX;
    rect.size.width = _currentWidth;
    
    _trackingArea = [[NSTrackingArea alloc] initWithRect:rect
                                                  options:opts
                                                    owner:self
                                                 userInfo:nil];
    [self addTrackingArea:_trackingArea];
    
}

-(CGFloat)currentX{
    return _currentX;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor blackColor] set];
    NSRectFill(dirtyRect);
    
    NSRect rect = self.bounds;
    rect.origin.x = _currentX;
    rect.size.width = _currentWidth;
    
    [[NSColor ceWaveColor] set];
    NSRectFill(rect);
    
}


-(NSPoint)eventLocation:(NSEvent *) theEvent{
    return [self convertPoint:theEvent.locationInWindow fromView:nil];
}

-(NSString *)eventLocationStr:(NSEvent *)theEvent{
    return NSStringFromPoint([self eventLocation:theEvent]);
}

-(void)mouseEntered:(NSEvent *)theEvent{
    NSLog(@"mouse enter");
    [[NSCursor openHandCursor] set];
}

-(void)mouseMoved:(NSEvent *)theEvent{
    NSLog(@"mouse moved");
}

-(void)mouseExited:(NSEvent *)theEvent{
    NSLog(@"mouse exited");
    [[NSCursor arrowCursor] set];
}


-(void)mouseDown:(NSEvent *)theEvent{
    
    CGFloat x =  [self eventLocation:theEvent].x;
    if ( (_currentX < x) &&
         (x < _currentX+_currentWidth) ){
        _dragging = YES;
        _startX = [self eventLocation:theEvent].x;
        _dragStartCurrentX = _currentX;
        
        [[NSCursor closedHandCursor] set];
        

    }else{
        _dragging = NO;
        _startX = 0.0f;
    }
}

-(void)mouseDragged:(NSEvent *)theEvent{
    if (_dragging){
        CGFloat x = [self eventLocation:theEvent].x;
        if (x - _startX > 0) {
            _currentX =  _dragStartCurrentX + (x - _startX);
        }else{
            _currentX = _dragStartCurrentX - (_startX - x);
        }
        
        if (self.bounds.size.width < _currentX + _currentWidth ){
            _currentX = self.bounds.size.width - _currentWidth;
        }else if (_currentX < 0){
            _currentX = 0;
        }

        [[NSCursor closedHandCursor] set];
        
        [self setNeedsDisplay:YES];
        [_delegate outlineViewScrolled];
    }
}

-(void)mouseUp:(NSEvent *)theEvent{
    if (_dragging){
        
        CGFloat x = [self eventLocation:theEvent].x;
        if (x - _startX > 0) {
            _currentX =  _dragStartCurrentX + (x - _startX);
        }else{
            _currentX = _dragStartCurrentX - (_startX - x);
        }
        
        if (self.bounds.size.width < _currentX + _currentWidth ){
            _currentX = self.bounds.size.width - _currentWidth;
        }else if (_currentX < 0){
            _currentX = 0;
        }
        
        [[NSCursor arrowCursor] set];
        [self resetTrackingArea];
        
        [self setNeedsDisplay:YES];
        [_delegate outlineViewScrolled];
        

    }
    _dragging = NO;
}





@end
