//
//  HorizontalRowRecord.m
//  HorizontalReuseScrollView
//
//  Created by chenyonghuai on 15/8/27.
//  Copyright © 2015年 chenyonghuai. All rights reserved.
//

#import "HorizontalRowRecord.h"

@implementation HorizontalRowRecord
- (void) dealloc;
{
    _cachedView =nil;
}

- (NSString*) description;
{
    UITextView* textView =(UITextView*)[[self cachedView] viewWithTag: 101];
    NSString* text = [textView text];
    if ([text length] > 20)
    {
        text = [text substringToIndex: 20];
    }
    
    return [NSString stringWithFormat: @"cachedView: cachedCell %@ ('%@'); start %.2f height: %.2f", [self cachedView], text, [self startPositionX], [self viewWidth]];
    
}

@end
