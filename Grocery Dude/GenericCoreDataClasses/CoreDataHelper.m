//
//  CoreDataHelper.m
//  Grocery Dude
//
//  Created by Frank Cipolla on 2/1/14.
//  Copyright (c) 2014 Frank Cipolla. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

#define BREADCRUMBS 1
#define DEBUG_TRACE 1

#pragma mark - FILES
NSString *storeFilename = @"Grocery Dude.sqlite";

#pragma mark - PATHS
-(NSString *)applicationDocumentsDirectory
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) lastObject];
}

-(NSURL *)applicationStoresDirectory
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  NSURL *storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"];

  NSFileManager *fileManager = [NSFileManager defaultManager];

  if (![fileManager fileExistsAtPath:[storesDirectory path] ])
  {
    NSError *error = Nil;
    if  ([fileManager createDirectoryAtURL:storesDirectory withIntermediateDirectories:YES attributes:Nil error: &error])
    {
      if (DEBUG_TRACE==1)
      {
        NSLog(@"Successfully created Stores directory");
      }
    }
    else
    {
      NSLog(@"FAILED to create Stores directory: %@",error);
    }

  }
  return storesDirectory;
}

-(NSURL *)storeUrl
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  return [[self applicationStoresDirectory] URLByAppendingPathComponent:storeFilename];

}

#pragma mark - SETUP

-(id)init
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  self = [super init];
  if (!self) {
    return nil;
  }

  _model = [NSManagedObjectModel mergedModelFromBundles:nil];
  _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
  _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];

  [_context setPersistentStoreCoordinator:_coordinator];

  return self;
}

-(void)loadStore
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  if (_store) { return;} // Don't load store if already loaded

  // Check to see if coredata store model is current
  BOOL useMigrationManager = NO;
  if (useMigrationManager && [self isMigrationNecessaryForStore:[self storeUrl]])
  {
    [self performBackgroundManagedMigrationForStore:[self storeUrl]];
  }
  else
  {
    NSDictionary *options =
    @{NSMigratePersistentStoresAutomaticallyOption: @YES
      , NSInferMappingModelAutomaticallyOption: @YES // NO page 53
      , NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"}
      };

    NSError *error = nil;
    _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil
                                                  URL:[self storeUrl]
                                              options:options
                                                error:&error];

    if (!_store)
    {
      NSLog(@"Failed to add store. Error: %@",error);
      abort();
    }
    else
    {
      if (DEBUG_TRACE==1)
      {
        NSLog(@"Successfully added store: %@", _store);
      }
    }
  }
}

-(void)setupCoreData
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  [self loadStore];
}

#pragma mark - SAVING

-(void)saveContext
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  if ([_context hasChanges])
  {
    NSError *error = nil;

    if ([_context save:&error])
    {
      NSLog(@" _context SAVED changes to persistant store");
    }
    else
    {
      NSLog(@"Failed to save _context: %@",error);

      [self showValidationError: error];
    }
  }
  else
  {
    NSLog(@"SKIPPED _context save, there are no changes!");
  }
}

#pragma mark - MIGRATION MANAGER

-(BOOL) isMigrationNecessaryForStore:(NSURL *) storeURL
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  if (![[NSFileManager defaultManager] fileExistsAtPath:[self storeUrl].path])
  {
    if (BREADCRUMBS==1)
    {
      NSLog(@"SKIPPED MIGRATION: Source database missing.");
    }
    return NO;
  }

  NSError *error = nil;
  NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL error:&error];
  NSManagedObjectModel *destinationMadel = _coordinator.managedObjectModel;
  if ([destinationMadel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata])
  {
    if (DEBUG_TRACE==1)
    {
      NSLog(@"SKIPPED MIGRATION: Source is already compatible.");
    }
    return NO;
  }
  return  YES;
}

