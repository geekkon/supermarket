//
//  DBCategory.h
//  NewSupermarket
//
//  Created by Dim on 06.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBItem;

@interface DBCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *items;
@end

@interface DBCategory (CoreDataGeneratedAccessors)

- (void)addItemsObject:(DBItem *)value;
- (void)removeItemsObject:(DBItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
