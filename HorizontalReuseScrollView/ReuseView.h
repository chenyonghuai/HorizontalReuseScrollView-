//
//  ReuseView.h
//  HorizontalReuseScrollView
//
//  Created by chenyonghuai on 15/8/27.
//  Copyright © 2015年 chenyonghuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReuseView : UIView
- (id) initWithReuseIdentifier: (nonnull NSString*) reuseIdentifier;

@property (nonatomic, retain,nonnull) NSString* reuseIdentifier;

@end
