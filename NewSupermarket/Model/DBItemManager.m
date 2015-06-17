//
//  DBItemManager.m
//  NewSupermarket
//
//  Created by Dim on 03.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "DBItemManager.h"
#import "DBCategory.h"
#import "DBItem.h"

@interface DBItemManager ()

@property (nonatomic) dispatch_queue_t queue;

@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation DBItemManager

+ (DBItemManager *)sharedManager {
    
    static DBItemManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DBItemManager alloc] init];
    });
    
    return manager;
}

#pragma mark - Getters

- (dispatch_queue_t)queue {
    
    if (!_queue) {
       _queue = dispatch_queue_create("com.supermarket.order.queue", DISPATCH_QUEUE_SERIAL);
    }
 
    return _queue;
}

#pragma mark - DBItem Methods

- (DBItem *)createItem {
 
    DBItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"DBItem"
                                                 inManagedObjectContext:self.managedObjectContext];
    [self save];
    
    return item;
}

- (void)removeItem:(DBItem *)item {
    
    [self.managedObjectContext deleteObject:item];
    
    [self save];
}

static const NSUInteger DELAY_IN_SECONDS = 3;

- (void)addCount:(NSInteger)count toItem:(DBItem *)item onFailure:(VoidBlock)block {
    
    __weak DBItemManager *weakSelf = self;
    __weak DBItem *weakItem = item;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IN_SECONDS * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([weakSelf.managedObjectContext.registeredObjects containsObject:weakItem]) {

            dispatch_async(weakSelf.queue, ^{
                
                NSUInteger currentCount = [weakItem.count integerValue];
                NSInteger delta = currentCount + count;
                NSUInteger canOrderCount = count;
                
                if (delta < 0) {
                    canOrderCount = count - delta;
                }
                
                NSNumber *newCount = @(currentCount + canOrderCount);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    weakItem.count = newCount;
                    
                    [weakSelf save];
                    
                });
            });
            
        } else {
            
            if (block) {
                block();
            }
        }
    });
}

#pragma mark - DBCategory Methods

- (void)createCategoryWithName:(NSString *)name {
    
    DBCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"DBCategory" inManagedObjectContext:self.managedObjectContext];
    
    category.name = name;
    
    [self save];
}

- (void)renameCategory:(DBCategory *)category withName:(NSString *)name {
    
    category.name = name;
    
    [self.managedObjectContext refreshObject:category mergeChanges:YES];
    
    [self save];
}

- (void)deleteCategory:(DBCategory *)category {
    
    [self.managedObjectContext deleteObject:category];
    
    [self save];
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    
    if (coordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NewSupermarket" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NewSupermarket.sqlite"];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error]) {
 
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)save {
    
    NSError *error = nil;
    
    BOOL successful = [self.managedObjectContext save:&error];
    
    if (!successful) {
        [NSException raise:@"Error saving" format:@"Reason : %@", [error localizedDescription]];
    }
}


@end
