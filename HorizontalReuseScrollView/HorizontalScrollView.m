//
//  HorizontalScrollView.m
//  HorizontalReuseScrollView
//
//  Created by chenyonghuai on 17/8/27.
//  Copyright © 2017年 chenyonghuai. All rights reserved.
//

#import "HorizontalScrollView.h"
#import "HorizontalRowRecord.h"
#import "ReuseView.h"

@interface HorizontalScrollView ()

@property (nonatomic, retain) NSMutableArray* rowRecords;
@property (nonatomic, retain) NSMutableSet* reusePool;
@property (nonatomic, retain) NSMutableIndexSet* visibleRows;

@end


@implementation HorizontalScrollView

@synthesize reusePool = _hrReusePool;
@synthesize visibleRows = _hrVisibleRows;
@synthesize rowRecords = _hrRowRecords;
@synthesize rowMargin = _hrRowMargin;

- (void) dealloc
{
    _hrReusePool =nil;
    _hrVisibleRows =nil;
    _hrRowRecords =nil;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self)
    {
        [self setup]; // called if created by a xib file
    }
    return self;
}


- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];   // called if programmatically created
    }
    return self;
}
#pragma mark - service methods and lazy instantiation

- (void) setup;
{
    [self setBackgroundColor:[UIColor blueColor]];
    [self setRowWidth:200.0];  // default value for row height
    [self setRowMargin: 20.0];
}

- (NSMutableSet*) reusePool
{
    if (!_hrReusePool)
    {
        _hrReusePool = [[NSMutableSet alloc] init];
    }
    
    return _hrReusePool;
}

- (NSMutableIndexSet*) visibleRows
{
    if (!_hrVisibleRows)
    {
        _hrVisibleRows = [[NSMutableIndexSet alloc] init];
    }
    
    return _hrVisibleRows;
}
#pragma mark - public methods

- (nonnull ReuseView*) dequeueReusableCellWithIdentifier: (NSString*) reuseIdentifier
{
    if ([self disablePool])
    {
        [self setReusePool: nil];   // empty pool
        return nil;                 // force creation of new view every time
    }
    
    ReuseView* poolView = nil;
    
    for (ReuseView* view in [self reusePool])
    {
        if ([[view reuseIdentifier] isEqualToString: reuseIdentifier])
        {
            poolView = view;
            break;
        }
    }
    
    if (poolView)
    {
        [[self reusePool] removeObject: poolView];
    }
    
     [self logPool: reuseIdentifier andCell: poolView];
    
    return poolView;
}



- (void) reloadData
{
    [self returnNonVisibleRowsToThePool: nil];
    [self generatewidthAndOffsetData];
    [self layoutScrollViewRows];
}



// bonus content - change the height of just one row w/o asking every row for new height
- (void) row: (NSInteger) row changedWidth: (CGFloat) width
{
    HorizontalRowRecord* rowRecord = (HorizontalRowRecord*)[[self rowRecords] objectAtIndex: row];
    CGFloat adjust = width - [rowRecord viewWidth];
    [rowRecord setViewWidth: width];
    
    if ([rowRecord cachedView])
    {
        [[rowRecord cachedView] removeFromSuperview];
        [[self reusePool] addObject: [rowRecord cachedView]];
        [rowRecord setCachedView: nil];
    }
    
    for (NSInteger index = row + 1; index < [[self rowRecords] count]; index++)
    {
        rowRecord = (HorizontalRowRecord*)[[self rowRecords] objectAtIndex: index];
        [rowRecord setStartPositionX: [rowRecord startPositionX] + adjust];
        
        if ([rowRecord cachedView])
        {
            [[rowRecord cachedView] removeFromSuperview];
            [[self reusePool] addObject: [rowRecord cachedView]];
            [rowRecord setCachedView: nil];
        }
    }
    
    [self setContentSize: CGSizeMake([self contentSize].width+adjust, [self contentSize].height)];
    
    [self layoutScrollViewRows];
}


- (NSIndexSet*) indexSetOfVisibleRows
{
    return [[self visibleRows] copy] ;
}
#pragma mark - scrollView overrides

- (void) setContentOffset:(CGPoint)contentOffset //  note: this method called frequently - needs to be fast
{
    [super setContentOffset: contentOffset];
    [self layoutScrollViewRows];
}


#pragma mark - Layout
-(void)layoutScrollViewRows
{
    CGFloat currentStartX = [self contentOffset].x;
    CGFloat currentEndX = currentStartX+[self frame].size.width;
    
    NSUInteger rowToDisplay = [self findRowForOffsetX:currentStartX inRange:NSMakeRange(0, [[self rowRecords] count])];
    
    NSMutableIndexSet* newVisibleRows = [[NSMutableIndexSet alloc] init];
    
    CGFloat XOrigin;
    CGFloat rowWidth;
    do{
        [newVisibleRows addIndex:rowToDisplay];
        XOrigin = [self startPositionXForRow:rowToDisplay];
        rowWidth = [self widthForRow:rowToDisplay];
        ReuseView *view = [self cachedViewForRow:rowToDisplay];
        if (!view) {
            view = [[self dataSource]hrScrollView:self cellForRow:rowToDisplay];
            [self setCachedView:view forRow:rowToDisplay];
            [view setFrame:CGRectMake(XOrigin, 0.0, rowWidth-_hrRowMargin, [self bounds].size.height)];
            [self addSubview:view];
        }
        rowToDisplay++;
    }
    while (XOrigin + rowWidth < currentEndX && rowToDisplay < [[self rowRecords] count]);
    
    
    NSLog(@"laying out %ld row", [newVisibleRows count]);
    
    [self returnNonVisibleRowsToThePool: newVisibleRows];

}

