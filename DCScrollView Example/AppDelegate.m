//
//  AppDelegate.m
//  DCScrollView Example
//
//  Created by Hirohisa Kawasaki on 2014/03/14.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import "AppDelegate.h"
#import "DemoTableViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    self.window.rootViewController =
    [[UINavigationController alloc] initWithRootViewController:[[DemoTableViewController alloc]init]];

    [self.window makeKeyAndVisible];
    return YES;
}

@end
