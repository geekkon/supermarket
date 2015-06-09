//
//  DBCategory.h
//  NewSupermarket
//
//  Created by Dim on 06.06.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@interface DBCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *items;

@end
