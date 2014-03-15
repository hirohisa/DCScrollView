//
//  DCScrollView+Logic.m
//
//  Created by Hirohisa Kawasaki on 13/08/28.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import "DCScrollView+Logic.h"

@implementation UIScrollView (DCScrollViewLogic)

- (NSInteger)currentPage
{
    return [self convertToPageWithOffsetX:self.contentOffset.x];
}

- (NSInteger)reservingPage
{
    return [self convertToPageWithOffsetX:(self.contentOffset.x - CGRectGetWidth(self.bounds) / 2)]+1;
}

- (NSInteger)convertToPageWithOffsetX:(CGFloat)offsetX
{
    return floor(offsetX/CGRectGetWidth(self.bounds));
}

- (NSInteger)centerPage
{
    int maxContent = (int)self.contentSize.width/self.bounds.size.width;
    return (NSInteger)maxContent/2;
}

@end

@implementation NSNumber (DCScrollViewLogic)

- (NSUInteger)relativedIntegerValueWithLength:(NSUInteger)length
{
    NSInteger index = [self integerValue];
    NSInteger denominator = length?length:1;
    index = index%denominator;

    if (index < 0) {
        index = length-abs((int)index);
    }
    return index;
}

@end