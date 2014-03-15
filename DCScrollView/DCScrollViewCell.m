//
//  DCScrollViewCell.m
//
//  Created by Hirohisa Kawasaki on 2014/01/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import "DCScrollViewCell.h"

@implementation DCScrollViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super init]) {
		_reuseIdentifier = reuseIdentifier;
	}
	return self;
}

@end