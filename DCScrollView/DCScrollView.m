//
//  DCScrollView.m
//
//  Created by Hirohisa Kawasaki on 13/03/29.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import "DCScrollView.h"
#import "DCScrollView+Logic.h"

#pragma mark - DCTitleScrollView

@class DCTitleScrollView;

@protocol DCTitleScrollViewDelegate <NSObject>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;

@end

@protocol DCTitleScrollViewDataSource <NSObject>

- (NSInteger)numberOfCellsInDCTitleScrollView:(DCTitleScrollView *)scrollView;
- (DCTitleScrollViewCell *)dcTitleScrollView:(DCTitleScrollView *)scrollView cellAtIndex:(NSInteger)index;

@end

@interface DCTitleScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, assign) id<DCTitleScrollViewDelegate> dcDelegate;
@property (nonatomic, assign) id<DCTitleScrollViewDataSource> dataSource;
@property (nonatomic, strong) NSMutableArray *visibleCells;
@property (nonatomic, readonly) NSInteger page;
@property (nonatomic) BOOL focusedCenter;

@property (nonatomic) BOOL touched;
- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated;

@end

@implementation DCTitleScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.clipsToBounds = NO;
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.scrollsToTop = NO;
        self.focusedCenter = NO;
    }
    return self;
}

#pragma mark - generate

- (DCTitleScrollViewCell *)cellAtIndex:(NSInteger)index
{
    for (DCTitleScrollViewCell *cell in self.visibleCells) {
        if (cell.index == index) {
            return cell;
        }
    }

    NSUInteger length = [self.dataSource numberOfCellsInDCTitleScrollView:self];
    NSInteger relativedIndex = [NSNumber relativedIntegerValueForIndex:index length:length];
    DCTitleScrollViewCell *cell = [self.dataSource dcTitleScrollView:self cellAtIndex:relativedIndex];
    cell.index = index;

    return cell;
}

#pragma mark - reloadData

- (void)reloadData
{
    for (DCTitleScrollViewCell *cell in self.visibleCells) {
        [cell removeFromSuperview];
    }
    self.visibleCells = [@[] mutableCopy];

    NSUInteger length = ([self.dataSource numberOfCellsInDCTitleScrollView:self] > 1)?11:1;
    self.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * length, CGRectGetHeight(self.frame));
    [self renderCells];
    CGFloat x = CGRectGetWidth(self.bounds) * ([self centerPage]);
    [self setContentOffset:CGPointMake(x, 0) animated:NO];
}

- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated
{
    NSInteger diff = page - self.page;
    if (abs(diff)) {
        if (self.focusedCenter) {
            [self changeCellsWithHighlited:NO];
        }
        if ([self.dataSource numberOfCellsInDCTitleScrollView:self] > 1) {
            CGFloat x = CGRectGetWidth(self.bounds) * diff;
            [self setContentOffset:CGPointMake(self.contentOffset.x + x, 0) animated:YES];
        }
        _page = page;
    }
}

#pragma mark - rendering

- (void)renderCells
{
    NSMutableArray *cells = [@[] mutableCopy];
    // remove not visibled cells
    for (DCTitleScrollViewCell *cell in self.visibleCells) {
        if (cell.index < self.page-[self centerPage] || cell.index > self.page+[self centerPage]) {
            [cell removeFromSuperview];
        } else {
            [cells addObject:cell];
        }
    }

    // add cells to visibled
    self.visibleCells = [cells mutableCopy];
    int i = 0;
    for (int index=self.page-[self centerPage]; index<=self.page+[self centerPage]; index++) {
        DCTitleScrollViewCell *cell = [self cellAtIndex:index];
        cell.frame = [self frameForTitleAtIndex:i];
        if (![self.visibleCells containsObject:cell]) {
            [self.visibleCells addObject:cell];
        }
        if (![cell isDescendantOfView:self]) {
            [self addSubview:cell];
        }
        i++;
    }
    [self switchHighlited];
}

- (CGRect)frameForTitleAtIndex:(NSInteger)index
{
    CGSize size = self.bounds.size;
    return (CGRect) {
        .origin.x = (size.width) * (index),
        .origin.y = 0,
        .size     = size
    };
}

- (void)changeCellsWithHighlited:(BOOL)highlited
{
    for (DCTitleScrollViewCell *cell in self.visibleCells) {
        cell.highlighted = highlited;
    }
}

