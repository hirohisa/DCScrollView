//
//  DCScrollViewNavigationViewCell.m
//
//  Created by Hirohisa Kawasaki on 2014/01/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import "DCScrollViewNavigationViewCell.h"

@interface DCScrollViewNavigationViewCell () {
@private
    NSNumber *_number;
}
@end

@implementation DCScrollViewNavigationViewCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return self;
}

- (void)dealloc
{
    _number = nil;
    [_textLabel removeFromSuperview];
    _textLabel = nil;
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

- (void)setTextLabel:(UILabel *)textLabel
{
    _textLabel = textLabel;
    [self addSubview:_textLabel];
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
    if (self.textLabel &&
        [self.textLabel.text length] &&
        CGSizeEqualToSize(self.textLabel.frame.size, CGSizeZero)) {
        [self.textLabel sizeToFit];
        self.textLabel.center = (CGPoint) {
            .x = CGRectGetWidth(self.frame)/2,
            .y = CGRectGetHeight(self.frame)/2
        };
    }
}
@end