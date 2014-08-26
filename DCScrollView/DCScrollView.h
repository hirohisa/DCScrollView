//
//  DCScrollView.h
//
//  Created by Hirohisa Kawasaki on 13/03/29.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCScrollView;

@interface DCScrollViewNavigationViewCell : UIView

@property (nonatomic) NSInteger index;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@end

@interface DCScrollViewCell : UIView

@property (nonatomic, readonly) NSString *reuseIdentifier;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol DCScrollViewDataSource <NSObject>

@required

- (NSInteger)numberOfCellsInDCScrollView:(DCScrollView *)scrollView;
- (DCScrollViewCell *)dcscrollView:(DCScrollView *)scrollView cellAtIndex:(NSInteger)index;

@optional

- (NSString *)titleOfDCScrollViewCellAtIndex:(NSInteger)index;
- (DCScrollViewNavigationViewCell *)dcscrollView:(DCScrollView *)scrollView navigationViewCellAtIndex:(NSInteger)index;

@end

@protocol DCScrollViewDelegate <NSObject>

@optional

- (CGSize)sizeOfDCScrollViewNavigationViewCell;
- (void)dcscrollViewDidScroll:(DCScrollView *)scrollView didChangeVisibleCell:(DCScrollViewCell *)cell atIndex:(NSInteger)index;

@end

@interface DCScrollView : UIView

@property (nonatomic) BOOL focusedCenter;
@property (nonatomic) NSUInteger page;

@property (nonatomic, assign) id <DCScrollViewDataSource> dataSource;
@property (nonatomic, assign) id <DCScrollViewDelegate> delegate;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)reloadData;
- (void)clearData; // clear Cache

- (void)setFont:(UIFont *)font textColor:(UIColor *)textColor highlightedTextColor:(UIColor *)highlightedTextColor;

@end

@interface DCScrollView (SubViews)

@property (nonatomic, readonly) NSArray *visibleCells;
@property (nonatomic, readonly) DCScrollViewCell *currentCell;

@property (nonatomic, readonly) UIView *navigationView;
@property (nonatomic, readonly) UIScrollView *contentView;

@end