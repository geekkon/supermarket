//
//  DBCategoryTableViewController.h
//  NewSupermarket
//
//  Created by Dim on 08.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBCategory;

typedef void (^SelectionBlock)(DBCategory *);

@interface DBCategoryTableViewController : UITableViewController

@property (copy, nonatomic) SelectionBlock block;

@end
