//
//  DemoTableViewController.m
//  Demo
//
//  Created by Hirohisa Kawasaki on 13/08/27.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import "DemoTableViewController.h"
#import "DemoViewController.h"

@interface DemoTableViewController ()

@end

@implementation DemoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *text;
    if (indexPath.row == 0) {
        text = @"sample 10 cells";
    } else if (indexPath.row == 1) {
        text = @"sample 1 cells";
    }
    cell.textLabel.text = text;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DemoViewController *viewController = [[DemoViewController alloc] init];
    if (indexPath.row == 0) {
        viewController.numerOfCells = 10;
    }

    [self.navigationController pushViewController:viewController animated:YES];
}

@end
