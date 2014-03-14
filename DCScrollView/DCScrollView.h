//
//  DCScrollView.h
//
//  Created by Hirohisa Kawasaki on 13/03/29.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCScrollViewCell.h"
#import "DCScrollViewNavigationViewCell.h"

@class DCScrollView;

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
@property (nonatomic, assign) id <DCScrollViewDataSource> dataSource;
@property (nonatomic, assign) id <DCScrollViewDelegate> delegate;
@property (nonatomic, readonly) UIView *titleView;
@property (nonatomic, readonly) UIScrollView *containerScrollView;
@property (nonatomic, readonly) NSArray *visibleCells;
@property (nonatomic, readonly) DCScrollViewCell *currentCell;
@property (nonatomic) BOOL focusedCenter;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)reloadData;
- (void)clear; // clear Caches

- (void)setFont:(UIFont *)font textColor:(UIColor *)textColor highlightedTextColor:(UIColor *)highlightedTextColor;
@end