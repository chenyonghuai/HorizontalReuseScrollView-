//
//  ReuseView.m
//  HorizontalReuseScrollView
//
//  Created by chenyonghuai on 15/8/27.
//  Copyright © 2015年 chenyonghuai. All rights reserved.
//

#import "ReuseView.h"

@implementation ReuseView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id) initWithReuseIdentifier: (nonnull NSString*) reuseIdentifier;
{
    self = [super initWithFrame: CGRectZero];
    if (self)
    {
        [self setReuseIdentifier: reuseIdentifier];
        [self setBackgroundColor: [UIColor whiteColor]];
    }
    return self;
}

@end
