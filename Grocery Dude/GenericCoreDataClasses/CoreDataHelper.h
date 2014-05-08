//
//  CoreDataHelper.h
//  Grocery Dude
//
//  Created by Frank Cipolla on 2/1/14.
//  Copyright (c) 2014 Frank Cipolla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MigrationVC.h"

/* Roadley, Tim (2013-11-01). Learning Core Data for iOS: A Hands-On Guide to Building Core Data Applications (p. 8). Pearson Education. Kindle Edition.
*/

@interface CoreDataHelper : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *context;
@property (nonatomic, readonly) NSManagedObjectModel  *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, readonly) NSPersistentStore *store;
@property (nonatomic, retain) MigrationVC *migrationVC;

-(void) setupCoreData;
-(void) saveContext;

@end
