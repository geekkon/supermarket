//
//  DBItem.h
//  NewSupermarket
//
//  Created by Dim on 06.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@class DBCategory;

@interface DBItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) DBCategory *category;

@end
