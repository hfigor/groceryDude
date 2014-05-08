//
//  AppDelegate.m
//  Grocery Dude
//
//  Created by Frank Cipolla on 1/31/14.
//  Copyright (c) 2014 Frank Cipolla. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "Item.h"
//#import "Measurement.h"
//#import "Amount.h"
#import "Unit.h"
#import "LocationAtHome.h"
#import "LocationAtShop.h"


@implementation AppDelegate

#define BREADCRUMBS 1

#pragma mark - DEMO DATA

-(void) demo
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

#pragma mark - ADD DEMO ITEM RECORDS
// #define ADD_ITEM_RECORDS 1
#ifdef  ADD_ITEM_RECORDS
  NSArray *newItemNames = [NSArray arrayWithObjects:@"Apples", @"Milk", @"Bread", @"Cheese", @"Sausages", @"Butter", @"Orange Juice", @"Cereal", @"Coffee", @"Eggs", @"Tomatoes", @"Fish", nil];

  for (NSString *newItemName in newItemNames) {
    Item *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_coreDataHelper.context];
    newItem.name = newItemName;
    NSLog(@"Inserted new Managed Object for '%@'", newItem.name);
  }
#endif  //ADD_ITEM_RECORDS

#pragma mark - ADD DEMO MEASUREMENT RECORDS
// #define ADD_MEASUREMENT_RECORDS 1
#ifdef ADD_MEASUREMENT_RECORDS
 if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
    for (int i = 1; i<5000; i++)
    {
      Measurement *newMeasurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:_coreDataHelper.context];

      newMeasurement.abc = [NSString stringWithFormat:@"-->>> LOTS OF TEST DATA x%i",i];
      NSLog(@"Inserted %@",newMeasurement.abc);
    }

    [_coreDataHelper saveContext];

#endif  // ADD_MEASUREMENT_RECORDS


#pragma mark - DEMO FETCH ITEM RECORDS
// #define FETCH_ITEM_RECORDS 1
#ifdef FETCH_ITEM_RECORDS
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];

  NSSortDescriptor *sort= [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

  [request setSortDescriptors:[NSArray arrayWithObject:sort]];

 /* NSPredicate *filter = [NSPredicate predicateWithFormat:@"name != %@",@"Coffee"];
  [request setPredicate:filter];
*/
  NSArray *fetchedObjects =[_coreDataHelper.context executeFetchRequest:request error:nil];

  for (Item *item in fetchedObjects)
  {
    NSLog(@"Fetched Object = %@",item.name);
  }
  /* delete all items
  for (Item *item in fetchedObjects) {
    NSLog(@"deleting Object = %@",item.name);
    [_coreDataHelper.context deleteObject:item];
  }
   */
#endif  // FETCH_ITEM_RECORDS

#pragma mark _ FETCH MEASUREMENT RECORDS
// #define FETCH_MEASUREMENT_RECORDS 1
#ifdef FETCH_MEASUREMENT_RECORDS // page 55 change to Amount
// page 67 change to unit
  NSFetchRequest *requestMeasurements = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
  [requestMeasurements setFetchLimit:50];
  NSError *error = nil;
  NSArray *fetchedMeasurementObjects = [_coreDataHelper.context executeFetchRequest:requestMeasurements error:&error];
  if (error)
  {
    NSLog(@" %@",error);
  }
  else
  {
    // for (Measurement *measurement in fetchedMeasurementObjects) {
    for (Unit *unit in fetchedMeasurementObjects) {

      NSLog(@"Fetched bject = %@",unit.name);
    }
  }
#endif  // FETCH_MEASUREMENT_RECORDS

#pragma mark - MAKE ITEM/UNIT RELATIONSHIPS
// Page 75  Adding relationship to items and units
//#define MAKE_ITEM_UNIT_RELATIONSHIP 1
#ifdef MAKE_ITEM_UNIT_RELATIONSHIP

if (BREADCRUMBS==1)
{
  NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
}
  Unit *kg = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:cdh.context];
  //inManagedObjectContext:[[self cdh] context]];
  Item *oranges = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:cdh.context];
  Item *bananas = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:cdh.context];

  kg.name = @"Kg";
  oranges.name = @"Oranges";
  bananas.name = @"Bananas";
  oranges.quantity =[NSNumber numberWithInt:1];
  bananas.quantity = [NSNumber numberWithInt:4];
  oranges.listed = [NSNumber numberWithBool:YES];
  bananas.listed = [NSNumber numberWithBool:YES];
  oranges.unit = kg;
  bananas.unit = kg;

  NSLog(@"Inserted %@%@ %@",oranges.quantity,oranges.unit.name,oranges.name);

  NSLog(@"Inserted %@%@ %@",bananas.quantity,bananas.unit.name,bananas.name);

  //[[self cdh] saveContext];
  [cdh saveContext];


