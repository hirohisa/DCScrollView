//
//  DemoViewController.h
//  Demo
//
//  Created by Hirohisa Kawasaki on 13/03/29.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCScrollView.h"

@interface DemoViewController : UIViewController
<DCScrollViewDataSource, DCScrollViewDelegate>

@property (nonatomic) NSInteger numerOfCells;
@property (nonatomic, strong) DCScrollView *scrollView;

@end
