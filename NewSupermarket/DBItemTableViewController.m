//
//  DBItemTableViewController.m
//  NewSupermarket
//
//  Created by Dim on 09.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "DBItemTableViewController.h"
#import "DBCategoryTableViewController.h"
#import "DBItem.h"
#import "DBCategory.h"
#import "DBItemManager.h"

@interface DBItemTableViewController ()

@property (strong, nonatomic) DBCategory *category;

@end

@implementation DBItemTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isNewItem) {
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
        
        self.navigationItem.rightBarButtonItem = doneButton;
        
        self.navigationItem.title = @"New item";
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSLog(@"%@", self.category.name);
}

- (void)dealloc
{
    NSLog(@"                               ITEM VIEW CONTROLLER IS DEALOCATED");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"addItem"]) {
        
        

        
        //
        //        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        //        [[segue destinationViewController] setDetailItem:object];
        
    } else if ([[segue identifier] isEqualToString:@"chooseCategory"]) {
        
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            
            __block UITableViewCell *cell = sender;
            
            [[segue destinationViewController] setBlock:^(DBCategory *category) {
                self.category = category;
                cell.textLabel.text = category.name;
            }];
        }

    }

    
}


#pragma mark - Actions

- (void)doneAction:(UIBarButtonItem *)sender {
    
//    DBItem *item = [[DBItemManager sharedManager] createItem];
//    item.name = @"Random name";
//    item.info = @"just an info";
//    item.count = @(arc4random_uniform(100));
//    
//    DBCategory *category = [[DBItemManager sharedManager] createCategoryWithName:@"New category"];
//    
//    item.category = category;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
