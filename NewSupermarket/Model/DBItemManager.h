//
//  DBItemManager.h
//  NewSupermarket
//
//  Created by Dim on 03.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@class DBItem;

extern NSString * const DBItemManagerDidChangeDataNotification;

@interface DBItemManager : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

+ (DBItemManager *)sharedManager;

- (void)generateData; // items + categories generation


- (DBItem *)createItem;

- (NSUInteger)itemsCount;
- (DBItem *)itemAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfItem:(DBItem *)item;

- (void)addCount:(NSInteger)count toItem:(DBItem *)item;

- (void)save;

@end
