//
//  DBItemManager.m
//  NewSupermarket
//
//  Created by Dim on 03.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "DBItemManager.h"
#import "DBItem.h"

NSString * const DBItemManagerDidChangeDataNotification = @"DBItemManagerDidChangeDataNotification";

@interface DBItemManager ()

@property (strong, nonatomic) NSMutableArray *items;
@property (nonatomic) dispatch_queue_t queue;

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

- (NSMutableArray *)items {
    
    if (!_items) {
        
        _items = [NSMutableArray array];
        
        for (int i = 0; i < 10; i++) {
            DBItem *item = [[DBItem alloc] init];
            item.name = [NSString stringWithFormat:@"Item number %d", i];
            item.count = arc4random_uniform(100);
            [self.items addObject:item];
        }
    }
    
    return _items;
}

- (NSUInteger)itemsCount {
    
    return 10;
}

- (DBItem *)itemAtIndex:(NSUInteger)index {
    
    return self.items[index];
}

static const NSUInteger DELAY_IN_SECONDS = 3;

- (void)addCount:(NSInteger)count toItem:(DBItem *)item {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IN_SECONDS * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        dispatch_async(self.queue, ^{
            
            if (item) {
                
                item.count += count;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:DBItemManagerDidChangeDataNotification
                                                                        object:item
                                                                      userInfo:nil];
                });
            }
        });
    });
}

- (NSUInteger)indexOfItem:(DBItem *)item {
    
    return [self.items indexOfObject:item];
}

@end
