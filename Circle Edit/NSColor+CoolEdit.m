//
//  NSColor+CoolEdit.m
//  Circle Edit
//
//  Created by kyab on 2017/04/26.
//  Copyright © 2017年 kyab. All rights reserved.
//

#import "NSColor+CoolEdit.h"

@implementation NSColor(CoolEdit)

+ (NSColor *)ceBGColor{
    return [[NSColor blackColor] colorWithAlphaComponent:0.1];
}

+ (NSColor *)ceWaveColor{
    NSColor *c = [NSColor colorWithSRGBRed:28/255.0 green:240/255.0 blue:171/255.0 alpha:1];
    return c;
}

+ (NSColor *)ceHighlightBGColor{
    return [[NSColor whiteColor] colorWithAlphaComponent:1.0];
}

+ (NSColor *)ceHighlightWaveColor{
    NSColor *c = [NSColor colorWithSRGBRed:32/255.0 green:71/255.0 blue:96/255.0 alpha:1];
    return c;
}



@end
