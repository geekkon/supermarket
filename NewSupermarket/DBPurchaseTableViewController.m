//
//  DBPurchaseTableViewController.m
//  NewSupermarket
//
//  Created by Dim on 03.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "DBPurchaseTableViewController.h"
#import "DBItemTableViewController.h"
#import "DBItemManager.h"
#import "DBItem.h"

@interface DBPurchaseTableViewController ()

@end

@implementation DBPurchaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"editItem" sender:indexPath];
}

#pragma mark - <UITableViewDataSource>

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DBItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[DBItemManager sharedManager] removeItem:item];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"editItem"]) {
        DBItem *item = [self.fetchedResultsController objectAtIndexPath:sender];
        DBItemTableViewController *itemViewController = [segue destinationViewController];
        itemViewController.item = item;
    }
}

@end
