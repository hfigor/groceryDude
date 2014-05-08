//
//  LocationAtHome.h
//  Grocery Dude
//
//  Created by Frank Cipolla on 5/6/14.
//  Copyright (c) 2014 Frank Cipolla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Location.h"

@class Item;

@interface LocationAtHome : Location

@property (nonatomic, retain) NSString * storedIn;
@property (nonatomic, retain) NSSet *items;
@end

@interface LocationAtHome (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
