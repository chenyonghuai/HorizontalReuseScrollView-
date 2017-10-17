//
//  ViewController.m
//  HorizontalReuseScrollView
//
//  Created by chenyonghuai on 15/8/27.
//  Copyright © 2015年 chenyonghuai. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSArray* tableRows;
@property (nonatomic, retain) HorizontalScrollView* hrScrollerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableRows = @[@"view1",@"view2",@"view3",@"view4",@"view5",@"view6",@"view7",@"view8",@"view9",@"view10",@"view11",@"view12"];
    self.hrScrollerView  = [[HorizontalScrollView alloc] initWithFrame:CGRectMake(0, 100, [[UIScreen mainScreen] bounds].size.width, 40)];
    _hrScrollerView.delegate = self;
    _hrScrollerView.dataSource = self
    ;
    [_hrScrollerView setBackgroundColor: [UIColor lightGrayColor]];
    [_hrScrollerView reloadData];
    [self.view addSubview:_hrScrollerView];
}
#pragma mark -  dataSource and delegate methods

- (NSInteger) numberOfRowsInScrollView:(HorizontalScrollView *)scrollView
{
    return self.tableRows.count;
}
-(CGFloat) hrScrollView:(HorizontalScrollView *)hrScrollView widthForRow:(NSInteger)row
{
    return 200;
}

-(ReuseView *)hrScrollView:(HorizontalScrollView *)hrScrollView cellForRow:(NSInteger)row{
    static NSString* pgStandardRowReuseIdentifier = @"Text";
    NSString* reuseIdentifier = pgStandardRowReuseIdentifier;
    
    ReuseView* cell = [hrScrollView  dequeueReusableCellWithIdentifier: reuseIdentifier];
    if (!cell)
    {
        cell = [[ReuseView alloc] initWithReuseIdentifier: reuseIdentifier];
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        [label setText:[self.tableRows objectAtIndex:row]];
        [label setTag: 101];
        [cell addSubview: label];
    }
    return cell;
}




- (void) refresh;
{
    self.tableRows = @[@"view112312313",@"v2312321iew2",@"vi232ew3",@"view4554",@"view45",@"view5566",@"view67777",@"view865757",@"view7657569",@"view67575610",@"view133441",@"view2312"];
    [self.hrScrollerView  reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
