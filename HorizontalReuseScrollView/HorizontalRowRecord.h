//
//  HorizontalRowRecord.h
//  HorizontalReuseScrollView
//
//  Created by chenyonghuai on 15/8/27.
//  Copyright © 2015年 chenyonghuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import  "ReuseView.h"

@interface HorizontalRowRecord : NSObject
@property (nonatomic) CGFloat startPositionX;
@property (nonatomic) CGFloat viewWidth;
@property (nonatomic, retain) ReuseView* cachedView;

@end
