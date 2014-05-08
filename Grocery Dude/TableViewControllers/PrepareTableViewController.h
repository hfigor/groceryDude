//
//  PrepareTableViewController.h
//  Grocery Dude
//
//  Created by Frank Cipolla on 3/3/14.
//  Copyright (c) 2014 Frank Cipolla. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface PrepareTableViewController : CoreDataTableViewController
<UIActionSheetDelegate>

@property (strong, nonatomic) UIActionSheet * clearConfirmActionSheet;

@end
