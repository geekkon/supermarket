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

NSString * const DBItemManagerDidChangeDataNotification = @"DBItemManagerDidChangeDataNotification";

@interface DBItemManager ()

@property (strong, nonatomic) NSMutableArray *items;
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
        manager.queue = dispatch_queue_create("com.supermarket.order.queue", DISPATCH_QUEUE_SERIAL);
    });
    
    return manager;
}

- (void)generateData {
    
    for (int i = 0; i < 10; i++) {
        
        DBCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"DBCategory" inManagedObjectContext:self.managedObjectContext];
        
        category.name = [NSString stringWithFormat:@"Category #%d", i + 1];
        
        for (int j = 0; j < 10; j++) {
            
            DBItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"DBItem" inManagedObjectContext:self.managedObjectContext];
            
            item.name = [NSString stringWithFormat:@"Item number %d", j + 1];
            item.info = [NSString stringWithFormat:@"Info for item number %d", j + 1];
            item.count = @(arc4random_uniform(100));
            item.category = category;
        }
        
    }
    
    [self save];
}

- (DBItem *)createItem {
 
    DBItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"DBItem"
                                                 inManagedObjectContext:self.managedObjectContext];
    [self save];
    
    return item;
}

- (NSUInteger)itemsCount {
    
    return [self.items count];
}

- (DBItem *)itemAtIndex:(NSUInteger)index {
    
    return self.items[index];
}

static const NSUInteger DELAY_IN_SECONDS = 3;

- (void)addCount:(NSInteger)count toItem:(DBItem *)item {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IN_SECONDS * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        dispatch_async(self.queue, ^{
            
            if (item) {
                
                item.count = @([item.count integerValue] + count);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                 
                    [self save];

                 
                    /*
                    [[NSNotificationCenter defaultCenter] postNotificationName:DBItemManagerDidChangeDataNotification
                                                                        object:item
                   
                     userInfo:nil];
                     
                     */
                });
                
            }
        });
    });
}

- (NSUInteger)indexOfItem:(DBItem *)item {
    
    return [self.items indexOfObject:item];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
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

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NewSupermarket" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NewSupermarket.sqlite"];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:*/
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
         NSLog(@"STORE CLEANED");
        //  * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
        //     @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
        /*     BOOL success = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL
         options:@{NSMigratePersistentStoresAutomaticallyOption:@YES,NSInferMappingModelAutomaticallyOption:@YES}
         error:&error];
         if (!success)
         {
         //  Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
         }*/
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
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
