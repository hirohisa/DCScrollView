//
//  DCScrollView+Logic.h
//
//  Created by Hirohisa Kawasaki on 13/08/28.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import "DCScrollView.h"

@interface UIScrollView (DCScrollViewLogic)
- (NSInteger)currentPage;
- (NSInteger)willedPage;
- (NSInteger)convertToPageWithOffsetX:(CGFloat)offsetX;
- (NSInteger)centerPage;
@end

@interface NSNumber (DCScrollViewLogic)
+ (NSUInteger)relativedIntegerValueForIndex:(NSInteger)index length:(NSUInteger)length;
@end

@interface DCScrollView (Logic)
@end