//
//  DCScrollViewNavigationViewCell.m
//
//  Created by Hirohisa Kawasaki on 2014/01/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import "DCScrollViewNavigationViewCell.h"

@interface DCScrollViewNavigationViewCellLabel : UILabel

@end

@implementation DCScrollViewNavigationViewCellLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return self;
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self sizeToFit];
}

@end

@implementation DCScrollViewNavigationViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.index = NSNotFound;
        self.textLabel = [[DCScrollViewNavigationViewCellLabel alloc] initWithFrame:CGRectZero];
    }
    return self;
}

#pragma mark - accessor

- (void)setTextLabel:(UILabel *)textLabel
{
    _textLabel = textLabel;
    [self addSubview:textLabel];
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    if (self.textLabel) {
        self.textLabel.highlighted = highlighted;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.textLabel) {
        self.textLabel.center = (CGPoint) {
            .x = CGRectGetWidth(self.frame)/2,
            .y = CGRectGetHeight(self.frame)/2
        };
    }
}

@end