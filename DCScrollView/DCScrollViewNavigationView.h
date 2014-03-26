//
//  DCScrollViewNavigationView.h
//
//  Created by Hirohisa Kawasaki on 2014/03/16.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCScrollViewNavigationView, DCScrollViewNavigationViewCell;

@interface DCScrollViewNavigationViewInnerScrollView : UIScrollView
@end

@protocol DCScrollViewNavigationViewDelegate <NSObject>

- (void)dcscrollViewNavigationViewDidEndDecelerating:(DCScrollViewNavigationView *)navigationView;
- (void)dcscrollViewNavigationViewDidEndScrollingAnimation:(DCScrollViewNavigationView *)navigationView;

@end

@protocol DCScrollViewNavigationViewDataSource <NSObject>

- (NSInteger)numberOfCellsInDCScrollViewNavigationView:(DCScrollViewNavigationView *)navigationView;
- (DCScrollViewNavigationViewCell *)dcscrollViewNavigationView:(DCScrollViewNavigationView *)navigationView cellAtIndex:(NSInteger)index;

@end

@interface DCScrollViewNavigationView : UIView <UIScrollViewDelegate>

@property (nonatomic, readonly) DCScrollViewNavigationViewInnerScrollView *scrollView;

@property (nonatomic, assign) id<DCScrollViewNavigationViewDelegate> delegate;
@property (nonatomic, assign) id<DCScrollViewNavigationViewDataSource> dataSource;

@property (nonatomic, strong) NSMutableArray *visibleCells;
@property (nonatomic, readonly) NSInteger page;
@property (nonatomic) BOOL focusedCenter;

- (void)reloadData;
- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated;

@end
