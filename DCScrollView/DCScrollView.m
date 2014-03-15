//
//  DCScrollView.m
//
//  Created by Hirohisa Kawasaki on 13/03/29.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import "DCScrollView.h"
#import "DCScrollView+Logic.h"

#import "DCScrollViewNavigationView.h"

@class DCScrollViewContentView;

@protocol DCScrollViewContentViewDataSource <NSObject>

- (DCScrollViewCell *)dcscrollViewContentView:(DCScrollViewContentView *)contentView cellAtIndex:(NSInteger)index;
- (NSUInteger)numberOfCellsInDCScrollViewContentView:(DCScrollViewContentView *)contentView;
- (void)dcscrollViewContentView:(DCScrollViewContentView *)scrollView enqueueReusableCell:(id)cell;

@end

@protocol DCScrollViewContentViewDelegate <NSObject>

- (void)dcscrollViewContentView:(DCScrollViewContentView *)contentView didChangeVisibleCellAtIndex:(NSInteger)index;

@end

@interface DCScrollViewContentView : UIScrollView

@property (nonatomic, readonly) NSArray *visibleCells;

@property (nonatomic) NSInteger page;
@property (nonatomic, assign) DCScrollViewCell *previousCell;
@property (nonatomic, assign) DCScrollViewCell *currentCell;
@property (nonatomic, assign) DCScrollViewCell *nextCell;

@property (nonatomic, assign) id<DCScrollViewContentViewDataSource> dataSource;
@property (nonatomic, assign) id<DCScrollViewContentViewDelegate> dcDelegate;

@end

@implementation DCScrollViewContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.scrollsToTop = NO;
    }
    return self;
}

#pragma mark - public

- (void)reloadData
{
    [self _initialize];
}

#pragma mark - accessor

- (void)setPage:(NSInteger)page
{
    if (_page != page) {
        _page = page;
        [self reloadData];
    }
}

- (NSArray *)visibleCells
{
    NSMutableArray *cells = [@[] mutableCopy];
    if (self.previousCell) {
        [cells addObject:self.previousCell];
    }
    if (self.currentCell) {
        [cells addObject:self.currentCell];
    }
    if (self.nextCell) {
        [cells addObject:self.nextCell];
    }
    return [cells copy];
}

#pragma mark - enqueue

- (void)enqueueReusableCell:(id)cell
{
    if (self.dataSource) {
        [self.dataSource dcscrollViewContentView:self enqueueReusableCell:cell];
    }
    [cell removeFromSuperview];
}

#pragma mark - initialize

- (void)_initialize
{
    // set content size
    NSInteger length = ([self.dataSource numberOfCellsInDCScrollViewContentView:self] != 1)?3:1;
    self.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * length, CGRectGetHeight(self.frame));

    // enqueue cells
    CGPoint startPoint = CGPointZero;
    if (self.previousCell) {
        startPoint = self.previousCell.frame.origin;
        [self enqueueReusableCell:self.previousCell];
        self.previousCell = nil;
    }
    if (self.currentCell) {
        [self enqueueReusableCell:self.currentCell];
        self.currentCell = nil;
    }
    if (self.nextCell) {
        [self enqueueReusableCell:self.nextCell];
        self.nextCell = nil;
    }

    // add subviews
    if ([self.dataSource numberOfCellsInDCScrollViewContentView:self] != 1) {
        id previousCell = [self cellAtIndex:self.page-1];
        self.previousCell = previousCell;
        self.previousCell.frame = (CGRect) {
            .origin = startPoint,
            .size = self.previousCell.frame.size
        };
        [self addSubview:self.previousCell];
        startPoint = CGPointMake(CGRectGetMaxX(self.previousCell.frame), 0);
    }

    id currentCell = [self cellAtIndex:self.page];
    self.currentCell = currentCell;
    self.currentCell.frame = (CGRect) {
        .origin = startPoint,
        .size = self.currentCell.frame.size
    };
    [self addSubview:self.currentCell];

    startPoint = CGPointMake(CGRectGetMaxX(self.currentCell.frame), 0);
    if ([self.dataSource numberOfCellsInDCScrollViewContentView:self] != 1) {
        id nextCell = [self cellAtIndex:self.page+1];
        self.nextCell = nextCell;
        self.nextCell.frame = (CGRect) {
            .origin = startPoint,
            .size = self.nextCell.frame.size
        };
        [self addSubview:self.nextCell];
    }

    [self delegateDidChangeVisibleCell];
    self.contentOffset = CGPointMake(CGRectGetMinX(self.currentCell.frame), 0);
}

