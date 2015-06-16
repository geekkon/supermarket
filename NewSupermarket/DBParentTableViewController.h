//
//  DBParentTableViewController.h
//  NewSupermarket
//
//  Created by Dim on 16.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreData;

@interface DBParentTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