- (void)switchHighlited
{
    for (DCTitleScrollViewCell *cell in self.visibleCells) {
        cell.highlighted = (cell.index == self.page);
    }
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touched = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touched = NO;
    CGPoint point = [[touches anyObject] locationInView:self];
    if ([self.dataSource numberOfCellsInDCTitleScrollView:self] > 1) {
        NSInteger touchedPage = [self convertToPageWithOffsetX:point.x];
        if (touchedPage > [self centerPage]) {
            [self scrollToPage:self.page+1 animated:YES];
        } else if (touchedPage < [self centerPage]) {
            [self scrollToPage:self.page-1 animated:YES];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touched = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touched = NO;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y) {
        scrollView.contentOffset = (CGPoint) {
            .x = scrollView.contentOffset.x,
            .y = 0
        };
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.focusedCenter) {
        [self changeCellsWithHighlited:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int adjust = [scrollView willedPage] - [scrollView centerPage];
    _page = self.page + adjust;
    [self renderCells];
    [self scrollToCenterWithAnimated:NO];
    if ([self.dcDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.dcDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self renderCells];
    [self scrollToCenterWithAnimated:NO];
    if ([self.dcDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.dcDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (void)scrollToCenterWithAnimated:(BOOL)animated
{
    CGFloat x = CGRectGetWidth(self.bounds) * ([self centerPage]);
    [self setContentOffset:CGPointMake(x, 0) animated:animated];
}

@end

#pragma mark - DCBodyScrollView

@class DCBodyScrollView;

@protocol DCBodyScrollViewDataSource <NSObject>

- (DCScrollViewCell *)dcBodyScrollView:(DCBodyScrollView *)scrollView cellAtIndex:(NSInteger)index;
- (NSInteger)numberOfCellsInDCBodyScrollView:(DCBodyScrollView *)scrollView;
- (void)dcBodyScrollView:(DCBodyScrollView *)scrollView enqueueReusableCell:(id)cell;

@end

@protocol DCBodyScrollViewDelegate <NSObject>

- (void)dcBodyScrollView:(DCBodyScrollView *)scrollView didChangeVisibleCellAtIndex:(NSInteger)index;

@end

@interface DCBodyScrollView : UIScrollView

@property (nonatomic, readonly) NSArray *visibleCells;

@property (nonatomic) NSInteger page;
@property (nonatomic, assign) DCScrollViewCell *previousCell;
@property (nonatomic, assign) DCScrollViewCell *currentCell;
@property (nonatomic, assign) DCScrollViewCell *nextCell;

@property (nonatomic, assign) id<DCBodyScrollViewDataSource> dataSource;
@property (nonatomic, assign) id<DCBodyScrollViewDelegate> dcDelegate;

@end

@implementation DCBodyScrollView

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
        [self.dataSource dcBodyScrollView:self enqueueReusableCell:cell];
    }
    [cell removeFromSuperview];
}

#pragma mark - initialize

- (void)_initialize
{
    // set content size
    NSInteger length = ([self.dataSource numberOfCellsInDCBodyScrollView:self] != 1)?3:1;
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
    if ([self.dataSource numberOfCellsInDCBodyScrollView:self] != 1) {
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
    if ([self.dataSource numberOfCellsInDCBodyScrollView:self] != 1) {
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
    NSInteger page = [self willedPage];

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
    NSUInteger length = [self.dataSource numberOfCellsInDCBodyScrollView:self];
    return [NSNumber relativedIntegerValueForIndex:index length:length];
}

- (DCScrollViewCell *)cellAtIndex:(NSInteger)index
{
    DCScrollViewCell *cell = [self.dataSource dcBodyScrollView:self cellAtIndex:[self indexRelativedForIndex:index]];
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
        [self.dcDelegate dcBodyScrollView:self didChangeVisibleCellAtIndex:[self indexRelativedForIndex:self.page]];
    }
}

@end

#pragma mark - DCScrollView

@interface DCScrollView ()
<UIScrollViewDelegate, DCTitleScrollViewDelegate, DCTitleScrollViewDataSource, DCBodyScrollViewDataSource, DCBodyScrollViewDelegate>
@property (nonatomic) BOOL touchedBody;
@property (nonatomic, readonly) DCTitleScrollView *headScrollView;
@property (nonatomic, readonly) DCBodyScrollView *bodyScrollView;

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
    if (!self.headBackgroundView) {
        frame = (CGRect) {
            .origin.x = 0,
            .origin.y = 0,
            .size.width = CGRectGetWidth(self.bounds),
            .size.height = [self heightOfCellInDCTitleScrollView]
        };
        _headBackgroundView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:self.headBackgroundView];
    }
    if (!self.headScrollView) {
        frame = (CGRect) {
            .origin.x = 0,
            .origin.y = 0,
            .size.width = [self widthOfCellInDCTitleScrollView],
            .size.height = [self heightOfCellInDCTitleScrollView]
        };
        _headScrollView = [[DCTitleScrollView alloc]initWithFrame:frame];
        self.headScrollView.center = (CGPoint) {
            .x = CGRectGetWidth(self.frame)/2,
            .y = CGRectGetHeight(self.headScrollView.frame)/2
        };
        self.headScrollView.focusedCenter = self.focusedCenter;
        self.headScrollView.dcDelegate = self;
        self.headScrollView.dataSource = self;
        self.headScrollView.pagingEnabled = YES;
        self.headScrollView.showsHorizontalScrollIndicator = NO;
        self.headScrollView.showsVerticalScrollIndicator   = NO;
        [self.headBackgroundView addSubview:self.headScrollView];
    }
    // body
    if (!self.bodyScrollView) {
        frame = (CGRect) {
            .origin.x = 0,
            .origin.y = CGRectGetMaxY(self.headScrollView.frame),
            .size.width = CGRectGetWidth(self.frame),
            .size.height = CGRectGetHeight(self.frame) - CGRectGetHeight(self.headScrollView.frame)
        };
        _bodyScrollView = [[DCBodyScrollView alloc]initWithFrame:frame];
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

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self.headBackgroundView pointInside:point withEvent:event]) {
        return self.headScrollView;
    }
    return [super hitTest:point withEvent:event];
}

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
        if ([scrollView willedPage] == 0) {
            adjust = -1;
        } else if ([scrollView willedPage] == 2) {
            adjust = 1;
        }
        self.touchedBody = YES;
        [self.headScrollView scrollToPage:(self.bodyScrollView.page + adjust) animated:YES];
        [self.bodyScrollView renderCells];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.headScrollView]) {
        if (!self.touchedBody) {
            self.bodyScrollView.page = self.headScrollView.page;
        }
    }
    self.touchedBody = ![scrollView isEqual:self.headScrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.bodyScrollView.page = self.headScrollView.page;
    self.touchedBody = ![scrollView isEqual:self.headScrollView];
}

#pragma mark - DCBodyScrollViewDataSource

- (DCScrollViewCell *)dcBodyScrollView:(DCBodyScrollView *)scrollView cellAtIndex:(NSInteger)index
{
    DCScrollViewCell *cell = [self.dataSource dcScrollView:self cellAtIndex:index];
    return cell;
}

- (NSInteger)numberOfCellsInDCBodyScrollView:(DCBodyScrollView *)scrollView
{
    return [self.dataSource numberOfCellsInDCScrollView:self];
}

- (void)dcBodyScrollView:(DCBodyScrollView *)scrollView enqueueReusableCell:(id)cell
{
    [self recycleCellIntoReusableQueue:cell];
}

- (void)dcBodyScrollView:(DCBodyScrollView *)scrollView didChangeVisibleCellAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(dcScrollViewDidScroll:didChangeVisibleCell:atIndex:)]) {
        [self.delegate dcScrollViewDidScroll:self didChangeVisibleCell:self.currentCell atIndex:index];
    }
}