-(BOOL) migrateStore: (NSURL *) sourceStore
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  BOOL success = NO;
  NSError *error = nil;

  // Step 1 - Gather the Source, Destination and Mapping Model
  NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:sourceStore error:&error];
  NSManagedObjectModel *sourceModel =
  [NSManagedObjectModel mergedModelFromBundles:nil
                              forStoreMetadata:sourceMetadata];
  NSManagedObjectModel * destinModel = _model;

  NSMappingModel *mappingModel =
  [NSMappingModel mappingModelFromBundles:nil
                           forSourceModel:sourceModel
                         destinationModel:destinModel];

  // step 2 - Perform migration, assuming the mapping model isn't null

  if (mappingModel)
  {
    NSError *error = nil;
    NSMigrationManager *migrationManager =
    [[NSMigrationManager alloc]initWithSourceModel:sourceModel
                                  destinationModel:destinModel];
    [migrationManager addObserver:self
                       forKeyPath:@"migrationProgress"
                          options:NSKeyValueObservingOptionNew
                          context:NULL];

    NSURL * destinStore =
    [[self applicationStoresDirectory]
     URLByAppendingPathComponent:@"temp.sqlite"];

    success =
    [migrationManager migrateStoreFromURL:sourceStore
                                     type:NSSQLiteStoreType
                                  options:nil
                         withMappingModel:mappingModel
                         toDestinationURL:destinStore
                          destinationType:NSSQLiteStoreType
                       destinationOptions:nil
                                    error:&error];

    if (success)  // migration succeeded
    {
      // step 3 - Replace the old store with the new migrated store

      if ([self replaceStore:sourceStore withStore:destinStore])
      {
        if (DEBUG_TRACE==1)
        {
          NSLog(@"SUCCESSFULLY MIGRATED %@ to the current model",sourceStore.path);
        }

        [migrationManager removeObserver:self forKeyPath:@"migrationProgress"];
      }
    }
    else
    {
      if (DEBUG_TRACE==1)
      {
        NSLog(@"FAILED MIGRATION: %@",error);
      }
    }
  }
  else
  {
    if (DEBUG_TRACE==1)
    {
      NSLog(@"FAILED MIGRATION: Mapping model is null");
    }
  }
  return YES; // indicates migration is finished, regardless of outcome.
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if ([keyPath isEqualToString:@"migrationProgress"])
  {
    dispatch_async(dispatch_get_main_queue(), ^{
      float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
      self.migrationVC.progressView.progress = progress;
      int percentage = progress * 100;
      NSString *string = [NSString stringWithFormat:@"Migration Progress:%i%%",percentage];
      NSLog(@"%@",string);
      self.migrationVC.label.text = string;
    });
  }
}

-(BOOL) replaceStore: (NSURL *)old withStore:(NSURL *)new
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  BOOL success = NO;
  NSError *error = nil;

  if ([[NSFileManager defaultManager] removeItemAtURL:old
                                                error:&error])
  {
    error = nil;
    if([[NSFileManager defaultManager]moveItemAtURL:new
                                              toURL:old
                                              error:&error])
    {
      success = YES;
    }
    else
    {
      if (DEBUG_TRACE==1)
      {
        NSLog(@"FAILED to re-home new store Error: %@",error);
      }
    }
  }
  else
  {
    if (DEBUG_TRACE==1)
    {
      NSLog(@"FAILED to remove old store %@: Error: %@",old,error);
    }
  }
  return success;
}

-(void) performBackgroundManagedMigrationForStore:(NSURL *) storeURL
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

// Show migration progress vuew preventing the user from using the app

  UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.migrationVC = [sb instantiateViewControllerWithIdentifier:@"migration"];
  UIApplication *sa = [UIApplication sharedApplication];
  UINavigationController *nc = (UINavigationController *)sa.keyWindow.rootViewController;
  [nc presentViewController:self.migrationVC animated:NO completion:nil];

  // Perform migration in background, so it doesn't freeze the UI.
  // This way progress can be shown to the user.

  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND,0), ^{
    BOOL done = [self migrateStore:storeURL];
    if (done)
    {
      // When migration finishes, add the newly migrated store.
      dispatch_async(dispatch_get_main_queue(), ^{
        NSError * error = nil;
        _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL: [self storeUrl] options:nil error:&error];

        if (!_store)
        {
          NSLog(@"Failed to add migrated store. Error: %@", error);
          abort();
        }
        else
        {
          NSLog(@"Successfully added a migration store: %@",_store);
        }
        [self.migrationVC dismissViewControllerAnimated:NO completion:nil];
        self.migrationVC = nil;
      });
    }
  });
}


