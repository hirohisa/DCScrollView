//
//  DCScrollViewContentView.m
//
//  Created by Hirohisa Kawasaki on 2014/03/16.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import "DCScrollViewContentView.h"
#import "DCScrollView+Logic.h"

@interface DCScrollViewContentView () <UIScrollViewDelegate> {
    @package
    __unsafe_unretained id _delegate;
}

@end

@implementation DCScrollViewContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self dcscrollViewContentView_configure];
    }
    return self;
}

- (void)dcscrollViewContentView_configure
{
    self.showsHorizontalScrollIndicator = NO;
    self.scrollsToTop = NO;
    [super setDelegate:self];
}

- (void)dealloc
{
    self->_delegate = nil;
}

#pragma mark - public

- (void)reloadData
{
    if (self->_delegate &&
        self.dataSource) {
        [self _initialize];
    }
}

#pragma mark - accessor

- (void)setPage:(NSInteger)page
{
    if (_page != page) {
        _page = page;
        [self reloadData];
    }
}

- (void)setDelegate:(id<DCScrollViewContentViewDelegate>)delegate
{
    self->_delegate = delegate;
}

- (id<DCScrollViewContentViewDelegate>)delegate
{
    return self->_delegate;
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

    self.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * [self numberOfContentViewCells], CGRectGetHeight(self.frame));

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
    if ([self.dataSource numberOfCellsInDCScrollViewContentView:self] > 1) {
        id previousCell = [self cellAtIndex:self.page-1];
        self.previousCell = previousCell;
        self.previousCell.frame = (CGRect) {
            .origin = startPoint,
            .size = self.previousCell.frame.size
        };
        [self addSubview:self.previousCell];
        startPoint = CGPointMake(CGRectGetMaxX(self.previousCell.frame), 0);
    }

    if ([self.dataSource numberOfCellsInDCScrollViewContentView:self] >= 1) {
        id currentCell = [self cellAtIndex:self.page];
        self.currentCell = currentCell;
        self.currentCell.frame = (CGRect) {
            .origin = startPoint,
            .size = self.currentCell.frame.size
        };
        [self addSubview:self.currentCell];
        startPoint = CGPointMake(CGRectGetMaxX(self.currentCell.frame), 0);
    }

    if ([self.dataSource numberOfCellsInDCScrollViewContentView:self] > 1) {
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
        [self.delegate dcscrollViewContentView:self didChangeVisibleCellAtIndex:[self indexRelativedForIndex:self.page]];
    }
}

- (NSUInteger)numberOfContentViewCells
{
    switch ([self.dataSource numberOfCellsInDCScrollViewContentView:self]) {
        case 0:
            return 0;
            break;

        case 1:
            return 1;
            break;

        default:
            return 3;
            break;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self renderCells];
    [self.delegate dcscrollViewContentViewDidScroll:self];
}

@end
