//
//  DCScrollViewTest.m
//  DCScrollViewTest
//
//  Created by Hirohisa Kawasaki on 13/08/28.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "DCScrollView+Logic.h"

@interface DCScrollViewTest : SenTestCase

@end

@implementation DCScrollViewTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testRelativedIntegerValue
{
    NSInteger result;
    result = [NSNumber relativedIntegerValueForIndex:0 length:2];
    STAssertTrue(0 == result,
                 @"relativedIntegerValueForIndex:%d", result);

    result = [NSNumber relativedIntegerValueForIndex:-1 length:2];
    STAssertTrue(1 == result,
                 @"relativedIntegerValueForIndex:%d", result);

    result = [NSNumber relativedIntegerValueForIndex:-1 length:3];
    STAssertTrue(2 == result,
                 @"relativedIntegerValueForIndex:%d", result);

    result = [NSNumber relativedIntegerValueForIndex:0 length:1];
    STAssertTrue(0 == result,
                 @"relativedIntegerValueForIndex:%d", result);

    result = [NSNumber relativedIntegerValueForIndex:-5 length:3];
    STAssertTrue(1 == result,
                 @"relativedIntegerValueForIndex:%d", result);
}

- (void)testCenterPageAndWilledPage
{
    CGRect frame = (CGRect) {
        .origin.x = 0,
        .origin.y = 0,
        .size.width = 100,
        .size.height = 100
    };
    CGSize contentSize = (CGSize) {
        .width = 1100,
        .height = 100
    };

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.contentSize = contentSize;
    STAssertTrue(5 == [scrollView centerPage],
                 @"centerPage:%d", [scrollView centerPage]);

    scrollView.contentOffset = CGPointMake(0, 0);
    STAssertTrue(0 == [scrollView currentPage],
                 @"currentPage:%d", [scrollView currentPage]);

    scrollView.contentOffset = CGPointMake(100, 0);
    STAssertTrue(1 == [scrollView currentPage],
                 @"currentPage:%d", [scrollView currentPage]);

    scrollView.contentOffset = CGPointMake(0, 0);
    STAssertTrue(0 == [scrollView willedPage],
                 @"willedPage:%d", [scrollView willedPage]);

    scrollView.contentOffset = CGPointMake(40, 0);
    STAssertTrue(0 == [scrollView willedPage],
                 @"willedPage:%d", [scrollView willedPage]);

    scrollView.contentOffset = CGPointMake(60, 0);
    STAssertTrue(1 == [scrollView willedPage],
                 @"willedPage:%d", [scrollView willedPage]);

    scrollView.contentOffset = CGPointMake(110, 0);
    STAssertTrue(1 == [scrollView willedPage],
                 @"willedPage:%d", [scrollView willedPage]);
}

@end