#pragma mark - rendering

- (void)renderCells
{
    CGFloat centerOffsetX = (self.contentSize.width - CGRectGetWidth(self.bounds)) / 2.0;
    CGFloat distanceFromCenter = fabs(self.contentOffset.x - centerOffsetX);
    if (distanceFromCenter >= CGRectGetWidth(self.bounds)) {
        [self adjustContents];
        [self recenterIfNeeded];
    }
}

- (void)recenterIfNeeded
{
    CGFloat centerOffsetX = (self.contentSize.width - CGRectGetWidth(self.bounds)) / 2.0;
    self.contentOffset = CGPointMake(centerOffsetX, self.contentOffset.y);
    self.previousCell.center = (CGPoint) {
        .x = CGRectGetWidth(self.previousCell.frame)/2,
        .y = self.previousCell.center.y
    };
    self.currentCell.center = (CGPoint) {
        .x = CGRectGetMaxX(self.previousCell.frame) + CGRectGetWidth(self.currentCell.frame)/2,
        .y = self.currentCell.center.y
    };
    self.nextCell.center = (CGPoint) {
        .x = CGRectGetMaxX(self.currentCell.frame) + CGRectGetWidth(self.nextCell.frame)/2,
        .y = self.nextCell.center.y
    };
}

- (void)adjustContents
{
    NSInteger page = [self reservingPage];

    // remove
    switch (page) {
        case 0: {
            [self enqueueReusableCell:self.nextCell];
            self.nextCell = nil;
            _page = self.page -1;
        }
            break;

        case 1:
            break;

        case 2: {
            [self enqueueReusableCell:self.previousCell];
            self.previousCell = nil;
            _page = self.page +1;
        }
            break;
    }

    // switch and generate view when view is empty
    if (!self.nextCell) {
        self.nextCell = self.currentCell;
        self.currentCell = self.previousCell;
        DCScrollViewCell *cell = [self cellAtIndex:self.page-1];
        cell.frame = (CGRect) {
            .origin.x = CGRectGetMinX(self.currentCell.frame) - CGRectGetWidth(cell.frame),
            .origin.y = CGRectGetMinY(self.currentCell.frame),
            .size = cell.frame.size
        };
        self.previousCell = cell;
        [self addSubview:cell];

        [self delegateDidChangeVisibleCell];
    } else if (!self.previousCell) {
        self.previousCell = self.currentCell;
        self.currentCell = self.nextCell;
        DCScrollViewCell *cell = [self cellAtIndex:self.page+1];
        cell.frame = (CGRect) {
            .origin.x = CGRectGetMinX(self.currentCell.frame) + CGRectGetWidth(cell.frame),
            .origin.y = CGRectGetMinY(self.currentCell.frame),
            .size = cell.frame.size
        };
        self.nextCell = cell;
        [self addSubview:cell];

        [self delegateDidChangeVisibleCell];
    }
}

#pragma mark -

- (NSInteger)indexRelativedForIndex:(NSInteger)index
{
    NSUInteger length = [self.dataSource numberOfCellsInDCScrollViewContentView:self];
    return [@(index) relativedIntegerValueWithLength:length];
}

- (DCScrollViewCell *)cellAtIndex:(NSInteger)index
{
    DCScrollViewCell *cell = [self.dataSource dcscrollViewContentView:self cellAtIndex:[self indexRelativedForIndex:index]];
    cell.frame = (CGRect) {
        .origin.x = 0,
        .origin.y = 0,
        .size.width = CGRectGetWidth(self.frame),
        .size.height = CGRectGetHeight(self.frame)
    };
    return cell;
}

- (void)delegateDidChangeVisibleCell
{
    if (self.currentCell) {
        [self.dcDelegate dcscrollViewContentView:self didChangeVisibleCellAtIndex:[self indexRelativedForIndex:self.page]];
    }
}

@end

#pragma mark - DCScrollView

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
    return self.bodyScrollView.visibleCells;
}

- (DCScrollViewCell *)currentCell
{
    return (DCScrollViewCell *)self.bodyScrollView.currentCell;
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