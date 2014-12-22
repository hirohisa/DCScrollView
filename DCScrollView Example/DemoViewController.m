//
//  DemoViewController.m
//  Demo
//
//  Created by Hirohisa Kawasaki on 13/03/29.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import "DemoViewController.h"

@interface DemoDCScrollViewCell : DCScrollViewCell
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation DemoDCScrollViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.textLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.center = (CGPoint) {
        .x = CGRectGetWidth(self.frame)/2,
        .y = CGRectGetHeight(self.frame)/2
    };
}

@end

@implementation DemoViewController

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

    UIBarButtonItem *buttonItem1 = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Reload"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(reloadData)];

    UIBarButtonItem *buttonItem2 = [[UIBarButtonItem alloc]
                                    initWithTitle:@"moveTo0"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(moveToZero)];

    self.navigationItem.rightBarButtonItems = @[buttonItem1, buttonItem2];
}

- (void)moveToZero
{
    self.scrollView.page = 0;
}

- (void)reloadData
{
    [self.scrollView reloadData];
}

#pragma mark - DCScrollViewDataSource

- (NSInteger)numberOfCellsInDCScrollView:(DCScrollView *)scrollView
{
    return self.numerOfCells;
}

- (DCScrollViewCell *)dcscrollView:(DCScrollView *)scrollView cellAtIndex:(NSInteger)index
{
    NSString *identifier = @"Cell";
    DemoDCScrollViewCell *cell = [scrollView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell  = [[DemoDCScrollViewCell alloc] initWithReuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"title %ld", (long)index];
    [cell.textLabel sizeToFit];

    return cell;
}

- (NSString *)titleOfDCScrollViewCellAtIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"title %ld", (long)index];
}

- (void)dcscrollViewDidScroll:(DCScrollView *)scrollView didChangeVisibleCell:(DCScrollViewCell *)cell atIndex:(NSInteger)index
{
    DemoDCScrollViewCell *aCell = (DemoDCScrollViewCell *)cell;
    NSLog(@"index: %ld, cell title: %@", (long)index, aCell.textLabel.text);
}

@end
