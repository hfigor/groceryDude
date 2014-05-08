//
//  PrepareTableViewController.m
//  Grocery Dude
//
//  Created by Frank Cipolla on 3/3/14.
//  Copyright (c) 2014 Frank Cipolla. All rights reserved.
//

#import "PrepareTableViewController.h"
#import "CoreDataHelper.h"
#import "Item.h"
#import "Unit.h"
#import "AppDelegate.h"

@interface PrepareTableViewController ()

@end

@implementation PrepareTableViewController

#define BREADCRUMBS 1
/*
if (BREADCRUMBS==1)
{
  NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
}
 */

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - VIEW

- (void)viewDidLoad
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  [super viewDidLoad];
  [self configureFetch];
  [self performFetch];
  self.clearConfirmActionSheet.delegate = self;

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performFetch) name:@"SomethingChanged" object:nil];
  // to pause for debug int j = 0;
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  static NSString *cellIdentifier = @"Item Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  cell.accessoryType = UITableViewCellAccessoryDetailButton;
  Item *item = [self.frc objectAtIndexPath:indexPath];
  NSMutableString *title = [NSMutableString stringWithFormat:@"%@%@ %@", item.quantity, item.unit.name, item.name];
  [title replaceOccurrencesOfString:@"(null)" withString:@"" options:0 range:NSMakeRange(0, [title length])];
  cell.textLabel.text = title;

  // Make selected items orange
  if ([item.listed boolValue])
  {
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:18]];
    [cell.textLabel setTextColor:[UIColor orangeColor]];
  }
  else
  {
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16]];
    [cell.textLabel setTextColor:[UIColor grayColor]];
  }
  return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  return nil; // Override CoreDataTableViewController method- We don't want a section index
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  if (editingStyle == UITableViewCellEditingStyleDelete) {
    Item *deleteTarget = [self.frc objectAtIndexPath:indexPath];
    [self.frc.managedObjectContext deleteObject:deleteTarget];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  NSManagedObjectID *itemId = [[self.frc objectAtIndexPath:indexPath] objectID];
  Item *item = (Item *)[self.frc.managedObjectContext existingObjectWithID:itemId error:nil];
  if ([item.listed boolValue])
  {
    item.listed = [NSNumber numberWithBool:NO];
  }
  else
  {
    item.listed = [NSNumber numberWithBool:YES];
    item.collected = [NSNumber numberWithBool:NO];
  }
  // for debugging:
  NSString*mystring;
  mystring = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
  NSLog(@"%@",mystring);
  // debugging ^^^
  [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DATA

- (void)configureFetch
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate]cdh];
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
  request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"locationAtHome.storedIn" ascending:YES], nil];
  [request setFetchBatchSize:50];
  self.frc = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:@"locationAtHome.storedIn" cacheName:Nil];
  self.frc.delegate = self;

}

#pragma mark - INTERACTION

- (IBAction)clear :(id)sender
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }
  CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate]cdh];
  NSFetchRequest *request = [cdh.model fetchRequestTemplateForName:@"ShoppingList"];
  NSArray *shoppingList = [cdh.context executeFetchRequest:request error:nil];

  if (shoppingList.count > 0)
  {
    self.clearConfirmActionSheet = [[UIActionSheet alloc]initWithTitle:@"Clear Entire Shopping List?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear" otherButtonTitles:nil];
    [self.clearConfirmActionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
  }
  else
  {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Nothing to Clear" message:@"Add Items to the Shop tab by tapping them on the Prepare tab.  Remove all Items from the Shop tab by clicking Clear on the Prepare tab" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
  }
  shoppingList = nil;
}

- (void)clearList
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  CoreDataHelper *cdh = [(AppDelegate *) [[UIApplication sharedApplication]delegate] cdh];
  NSFetchRequest *request = [cdh.model fetchRequestTemplateForName:@"ShoppingList"];
  NSArray *shoppingList = [cdh.context executeFetchRequest:request error:nil];

  for (Item *item in shoppingList)
  {
    item.listed = [NSNumber numberWithBool:NO];
  }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (BREADCRUMBS==1)
  {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
  }

  if (actionSheet == self.clearConfirmActionSheet)
  {
    if (buttonIndex == [actionSheet destructiveButtonIndex])
    {
      [self performSelector:@selector(clearList)];
    }
    else if (buttonIndex == [actionSheet cancelButtonIndex])
    {
      [actionSheet dismissWithClickedButtonIndex:[actionSheet cancelButtonIndex] animated:YES];
    }
  }
}
@end
