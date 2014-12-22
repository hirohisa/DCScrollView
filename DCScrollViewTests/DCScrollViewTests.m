//
//  DCScrollViewTests.m
//  DCScrollViewTests
//
//  Created by Hirohisa Kawasaki on 2014/03/02.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "DCScrollView+Logic.h"

@interface DCScrollViewTests : XCTestCase

@end

@implementation DCScrollViewTests

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
    result = [@(0) relativedIntegerValueWithLength:2];
    XCTAssertTrue(0 == result,
                  @"relativedIntegerValueForIndex:%d", result);

    result = [@(-1) relativedIntegerValueWithLength:2];
    XCTAssertTrue(1 == result,
                  @"relativedIntegerValueForIndex:%d", result);

    result = [@(-1) relativedIntegerValueWithLength:3];
    XCTAssertTrue(2 == result,
                  @"relativedIntegerValueForIndex:%d", result);

    result = [@(0) relativedIntegerValueWithLength:1];
    XCTAssertTrue(0 == result,
                  @"relativedIntegerValueForIndex:%d", result);

    result = [@(-5) relativedIntegerValueWithLength:3];
    XCTAssertTrue(1 == result,
                  @"relativedIntegerValueForIndex:%d", result);
}

- (void)testCenterPageAndReservingPage
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
    XCTAssertTrue(5 == [scrollView centerPage],
                  @"centerPage:%d", [scrollView centerPage]);

    scrollView.contentOffset = CGPointMake(0, 0);
    XCTAssertTrue(0 == [scrollView reservingPage],
                  @"willedPage:%d", [scrollView reservingPage]);

    scrollView.contentOffset = CGPointMake(40, 0);
    XCTAssertTrue(0 == [scrollView reservingPage],
                  @"willedPage:%d", [scrollView reservingPage]);

    scrollView.contentOffset = CGPointMake(60, 0);
    XCTAssertTrue(1 == [scrollView reservingPage],
                  @"willedPage:%d", [scrollView reservingPage]);

    scrollView.contentOffset = CGPointMake(110, 0);
    XCTAssertTrue(1 == [scrollView reservingPage],
                  @"willedPage:%d", [scrollView reservingPage]);
}

@end