//
//  MainView.m
//  Circle Edit
//
//  Created by kyab on 2017/04/13.
//  Copyright © 2017年 kyab. All rights reserved.
//

#import "MainView.h"

@implementation MainView

- (void)awakeFromNib
{
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

-(void)setDragDrop:(id)target action:(SEL)action tryAction:(SEL)tryAction{
    _dragDropTarget = target;
    _dragDropAction = action;
    _dragDropTryAction = tryAction;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    NSPasteboard *board = [sender draggingPasteboard];
    NSArray *files = [board propertyListForType:NSFilenamesPboardType];
    NSURL *fileURL = [NSURL fileURLWithPath:files[0]];
  
    NSLog(@"dragginEntered");
    
    if (_dragDropTarget){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([_dragDropTarget performSelector:_dragDropTryAction withObject:fileURL.path]){
#pragma clang diagnostic pop
            return NSDragOperationCopy;
        }
    }
    
    return NSDragOperationNone;
}

//- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
//{
//    NSPasteboard *board = [sender draggingPasteboard];
//    NSArray *files = [board propertyListForType:NSFilenamesPboardType];
//    NSURL *fileURL = [NSURL fileURLWithPath:files[0]];
//    
//    NSLog(@"dragginUpdated");
//    return NSDragOperationCopy;
//    
//}

-(BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    NSPasteboard *board = [sender draggingPasteboard];
    NSArray *files = [board propertyListForType:NSFilenamesPboardType];
    NSURL *fileURL = [NSURL fileURLWithPath:files[0]];

    if (_dragDropTarget){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([_dragDropTarget performSelector:_dragDropAction withObject:fileURL.path]){
#pragma clang diagnostic pop
            return YES;
        }
    }
    return NO;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
