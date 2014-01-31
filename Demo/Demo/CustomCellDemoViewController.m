//
//  CustomCellDemoViewController.m
//  Demo
//
//  Created by Hirohisa Kawasaki on 2014/01/31.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import "CustomCellDemoViewController.h"

@interface DemoTitleViewCell : DCTitleScrollViewCell
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation DemoTitleViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.detailLabel = [[UILabel alloc] init];
        [self addSubview:self.detailLabel];
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.textLabel.alpha = highlighted?1.:0.5;
    self.backgroundColor = highlighted?[UIColor whiteColor]:[UIColor grayColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.center = (CGPoint){
        .x = self.textLabel.center.x,
        .y = 15
    };
    self.detailLabel.frame = (CGRect) {
        .origin.x = CGRectGetMinX(self.textLabel.frame),
        .origin.y = CGRectGetMaxY(self.textLabel.frame) + 10,
        .size.width = CGRectGetWidth(self.textLabel.frame),
        .size.height = 15
    };
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
    cell.detailLabel.text = @"detail";
    return cell;
}

- (CGFloat)heightOfCellInDCTitleScrollView
{
    return 60.;
}

@end
