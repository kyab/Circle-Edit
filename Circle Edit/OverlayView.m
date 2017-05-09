//
//  OverlayView.m
//  Circle Edit
//
//  Created by kyab on 2017/04/30.
//  Copyright © 2017年 kyab. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView


-(void)setPlayingFrameRate:(double) rate{
    _playingFrameRate = rate;
    //[self setNeedsDisplayInRect:_prevRect];
    [self setNeedsDisplay:YES];
}

-(void)setIsPlaying:(BOOL) playing{
    _isPlaying = playing;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSLog(@"overlayview redrawing [%f x %f]" , dirtyRect.size.width, dirtyRect.size.height);
    
    if (!_isPlaying) return;
    
    
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line setLineWidth:1.0f];
    
    [line moveToPoint:NSMakePoint(self.bounds.size.width*_playingFrameRate
                                  ,0)];
    [line lineToPoint:NSMakePoint(self.bounds.size.width*_playingFrameRate,
                                  self.bounds.size.height)];
    
    _prevRect.origin = NSMakePoint(self.bounds.size.width*_playingFrameRate-1.0,
                                  0 );
    _prevRect.size.width=3.0;
    _prevRect.size.height = self.bounds.size.height;
    
    [[NSColor whiteColor] set];
    [line stroke];
    
}


@end