#pragma mark - DCTitleScrollViewDelegate

-(CGFloat)widthOfCellInDCTitleScrollView
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(widthOfCellInDCTitleScrollView)]) {
        return [self.delegate widthOfCellInDCTitleScrollView];
    }
    return CGRectGetWidth(self.bounds)/3;
}

- (CGFloat)heightOfCellInDCTitleScrollView
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(heightOfCellInDCTitleScrollView)]) {
        return [self.delegate heightOfCellInDCTitleScrollView];
    }
    return 44.;
}

#pragma mark - DCTitleScrollViewDataSource

- (NSInteger)numberOfCellsInDCTitleScrollView:(DCTitleScrollView *)scrollView
{
    return [self.dataSource numberOfCellsInDCScrollView:self];
}

- (DCTitleScrollViewCell *)dcTitleScrollView:(DCTitleScrollView *)scrollView cellAtIndex:(NSInteger)index
{
    DCTitleScrollViewCell *cell;
    if ([self.dataSource respondsToSelector:@selector(dcTitleScrollViewCellAtIndex:)]) {
        cell = [self.dataSource dcTitleScrollViewCellAtIndex:index];
    }

    if (!cell) {
        cell = [[DCTitleScrollViewCell alloc] init];
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

    if ([self.dataSource respondsToSelector:@selector(dcTitleScrollViewCellTitleAtIndex:)]) {
        cell.textLabel.text = [self.dataSource dcTitleScrollViewCellTitleAtIndex:index];
    }
    return cell;
}

@end