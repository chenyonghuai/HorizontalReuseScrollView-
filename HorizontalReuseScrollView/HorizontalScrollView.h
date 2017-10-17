//
//  HorizontalScrollView.h
//  HorizontalReuseScrollView
//
//  Created by chenyonghuai on 17/8/27.
//  Copyright © 2017年 chenyonghuai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReuseView.h"

@class HorizontalScrollView;

@protocol HRScrollViewDelegate<NSObject, UIScrollViewDelegate>

@optional
- (CGFloat)hrScrollView:(nullable HorizontalScrollView*) hrScrollView widthForRow: (NSInteger) row;

@end

@protocol HRScrollViewDataSource;


@interface HorizontalScrollView : UIScrollView
@property (nonatomic, weak, nullable)  id<HRScrollViewDelegate> delegate;
@property (nonatomic, weak, nullable)  id<HRScrollViewDataSource> dataSource;


@property (nonatomic) CGFloat rowWidth; // default to scren - ignored if delegate responds to pgTableView:heightForRow:
@property (nonatomic) CGFloat rowMargin; // default to 2.0

- (nonnull ReuseView*) dequeueReusableCellWithIdentifier: (nullable NSString*) reuseIdentifier;
- (void) reloadData;

- (void) row: (NSInteger) row changedWidth: (CGFloat) width;  // change height of one row w/o triggering request for row heights

- (nullable NSIndexSet*) indexSetOfVisibleRows;

// exposed here so we can run test measurements - but not part of public interface
- (NSInteger) findRowForOffsetX: (CGFloat) xPosition inRange: (NSRange) range;
- (NSInteger) inefficientFindRowForOffsetX: (CGFloat) xPosition inRange: (NSRange) range;
- (NSInteger) OLDfindRowForOffsetX: (CGFloat) xPosition inRange: (NSRange) range;

@property (nonatomic) BOOL disablePool;

@end

@protocol HRScrollViewDataSource<NSObject>

@required
- (NSInteger) numberOfRowsInScrollView: (nonnull HorizontalScrollView*) scrollView;
- (nonnull ReuseView*) hrScrollView:(nonnull HorizontalScrollView*)hrScrollView cellForRow: (NSInteger) row;

@end

