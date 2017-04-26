//
//  MainView.h
//  Circle Edit
//
//  Created by kyab on 2017/04/13.
//  Copyright © 2017年 kyab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainView : NSView{
    id _dragDropTarget;
    SEL _dragDropAction;
    SEL _dragDropTryAction;
}

-(void)setDragDrop:(id)target action:(SEL)action tryAction:(SEL)tryAction;

@end
