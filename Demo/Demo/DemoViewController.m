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
        self.textLabel.textAlignment = UITextAlignmentCenter;
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

@interface DemoViewController ()
@property (nonatomic, strong) DCScrollView *scrollView;
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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Reload"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(reloadData)];
}

- (void)reloadData
{
    [self.scrollView reloadData];
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
    NSString *identifier = @"Cell";
    DemoDCScrollViewCell *cell = [scrollView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell  = [[DemoDCScrollViewCell alloc] initWithReuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"title %d", index];
    [cell.textLabel sizeToFit];

    return cell;
}

- (NSString *)dcTitleScrollViewCellTitleAtIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"title %d", index];
}

- (void)dcScrollViewDidScroll:(DCScrollView *)scrollView didChangeVisibleCell:(DCScrollViewCell *)cell atIndex:(NSInteger)index
{
    DemoDCScrollViewCell *aCell = (DemoDCScrollViewCell *)cell;
    NSLog(@"index: %d, cell title: %@", index, aCell.textLabel.text);
}

@end
