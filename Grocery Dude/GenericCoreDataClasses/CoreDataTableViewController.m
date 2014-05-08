//
//  CoreDataTableViewController.m
//  Grocery Dude
//
//  Created by Frank Cipolla on 2/25/14.
//  Copyright (c) 2014 Frank Cipolla. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface CoreDataTableViewController ()

@end

@implementation CoreDataTableViewController
#define BREADCRUMBS 1

#pragma mark - FETCHING

- (void)  performFetch
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  if (self.frc)
  {
    [self.frc.managedObjectContext performBlockAndWait:^{
      NSError *error = nil;
      if (![self.frc performFetch:&error])
      {
        NSLog(@"Failed to perform fetch %@", error);
      }
      [self.tableView reloadData];
    }];
  }
    else
    {
      NSLog(@"Failed to fetch, the fetched results controller is nil.");
    }
} // performFetch


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DATASOURCE: UITableView // from Learning core data for iOS

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  return [[self.frc.sections objectAtIndex:section] numberOfObjects];
} // tableView numberOfRowsInSection

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  return [[self.frc sections] count];
} // numberOfSectionsInTableView

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  return [self.frc sectionForSectionIndexTitle:title atIndex:index];
} // tableView  sectionForSectionIndexTitle

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  return [[[self.frc sections] objectAtIndex:section] name];
} // tableView  titleForHeaderInSection

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  return [self.frc sectionIndexTitles];
} // sectionIndexTitlesForTableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

/*

 You can tell by looking in its header file that CoreDataTVC adopts the NSFetchedResultsControllerDelegate protocol, which means optional methods can now be implemented to ensure the Table View Controller correctly handles moves, deletes, updates, and insertions. Whenever you need to make a change to a table view, you need to tell it to beginUpdates, and when you’re done, endUpdates. When you’re using a fetched results controller, you need to call these methods from controllerWillChangeContent and controllerDidChangeContent,

 Roadley, Tim (2013-11-01). Learning Core Data for iOS: A Hands-On Guide to Building Core Data Applications (p. 98). Pearson Education. Kindle Edition.
*/
#pragma mark - DELEGATE: NSFetchedResultsController

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  [self.tableView beginUpdates];
}

-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  [self.tableView endUpdates];
}

-(void) controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  switch (type) {
    case NSFetchedResultsChangeInsert:

      /*
       The chosen animation option makes sure there’s no fade-in delay. You may wish to set this to UITableViewRowAnimationAutomatic if you adapt this code to your own projects.

       Roadley, Tim (2013-11-01). Learning Core Data for iOS: A Hands-On Guide to Building Core Data Applications (p. 99). Pearson Education. Kindle Edition.
       */

      // [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]withRowAnimation:UITableViewRowAnimationFade];

      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]withRowAnimation:UITableViewRowAnimationAutomatic];

      break;

    case NSFetchedResultsChangeDelete:
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
      break;
      
    default:
      break;
  }
}

- (void) controller:(NSFetchedResultsController *) controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  UITableView *tableView = self.tableView;

  switch (type) {
    case NSFetchedResultsChangeInsert:
     [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      break;

      case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      break;

      case NSFetchedResultsChangeUpdate:
      if (!newIndexPath)
      {
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
      }
      else
      {
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone  ];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
      }
      break;

      case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      break;

    default:
      break;
  }
}
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
