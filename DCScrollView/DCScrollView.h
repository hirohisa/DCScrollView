//
//  DCScrollView.h
//  DCScrollView
//
//  Created by Hirohisa Kawasaki on 13/03/29.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCTitleScrollViewCell : UIView
@property (nonatomic, strong) UILabel *textLabel;
@property(nonatomic,getter=isHighlighted) BOOL highlighted;
@end

@interface DCScrollViewCell : UIView
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
@end

@class DCScrollView;
@protocol DCScrollViewDataSource <NSObject>
@required
- (NSInteger)numberOfCellsInDCScrollView:(DCScrollView *)scrollView;
- (DCScrollViewCell *)dcScrollView:(DCScrollView *)scrollView cellAtIndex:(NSInteger)index;

@optional
- (NSString *)dcTitleScrollViewCellTitleAtIndex:(NSInteger)index;
- (DCTitleScrollViewCell *)dcTitleScrollViewCellAtIndex:(NSInteger)index;
@end

@protocol DCScrollViewDelegate <NSObject>
@optional
- (CGFloat)heightOfCellInDCTitleScrollView;
- (CGFloat)widthOfCellInDCTitleScrollView;

- (void)dcScrollViewDidScroll:(DCScrollView *)scrollView didChangeVisibleCell:(DCScrollViewCell *)cell atIndex:(NSInteger)index;
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