- (void) returnNonVisibleRowsToThePool: (NSMutableIndexSet*) currentVisibleRows
{
    [[self visibleRows] removeIndexes: currentVisibleRows];
    [[self visibleRows] enumerateIndexesUsingBlock:^(NSUInteger row, BOOL *stop)
     {
         ReuseView* tableViewCell = [self cachedViewForRow: row];
         if (tableViewCell)
         {
             [[self reusePool] addObject: tableViewCell];
             [tableViewCell removeFromSuperview];
             [self setCachedView: nil forRow: row];
         }
     }];
    [self setVisibleRows: currentVisibleRows];
}
- (void) generatewidthAndOffsetData
{
    CGFloat currentOffsetX= 0.0;
    
    BOOL checkWidthForEachRow = [[self delegate] respondsToSelector: @selector(hrScrollView:widthForRow:)];
    
    NSMutableArray* newRowRecords = [NSMutableArray array];
    
    NSInteger numberOfRows = [[self dataSource] numberOfRowsInScrollView: self];
    
    for (NSInteger row = 0; row < numberOfRows; row++)
    {
        HorizontalRowRecord* rowRecord = [[HorizontalRowRecord alloc] init];
        
        CGFloat rowWidth = checkWidthForEachRow ? [[self delegate] hrScrollView: self widthForRow: row] : [self rowWidth];
        
        [rowRecord setViewWidth: rowWidth + _hrRowMargin];
        [rowRecord setStartPositionX: currentOffsetX + _hrRowMargin];
        
        [newRowRecords insertObject: rowRecord atIndex: row];
        
        currentOffsetX= currentOffsetX + rowWidth + _hrRowMargin;
    }
    
    [self setRowRecords: newRowRecords];
    [self setContentSize: CGSizeMake(currentOffsetX,[self bounds].size.height)];
}


- (NSInteger) findRowForOffsetX: (CGFloat) xPosition inRange: (NSRange) range
{
    if ([[self rowRecords] count] == 0) return 0;
    
    HorizontalRowRecord* rowRecord = [[HorizontalRowRecord alloc] init];
    [rowRecord setStartPositionX: xPosition];
    
    NSInteger returnValue = [[self rowRecords] indexOfObject: rowRecord
                                               inSortedRange: NSMakeRange(0, [[self rowRecords] count])
                                                     options: NSBinarySearchingInsertionIndex
                                             usingComparator: ^NSComparisonResult(HorizontalRowRecord* rowRecord1, HorizontalRowRecord* rowRecord2){
                                                 if ([rowRecord1 startPositionX] < [rowRecord2 startPositionX]) return NSOrderedAscending;
                                                 return NSOrderedDescending;
                                             }];
    if (returnValue == 0) return 0;
    return returnValue-1;
}

#pragma mark - convenience methods for accessing row records

- (CGFloat) startPositionXForRow: (NSInteger) row
{
    return [(HorizontalRowRecord*)[[self rowRecords] objectAtIndex: row] startPositionX];
}

- (CGFloat) widthForRow: (NSInteger) row
{
    return [(HorizontalRowRecord*)[[self rowRecords] objectAtIndex: row] viewWidth];
}

- (nonnull ReuseView*) cachedViewForRow: (NSInteger) row
{
    return [(HorizontalRowRecord*)[[self rowRecords] objectAtIndex: row] cachedView];
}

- (void) setCachedView: (nullable ReuseView*) view forRow: (NSInteger) row
{
    [(HorizontalRowRecord*)[[self rowRecords] objectAtIndex: row] setCachedView: view];
}

#pragma mark - logging and debugging

- (void) logPool: (NSString*) reuseIdentifier andCell: (ReuseView*) view

{
    NSArray* poolIds= [[[self reusePool] allObjects] valueForKey: @"reuseIdentifier"];
    NSString* poolDescription = [poolIds componentsJoinedByString: @", "];
    
    NSString* recycle = @"Recyling a";
    if (!view)
    {
        recycle = @"Making a new";
    }
    
    NSLog(@"%@ %@ cell. Pool contains %ld items (%@)", recycle, reuseIdentifier, [[self reusePool] count], poolDescription);
}



- (NSInteger) OLDfindRowForOffsetX: (CGFloat) xPosition inRange: (NSRange) range
{
    if (range.length < 2)
    {
        return (range.location<1) ? range.location : range.location - 1;
    }
    
    NSInteger halfwayMark = range.length / 2;
    
    if (xPosition > [self startPositionXForRow: range.location + halfwayMark])
    {
        return [self findRowForOffsetX: xPosition inRange: NSMakeRange(range.location + (halfwayMark + 1), range.length - (halfwayMark +1))];
    }
    else
    {
        return [self findRowForOffsetX: xPosition inRange: NSMakeRange(range.location, range.length - halfwayMark)];
    }
}


- (NSInteger) inefficientFindRowForOffsetX: (CGFloat) xPosition inRange: (NSRange) range
{
    if (range.length == 0) return 0;
    
    NSInteger row = range.location;
    
    while (row < range.length)
    {
        if (xPosition < [self startPositionXForRow: row]) return (row<1) ? row : row - 1;
        row++;
    }
    row--;
    return row;
}


@end
