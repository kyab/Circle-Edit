//
//  OutlineView.h
//  Circle Edit
//
//  Created by kyab on 2017/05/04.
//  Copyright © 2017年 kyab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol OutlineViewDelegate <NSObject>
@optional
- (void)outlineViewScrolled;
@end

@interface OutlineView : NSView
{
    double _currentWidth;
    
    //dragging
    BOOL _dragging;
    CGFloat _startX;
    CGFloat _dragStartCurrentX;
    
    CGFloat _currentX;
    
    id<OutlineViewDelegate> _delegate;
    
    NSTrackingArea *_trackingArea;
}

-(void)setPosition:(CGFloat)currentXRate width:(double)currentWidthRate;
-(void)setDelegate:(id<OutlineViewDelegate>)delegate;
-(CGFloat)currentX;

@end