#endif // MAKE_ITEM_UNIT_RELATIONSHIP

  [self showUnitAndItemCount];
  // [self deleteUnits: (NSString *)@"Kg" ];

#pragma mark - DEMO POPULATE LOCATIONS WITH DATA
//#define POPULATE_LOCATIONS 1
#ifdef POPULATE_LOCATIONS
  NSArray *homeLocations = [NSArray arrayWithObjects:@"Fruit Bowl",@"Pantry",@"Nursery",@"Bathroom",@"Fridge", nil];
  NSArray *shopLocations = [NSArray arrayWithObjects:@"Produce",@"Aisle 1",@"Aisle 2",@"Aisle 3",@"Deli", nil];
  NSArray *unitNames = [NSArray arrayWithObjects:@"g",@"pkt",@"box",@"ml",@"kg", nil];
  NSArray *itemNames = [NSArray arrayWithObjects:@"Grapes",@"Biscuits",@"Diapers",@"Shampoo",@"Sausages", nil];

  int i = 0;
  for (NSString *itemName in itemNames)
  {
    LocationAtHome *locationAtHome = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome" inManagedObjectContext:cdh.context];
    LocationAtShop *locationAtShop = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop" inManagedObjectContext:cdh.context];
    Unit *unit = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:cdh.context];
    Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:cdh.context];

    locationAtHome.storedIn = [homeLocations objectAtIndex:i];
    locationAtShop.aisle = [shopLocations objectAtIndex:i];
    unit.name = [unitNames objectAtIndex:i];

    item.locationAtHome = locationAtHome;
    item.locationAtShop = locationAtShop;
    item.unit = unit;
    item.name = [itemNames objectAtIndex:i];
    i++;
  }

  [cdh saveContext];

#endif  // POPULATE_LOCATIONS

} // END OF DEMO METHOD **********************************

#pragma mark - COREDATA CONTEXT HELPER

- (CoreDataHelper *) cdh
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  if (!_coreDataHelper)
  {
    static dispatch_once_t predicate;
    dispatch_once (&predicate, ^{
      _coreDataHelper = [CoreDataHelper new];
    });

    [_coreDataHelper setupCoreData];
  }

  return _coreDataHelper;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  /* *************** Save CoreData context ********** */
  [[self cdh] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  [self cdh];
  [self demo];
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  /* *************** Save CoreData context ********** */
  [[self cdh] saveContext];
}

- (void)  showUnitAndItemCount
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
// List how many items there are in the database
  NSFetchRequest *items = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
  NSError *itemsError = nil;
  NSArray *fetchedItems = [[[self cdh] context]executeFetchRequest:items error:&itemsError];
  if (!fetchedItems)
  {
    NSLog(@"%@", itemsError);
  }
  else
  {
    NSLog(@"Found %lu item(s)", (unsigned long)[fetchedItems count]);
  }

  // List how many units there are in the database
  NSFetchRequest *units = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
  NSError *unitError = nil;
  NSArray *fetchedUnits = [[[self cdh] context] executeFetchRequest:units error:&unitError];
  if (!fetchedUnits)
  {
    NSLog(@"%@", unitError);
  }
  else
  {
    NSLog(@"Found %lu unit(s)", (unsigned long)[fetchedUnits count]);
  }
}

- (void) deleteUnits: (NSString *)thisUnit
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  NSLog(@"Before deletion of the unit entity");

  [self showUnitAndItemCount];

  NSFetchRequest *unitRequest = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
  //NSString *filterString = [NSString stringWithFormat:@"name == %@", thisUnit];
  NSPredicate *filter = [NSPredicate predicateWithFormat:@"name == %@", thisUnit];
  [unitRequest setPredicate:filter];
  NSArray *unitsArray = [[[self cdh] context] executeFetchRequest:unitRequest error:nil];
  
  for (Unit *unit in unitsArray)
  {
    [ _coreDataHelper.context deleteObject:unit];
/*
    if ([unit validateForDelete:&error])
    {
      NSLog(@"Deleting '%@'",unit.name);
    [ _coreDataHelper.context deleteObject:unit];
    NSLog(@"A %@ unit object was deleted",thisUnit);
  }
    else
    {
      NSLog(@"Failed to delete %@, error: %@",unit.name, error.localizedDescription);
      break;
    }
 */
  }
  NSLog(@"After delition of the unit entiry:");
  [[self cdh] saveContext];

  [self showUnitAndItemCount];
}

@end
