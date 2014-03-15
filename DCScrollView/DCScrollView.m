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

//
// DCScrollViewNavigationViewCell
//
//

@interface DCScrollViewNavigationViewCellLabel : UILabel

@end

@implementation DCScrollViewNavigationViewCellLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return self;
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self sizeToFit];
}

@end

@implementation DCScrollViewNavigationViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.index = NSNotFound;
        self.textLabel = [[DCScrollViewNavigationViewCellLabel alloc] initWithFrame:CGRectZero];
    }
    return self;
}

#pragma mark - accessor

- (void)setTextLabel:(UILabel *)textLabel
{
    _textLabel = textLabel;
    [self addSubview:textLabel];
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    if (self.textLabel) {
        self.textLabel.highlighted = highlighted;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.textLabel) {
        self.textLabel.center = (CGPoint) {
            .x = CGRectGetWidth(self.frame)/2,
            .y = CGRectGetHeight(self.frame)/2
        };
    }
}

@end


//
// DCScrollViewCell
//
//

@implementation DCScrollViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super init]) {
		_reuseIdentifier = reuseIdentifier;
	}
	return self;
}

@end


//
// DCScrollView
//
//

@interface DCScrollViewContentView ()

- (void)renderCells;

@end

@interface DCScrollView ()

<
UIScrollViewDelegate,
DCScrollViewNavigationViewDelegate, DCScrollViewNavigationViewDataSource,
DCScrollViewContentViewDelegate, DCScrollViewContentViewDataSource
>

@property (nonatomic) BOOL touchedContentView;

@property (nonatomic, readonly) DCScrollViewNavigationView *navigationView;
@property (nonatomic, readonly) DCScrollViewContentView *contentView;

@property (nonatomic, readonly) NSMutableDictionary *reusableCells;

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
    self = [super initWithFrame:frame];
    if (self) {
        _reusableCells = [@{} mutableCopy];
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - accessor

- (NSArray *)visibleCells
{
    NSMutableArray *cells = [@[] mutableCopy];
    if (self.contentView.previousCell) {
        [cells addObject:self.contentView.previousCell];
    }
    if (self.contentView.currentCell) {
        [cells addObject:self.contentView.currentCell];
    }
    if (self.contentView.nextCell) {
        [cells addObject:self.contentView.nextCell];
    }
    return [cells copy];
}

- (DCScrollViewCell *)currentCell
{
    return self.contentView.currentCell;
}

#pragma mark - initialize

- (void)_initialize
{
    // navigation
    CGRect frame;
    if (!self.navigationView) {
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
        _navigationView = [[DCScrollViewNavigationView alloc] initWithFrame:frame frameAtScrollView:frameAtScrollView];
        self.navigationView.focusedCenter = self.focusedCenter;
        self.navigationView.delegate = self;
        self.navigationView.dataSource = self;
        [self addSubview:self.navigationView];
    }

    // content
    if (!self.contentView) {
        frame = (CGRect) {
            .origin.x = 0,
            .origin.y = CGRectGetMaxY(self.navigationView.frame),
            .size.width = CGRectGetWidth(self.frame),
            .size.height = CGRectGetHeight(self.frame) - CGRectGetHeight(self.navigationView.frame)
        };
        _contentView = [[DCScrollViewContentView alloc]initWithFrame:frame];
        self.contentView.delegate = self;
        self.contentView.dcDelegate = self;
        self.contentView.dataSource = self;
        self.contentView.pagingEnabled = YES;
        self.contentView.showsHorizontalScrollIndicator = NO;
        self.contentView.showsVerticalScrollIndicator   = NO;
        [self addSubview:self.contentView];
    }
    [self reloadData];
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if (identifier &&
        self.reusableCells[identifier] &&
        [self.reusableCells[identifier] count]) {

        id cell = [self.reusableCells[identifier] lastObject];
        [self.reusableCells[identifier] removeLastObject];
        return cell;
    }
    return nil;
}

- (void)recycleCellIntoReusableQueue:(DCScrollViewCell *)cell
{
    if (!self.reusableCells[cell.reuseIdentifier]) {
        self.reusableCells[cell.reuseIdentifier] = [@[] mutableCopy];
    }
    [self.reusableCells[cell.reuseIdentifier] addObject:cell];
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
    [super setFrame:frame];
    if ([self validateToInitialize]) {
        [self _initialize];
    }
}

- (BOOL)validateToInitialize
{
    return (self.dataSource && self.delegate && !CGRectEqualToRect(self.frame, CGRectZero));
}

- (void)reloadData
{
    [self clearData];
    [self.navigationView reloadData];
    [self.contentView reloadData];
}

- (void)clearData
{
    self.touchedContentView = NO;
    _reusableCells = [@{} mutableCopy];
}

- (void)setFont:(UIFont *)font textColor:(UIColor *)textColor highlightedTextColor:(UIColor *)highlightedTextColor
{
    self.font = font;
    self.textColor = textColor;
    self.highlightedTextColor = highlightedTextColor;
    [self.navigationView reloadData];
}

#pragma mark - touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.touchedContentView = [touch.view isEqual:self.contentView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int adjust = 0;
    if ([scrollView reservingPage] == 0) {
        adjust = -1;
    } else if ([scrollView reservingPage] == 2) {
        adjust = 1;
    }
    self.touchedContentView = YES;
    [self.navigationView scrollToPage:(self.contentView.page + adjust) animated:YES];
    [self.contentView renderCells];
}

- (void)dcscrollViewNavigationViewDidEndScrollingAnimation:(DCScrollViewNavigationView *)navigationView
{
    if (!self.touchedContentView) {
        self.contentView.page = self.navigationView.page;
    }
    self.touchedContentView = NO;
}

- (void)dcscrollViewNavigationViewDidEndDecelerating:(DCScrollViewNavigationView *)navigationView
{
    self.contentView.page = self.navigationView.page;
    self.touchedContentView = NO;
}

#pragma mark - DCScrollViewContentViewDataSource

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

#pragma mark - DCScrollViewContentViewDelegate

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