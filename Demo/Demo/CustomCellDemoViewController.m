//
//  CustomCellDemoViewController.m
//  Demo
//
//  Created by Hirohisa Kawasaki on 2014/01/31.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import "CustomCellDemoViewController.h"

@interface DemoTitleViewCell : DCTitleScrollViewCell
@end

@implementation DemoTitleViewCell

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.textLabel.alpha = highlighted?1.:0.5;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"layout Subviews");
}
@end

@interface CustomCellDemoViewController ()

@end

@implementation CustomCellDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.numerOfCells = 10;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - DCScrollViewDataSource

- (DCTitleScrollViewCell *)dcTitleScrollViewCellAtIndex:(NSInteger)index
{
    DemoTitleViewCell *cell = [[DemoTitleViewCell alloc] init];
    cell.textLabel.text = [@(index) stringValue];
    cell.textLabel.textColor = [UIColor blueColor];
    return cell;
}


@end
