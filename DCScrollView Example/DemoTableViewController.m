//
//  DemoTableViewController.m
//  Demo
//
//  Created by Hirohisa Kawasaki on 13/08/27.
//  Copyright (c) 2013年 Hirohisa Kawasaki. All rights reserved.
//

#import "DemoTableViewController.h"
#import "DemoViewController.h"
#import "CustomCellDemoViewController.h"

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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *text;
    switch (indexPath.row) {
        case 0:
            text = @"10 cells";
            break;

        case 1:
            text = @"1 cell";
            break;

        case 2:
            text = @"none";
            break;

        case 3:
            text = @"custom cells";
            break;

        default:
            break;
    }
    cell.textLabel.text = text;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController;
    switch (indexPath.row) {
        case 3:
            viewController = [[CustomCellDemoViewController alloc] init];
            break;
        default:
            viewController = [[DemoViewController alloc] init];
            NSInteger numberOfCells = 0;
            if (indexPath.row == 0) {
                numberOfCells = 10;
            } else if (indexPath.row == 1) {
                numberOfCells = 1;
            }
            [(DemoViewController *)viewController setNumerOfCells:numberOfCells];
            break;
    }

    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
