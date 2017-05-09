//
//  OverlayView.h
//  Circle Edit
//
//  Created by kyab on 2017/04/30.
//  Copyright © 2017年 kyab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OverlayView : NSView{
    double _playingFrameRate;
    BOOL _isPlaying;
    
    NSRect _prevRect;
}

-(void)setPlayingFrameRate:(double) rate;
-(void)setIsPlaying:(BOOL) playing;

@end
