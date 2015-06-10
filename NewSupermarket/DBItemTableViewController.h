//
//  DBItemTableViewController.h
//  NewSupermarket
//
//  Created by Dim on 09.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBItem;

@interface DBItemTableViewController : UITableViewController

@property (strong, nonatomic) DBItem *item;

@end
