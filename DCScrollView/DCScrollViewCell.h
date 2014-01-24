//
//  DCScrollViewCell.h
//
//  Created by Hirohisa Kawasaki on 2014/01/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCScrollViewCell : UIView

@property (nonatomic, readonly) NSString *reuseIdentifier;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end