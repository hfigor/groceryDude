//
//  CoreDataTableViewController.h
//  Grocery Dude
//
//  Created by Frank Cipolla on 2/25/14.
//  Copyright (c) 2014 Frank Cipolla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"


@interface CoreDataTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *frc;

- (void)performFetch;

@end
