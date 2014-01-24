//
//  DCScrollViewCell.m
//
//  Created by Hirohisa Kawasaki on 2014/01/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import "DCScrollViewCell.h"

@interface DCScrollViewCell () {
@private
    NSNumber *_number;
}

@property (nonatomic) NSInteger index;
@end

@implementation DCScrollViewCell
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super init]) {
		_reuseIdentifier = reuseIdentifier;
	}
	return self;
}

- (void)dealloc
{
    _number = nil;
    _reuseIdentifier = nil;
}

#pragma mark - accessor

- (void)setIndex:(NSInteger)index
{
    _number = @(index);
}

- (NSInteger)index
{
    if (_number) {
        return [_number integerValue];
    }
    return NSNotFound;
}

@end