#pragma mark -  VALIDATION ERROR HANDlING
  - (void) showValidationError: (NSError *)anError
  {
    if (BREADCRUMBS==1)
    {
      NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

    if (anError && [anError.domain isEqualToString:@"NSCocoaErrorDomain"])
    {
      NSArray *errors = nil;  // Holds all errors
      NSString *txt = @" "; // the error message text of the alert

      // Populate array with error(s)
      if (anError.code == NSValidationMultipleErrorsError)
      {
        errors = [anError.userInfo objectForKey:NSDetailedErrorsKey];
      }
      else
      {
        errors = [NSArray arrayWithObject:anError];
      }

      // Display the error(s)
      if (errors && errors.count > 0)
      {
        // Buid error message text based on errors
        for (NSError *error in errors)
        {
          NSString *entity = [[[error.userInfo  objectForKey:@"NSValidationErrorObject"]entity]name];
          NSString *property = [error.userInfo objectForKey:@"NSValidationErrorKey"];

          switch (error.code)
          {
            case NSManagedObjectValidationError:
              txt = [txt stringByAppendingFormat:@"%@ database Object validation error associated with %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
              break;

            case NSValidationMultipleErrorsError:
              txt = [txt stringByAppendingFormat:@"%@ Multiple database validation errors associated with %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
              break;

            case NSValidationMissingMandatoryPropertyError:
              txt = [txt stringByAppendingFormat:@"%@ missing mandatory property  %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
              break;

            case NSValidationRelationshipLacksMinimumCountError:
              txt = [txt stringByAppendingFormat:@"%@ database relationship lacks minimum count associated with %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
              break;

            case NSValidationRelationshipExceedsMaximumCountError:
              txt = [txt stringByAppendingFormat:@"%@ database relationship exceeds maximum count associated with %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
              break;

            case NSValidationRelationshipDeniedDeleteError:
              txt = [txt stringByAppendingFormat:@"%@ delete was denied because there are associated %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
              break;

            case NSValidationNumberTooLargeError:
              txt = [txt stringByAppendingFormat:@"%@ Number is too large associated with %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
              break;

            case NSValidationNumberTooSmallError:
              txt = [txt stringByAppendingFormat:@"%@ Number is too small associated with %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
              break;

            case NSValidationDateTooLateError:
              txt = [txt stringByAppendingFormat:@"%@ Date is too late associated with %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
              break;

            case NSValidationDateTooSoonError:
              txt = [txt stringByAppendingFormat:@"%@ Date is too soon associated with %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
              break;

            case NSValidationInvalidDateError:
              txt = [txt stringByAppendingFormat:@"%@ Date is invalid associated with %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
              break;

            case NSValidationStringTooLongError:
              txt = [txt stringByAppendingFormat:@"%@ String is too long associated with %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
              break;


            case NSValidationStringTooShortError:
              txt = [txt stringByAppendingFormat:@"%@ String is too short associated with %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
              break;


            case NSValidationStringPatternMatchingError:
              txt = [txt stringByAppendingFormat:@"%@ Invalid string pattern matching associated with %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
              break;

            default:
              txt = [txt stringByAppendingFormat:@"Unhandled error code %li in showValidationError methode", (long)error.code];
              break;
          }
          // display error text message
          UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Validation Error" message:[NSString stringWithFormat:@"%@Please double-tap the home button and close this application by swiping the application screenshot upwards", txt] delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
          [alertview show];
        }
      }
    }

  }

@end
