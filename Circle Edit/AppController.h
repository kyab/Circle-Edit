//
//  ViewController.h
//  Circle Edit
//
//  Created by kyab on 2017/04/12.
//  Copyright © 2017年 kyab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WaveView.h"

#define BUFFER_SIZE_SAMPLE 44100*10*60

@interface AppController : NSViewController{
    
    __weak IBOutlet WaveView *_waveView;
    float _leftBuf[BUFFER_SIZE_SAMPLE];
    float _rightBuf[BUFFER_SIZE_SAMPLE];
    UInt32 _buffer_len;
    
    
}

-(Boolean)loadFile:(NSString *)path;

@end

