//
//  DCTitleScrollViewCell.h
//
//  Created by Hirohisa Kawasaki on 2014/01/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCTitleScrollViewCell : UIView

@property (nonatomic) NSInteger index;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@end