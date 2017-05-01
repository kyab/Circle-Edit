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
    Boolean _isPlaying;
}

-(void)setPlayingFrameRate:(double) rate;
-(void)setIsPlaying:(Boolean) playing;

@end
