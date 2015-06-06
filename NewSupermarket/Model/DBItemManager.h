//
//  DBItemManager.h
//  NewSupermarket
//
//  Created by Dim on 03.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DBItem;

extern NSString * const DBItemManagerDidChangeDataNotification;


@interface DBItemManager : NSObject

+ (DBItemManager *)sharedManager;

- (NSUInteger)itemsCount;
- (DBItem *)itemAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfItem:(DBItem *)item;

- (void)addCount:(NSInteger)count toItem:(DBItem *)item;

@end
