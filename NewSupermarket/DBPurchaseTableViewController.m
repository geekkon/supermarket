//
//  DBPurchaseTableViewController.m
//  NewSupermarket
//
//  Created by Dim on 03.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "DBPurchaseTableViewController.h"
#import "DBItemTableViewController.h"
#import "DBItem.h"
#import "DBItemManager.h"
#import "DBTableViewCell.h"

@interface DBPurchaseTableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation DBPurchaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [[DBItemManager sharedManager] generateData];

    [self.tableView registerNib:[UINib nibWithNibName:@"DBTableViewCell" bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"Cell"];
    
     self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters

- (NSManagedObjectContext *)managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [DBItemManager sharedManager].managedObjectContext;
    }
    
    return _managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = [NSEntityDescription entityForName:@"DBItem"
                                      inManagedObjectContext:self.managedObjectContext];
    
    fetchRequest.fetchBatchSize = 10;
    
    NSSortDescriptor *categoryDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"category.name" ascending:YES];
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                     ascending:YES];
    
    fetchRequest.sortDescriptors = @[categoryDescriptor, nameDescriptor];
    
    _fetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:@"category.name"
                                                   cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"editItem" sender:nil];
}

#pragma mark - <UITableViewDataSource>
 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController.sections count];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    
    return [sectionInfo name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (DBTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        DBItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[DBItemManager sharedManager] removeItem:item];
    }
}

#pragma mark - Private Methods

- (void)configureCell:(DBTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    DBItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.nameLabel.text = item.name;
    cell.infoLabel.text = item.info;
    cell.countLabel.text = [NSString stringWithFormat:@"Count: %@", item.count];
}

#pragma mark - <NSFetchedResultsControllerDelegate>

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];

            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"editItem"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DBItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[segue destinationViewController] setItem:item];
    }
}

@end
