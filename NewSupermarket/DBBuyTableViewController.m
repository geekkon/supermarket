//
//  DBBuyTableViewController.m
//  NewSupermarket
//
//  Created by Dim on 09.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "DBBuyTableViewController.h"
#import "DBItemTableViewController.h"
#import "DBItem.h"

@interface DBBuyTableViewController ()

@end

@implementation DBBuyTableViewController

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showItem" sender:indexPath];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showItem"]) {
        DBItem *item = [self.fetchedResultsController objectAtIndexPath:sender];
        DBItemTableViewController *itemViewController = [segue destinationViewController];
        itemViewController.item = item;
        itemViewController.segueFromBuyController = YES;
    }
}

@end
