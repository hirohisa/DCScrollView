//
//  DemoViewController.m
//  Demo
//
//  Created by Hirohisa Kawasaki on 13/03/29.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import "DemoViewController.h"

@interface DemoViewController ()
@property (nonatomic, strong) DCScrollView *scrollView;
@end

@implementation DemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
    self.view.clipsToBounds = YES;
    _scrollView = [[DCScrollView alloc]initWithFrame:self.view.bounds];
    self.scrollView.focusedCenter = YES;
    self.scrollView.dataSource = self;
    self.scrollView.delegate = self;
    [self.scrollView setFont:[UIFont systemFontOfSize:15.] textColor:[UIColor grayColor] highlightedTextColor:[UIColor redColor]];
    [self.view addSubview:self.scrollView];
    [self.scrollView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - DCScrollViewDataSource

- (NSInteger)numberOfCellsInDCScrollView:(DCScrollView *)scrollView
{
    if (self.numerOfCells) {
        return self.numerOfCells;
    }
    return 1;
}

- (DCScrollViewCell *)dcScrollView:(DCScrollView *)scrollView cellAtIndex:(NSInteger)index
{
    NSString *identifier = @"DCScrollView";
    DCScrollViewCell *cell = [scrollView dequeueReusableCellWithIdentifier:identifier];
    NSInteger tag = 111111;
    if (cell == nil) {
        cell  = [[DCScrollViewCell alloc] initWithReuseIdentifier:identifier];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.center = cell.center;
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.tag = tag;
        [cell addSubview:label];
    }
    UILabel *label = (UILabel *)[cell viewWithTag:tag];
    label.frame = CGRectMake(0, 0, CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds));
    label.text = [NSString stringWithFormat:@"title %d", index];
    return cell;
}

- (NSString *)dcTitleScrollViewCellTitleAtIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"title %d", index];
}

- (void)dcScrollViewDidScroll:(DCScrollView *)scrollView didChangeVisibleCell:(DCScrollViewCell *)cell atIndex:(NSInteger)index
{
    UILabel *label = (UILabel *)[cell viewWithTag:111111];
    NSLog(@"%d:%@", index, label.text);
}
@end
