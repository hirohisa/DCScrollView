//
//  DCScrollView.m
//
//  Created by Hirohisa Kawasaki on 13/03/29.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import "DCScrollView.h"
#import "DCScrollView+Logic.h"

#import "DCScrollViewNavigationView.h"
#import "DCScrollViewContentView.h"


@interface DCScrollViewContentView ()

- (void)renderCells;

@end

@interface DCScrollView ()
<UIScrollViewDelegate, DCScrollViewNavigationViewDelegate, DCScrollViewNavigationViewDataSource, DCScrollViewContentViewDataSource, DCScrollViewContentViewDelegate>
@property (nonatomic) BOOL touchedBody;
@property (nonatomic, readonly) DCScrollViewNavigationView *headScrollView;
@property (nonatomic, readonly) DCScrollViewContentView *bodyScrollView;

@property (nonatomic, strong) NSMutableDictionary *reusableCells;
@property (nonatomic, strong) NSMutableArray *visibleCells;

@property (nonatomic, readonly) UIView *headBackgroundView;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@end

@implementation DCScrollView
- (id)init
{
    return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _reusableCells = [@{} mutableCopy];
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - accessor

- (UIView *)titleView
{
    return self.headBackgroundView;
}

- (UIScrollView *)containerScrollView
{
    return (UIScrollView *)self.bodyScrollView;
}

- (NSArray *)visibleCells
{
    NSMutableArray *cells = [@[] mutableCopy];
    if (self.bodyScrollView.previousCell) {
        [cells addObject:self.bodyScrollView.previousCell];
    }
    if (self.bodyScrollView.currentCell) {
        [cells addObject:self.bodyScrollView.currentCell];
    }
    if (self.bodyScrollView.nextCell) {
        [cells addObject:self.bodyScrollView.nextCell];
    }
    return [cells copy];
}

- (DCScrollViewCell *)currentCell
{
    return self.bodyScrollView.currentCell;
}

#pragma mark - initialize

- (void)_initialize
{
    // head
    CGRect frame;
    if (!self.headScrollView) {
        frame = (CGRect) {
            .origin.x = 0,
            .origin.y = 0,
            .size.width  = CGRectGetWidth(self.bounds),
            .size.height = [self sizeOfCellInDCScrollViewNavigationView].height
        };
        CGRect frameAtScrollView = (CGRect) {
            .origin.x = 0,
            .origin.y = 0,
            .size     = [self sizeOfCellInDCScrollViewNavigationView]
        };
        _headScrollView = [[DCScrollViewNavigationView alloc] initWithFrame:frame frameAtScrollView:frameAtScrollView];
        self.headScrollView.focusedCenter = self.focusedCenter;
        self.headScrollView.delegate = self;
        self.headScrollView.dataSource = self;
        [self addSubview:self.headScrollView];
    }
    // body
    if (!self.bodyScrollView) {
        frame = (CGRect) {
            .origin.x = 0,
            .origin.y = CGRectGetMaxY(self.headScrollView.frame),
            .size.width = CGRectGetWidth(self.frame),
            .size.height = CGRectGetHeight(self.frame) - CGRectGetHeight(self.headScrollView.frame)
        };
        _bodyScrollView = [[DCScrollViewContentView alloc]initWithFrame:frame];
        self.bodyScrollView.delegate = self;
        self.bodyScrollView.dcDelegate = self;
        self.bodyScrollView.dataSource = self;
        self.bodyScrollView.pagingEnabled = YES;
        self.bodyScrollView.showsHorizontalScrollIndicator = NO;
        self.bodyScrollView.showsVerticalScrollIndicator   = NO;
        [self addSubview:self.bodyScrollView];
    }
    [self reloadData];
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if (identifier &&
        [self.reusableCells objectForKey:identifier] &&
        [[self.reusableCells objectForKey:identifier] count]) {

        id cell = [[self.reusableCells objectForKey:identifier] lastObject];
        [[self.reusableCells objectForKey:identifier] removeLastObject];
        return cell;
    }
    return nil;
}

- (void)recycleCellIntoReusableQueue:(DCScrollViewCell *)cell
{
    if (![self.reusableCells objectForKey:cell.reuseIdentifier]) {
        [self.reusableCells setObject:[@[] mutableCopy] forKey:cell.reuseIdentifier];
    }
    [[self.reusableCells objectForKey:cell.reuseIdentifier] addObject:cell];
}

- (void)setDataSource:(id<DCScrollViewDataSource>)dataSource
{
    _dataSource = dataSource;
    if ([self validateToInitialize]) {
        [self _initialize];
    }
}

- (void)setDelegate:(id<DCScrollViewDelegate>)delegate
{
    _delegate = delegate;
    if ([self validateToInitialize]) {
        [self _initialize];
    }
}

- (void)setFrame:(CGRect)frame
{
    BOOL changeFromZero = CGRectEqualToRect(self.frame, CGRectZero);
    [super setFrame:frame];
    if (changeFromZero && [self validateToInitialize]) {
        [self _initialize];
    }
}

- (BOOL)validateToInitialize
{
    return (self.dataSource && self.delegate && !CGRectEqualToRect(self.frame, CGRectZero));
}

- (void)reloadData
{
    [self clear];
    [self.headScrollView reloadData];
    [self.bodyScrollView reloadData];
}

- (void)clear
{
    self.touchedBody = NO;
    self.reusableCells = [@{} mutableCopy];
}

- (void)setFont:(UIFont *)font textColor:(UIColor *)textColor highlightedTextColor:(UIColor *)highlightedTextColor
{
    self.font = font;
    self.textColor = textColor;
    self.highlightedTextColor = highlightedTextColor;
    [self.headScrollView reloadData];
}

#pragma mark - touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.touchedBody = [touch.view isEqual:self.bodyScrollView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.bodyScrollView]) {
        int adjust = 0;
        if ([scrollView reservingPage] == 0) {
            adjust = -1;
        } else if ([scrollView reservingPage] == 2) {
            adjust = 1;
        }
        self.touchedBody = YES;
        [self.headScrollView scrollToPage:(self.bodyScrollView.page + adjust) animated:YES];
        [self.bodyScrollView renderCells];
    }
}

