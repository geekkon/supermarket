//
//  DBItemManager.h
//  NewSupermarket
//
//  Created by Dim on 03.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@class DBItem, DBCategory;

typedef void (^ComplitionBlock) (void);

@interface DBItemManager : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

+ (DBItemManager *)sharedManager;

//DBItem Methods
- (DBItem *)createItem;
- (void)removeItem:(DBItem *)item;

- (void)addCount:(NSInteger)count toItem:(DBItem *)item;
- (void)addCount:(NSInteger)count toItem:(DBItem *)item withBlock:(ComplitionBlock)block;

// DBCategory Methods
- (void)createCategoryWithName:(NSString *)name;
- (void)renameCategory:(DBCategory *)category withName:(NSString *)name;
- (void)deleteCategory:(DBCategory *)category;

- (void)save;

@end
