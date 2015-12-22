//
//  PopTableViewController.m
//  糯米团
//
//  Created by Sunny on 12/11/15.
//  Copyright © 2015 IOSDevelopeGuid. All rights reserved.
//

#import "PopTableViewController.h"

@interface PopTableViewController ()

@property (nonatomic, strong) NSArray *statusArray;

@end

@implementation PopTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置不可以滚动表格、
    self.tableView.scrollEnabled = NO;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _statusArray = [[NSArray alloc] initWithObjects:@"online", @"offline", @"logout", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentify = @"StatusCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    if (indexPath.row == 0) {
        UIImage *onImage = [UIImage imageNamed:@"on"];
        cell.imageView.image = onImage;
        cell.textLabel.textColor = [UIColor colorWithRed:181.0/255 green:239.0/255 blue:109.0/255 alpha:1.0];
    }
    if (indexPath.row == 1) {
        UIImage *offImage = [UIImage imageNamed:@"off"];
        cell.imageView.image = offImage;
        cell.textLabel.textColor = [UIColor colorWithRed:208.0/255 green:208.0/255 blue:208.0/255 alpha:1.0];
    }
    if (indexPath.row == 2) {
        UIImage *logoutImage = [UIImage imageNamed:@"logout"];
        cell.imageView.image = logoutImage;
        cell.textLabel.textColor = [UIColor colorWithRed:254.0/255 green:120.0/255 blue:10.0/255 alpha:1.0];
    }
    
    cell.textLabel.text = _statusArray[indexPath.row];
    
    cell.contentView.backgroundColor = [UIColor colorWithRed:55.0/255 green:55.0/255 blue:55.0/255 alpha:1.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _status = _statusArray[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PopoverDismiss" object:nil];
}

@end
