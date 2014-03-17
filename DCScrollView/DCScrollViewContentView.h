//
//  DCScrollViewContentView.h
//
//  Created by Hirohisa Kawasaki on 2014/03/16.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCScrollViewContentView, DCScrollViewCell;

@protocol DCScrollViewContentViewDataSource <NSObject>

- (DCScrollViewCell *)dcscrollViewContentView:(DCScrollViewContentView *)contentView cellAtIndex:(NSInteger)index;
- (NSUInteger)numberOfCellsInDCScrollViewContentView:(DCScrollViewContentView *)contentView;
- (void)dcscrollViewContentView:(DCScrollViewContentView *)scrollView enqueueReusableCell:(id)cell;

@end

@protocol DCScrollViewContentViewDelegate <UIScrollViewDelegate>

- (void)dcscrollViewContentView:(DCScrollViewContentView *)contentView didChangeVisibleCellAtIndex:(NSInteger)index;
- (void)dcscrollViewContentViewDidScroll:(DCScrollViewContentView *)contentView;

@end

@interface DCScrollViewContentView : UIScrollView

@property (nonatomic) NSInteger page;

@property (nonatomic, assign) DCScrollViewCell *previousCell;
@property (nonatomic, assign) DCScrollViewCell *currentCell;
@property (nonatomic, assign) DCScrollViewCell *nextCell;

@property (nonatomic, assign) id<DCScrollViewContentViewDataSource> dataSource;
@property (nonatomic, assign) id<DCScrollViewContentViewDelegate> delegate;

- (void)reloadData;

@end