- (void)dcscrollViewNavigationViewDidEndScrollingAnimation:(DCScrollViewNavigationView *)navigationView
{
    if ([navigationView isEqual:self.headScrollView]) {
        if (!self.touchedBody) {
            self.bodyScrollView.page = self.headScrollView.page;
        }
    }
    self.touchedBody = ![navigationView isEqual:self.headScrollView];
}

- (void)dcscrollViewNavigationViewDidEndDecelerating:(DCScrollViewNavigationView *)navigationView
{
    self.bodyScrollView.page = self.headScrollView.page;
    self.touchedBody = ![navigationView isEqual:self.headScrollView];
}

#pragma mark - DCBodyScrollViewDataSource

- (DCScrollViewCell *)dcscrollViewContentView:(DCScrollViewContentView *)contentView cellAtIndex:(NSInteger)index
{
    DCScrollViewCell *cell = [self.dataSource dcscrollView:self cellAtIndex:index];
    return cell;
}

- (NSUInteger)numberOfCellsInDCScrollViewContentView:(DCScrollViewContentView *)contentView
{
    return [self.dataSource numberOfCellsInDCScrollView:self];
}

- (void)dcscrollViewContentView:(DCScrollViewContentView *)contentView enqueueReusableCell:(id)cell
{
    [self recycleCellIntoReusableQueue:cell];
}

- (void)dcscrollViewContentView:(DCScrollViewContentView *)contentView didChangeVisibleCellAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(dcscrollViewDidScroll:didChangeVisibleCell:atIndex:)]) {
        [self.delegate dcscrollViewDidScroll:self didChangeVisibleCell:self.currentCell atIndex:index];
    }
}

#pragma mark - DCScrollViewNavigationViewDelegate

- (CGSize)sizeOfCellInDCScrollViewNavigationView
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(sizeOfDCScrollViewNavigationViewCell)]) {
        return [self.delegate sizeOfDCScrollViewNavigationViewCell];
    }

    return (CGSize) {
        .width  = CGRectGetWidth(self.bounds)/3,
        .height = 44.
    };
}

#pragma mark - DCScrollViewNavigationViewDataSource

- (NSInteger)numberOfCellsInDCScrollViewNavigationView:(DCScrollViewNavigationView *)navigationView
{
    return [self.dataSource numberOfCellsInDCScrollView:self];
}

- (DCScrollViewNavigationViewCell *)dcscrollViewNavigationView:(DCScrollViewNavigationView *)navigationView cellAtIndex:(NSInteger)index
{
    DCScrollViewNavigationViewCell *cell;
    if ([self.dataSource respondsToSelector:@selector(dcscrollView:navigationViewCellAtIndex:)]) {
        cell = [self.dataSource dcscrollView:self navigationViewCellAtIndex:index];
    }

    if (!cell) {
        cell = [[DCScrollViewNavigationViewCell alloc] init];
        if (self.font) {
            cell.textLabel.font = self.font;
        }
        if (self.textColor) {
            cell.textLabel.textColor = self.textColor;
        }
        if (self.highlightedTextColor) {
            cell.textLabel.highlightedTextColor = self.highlightedTextColor;
        }
    }

    if ([self.dataSource respondsToSelector:@selector(titleOfDCScrollViewCellAtIndex:)]) {
        cell.textLabel.text = [self.dataSource titleOfDCScrollViewCellAtIndex:index];
    }
    return cell;
}

@end