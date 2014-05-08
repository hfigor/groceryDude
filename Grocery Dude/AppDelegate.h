//
//  AppDelegate.h
//  Grocery Dude
//
//  Created by Frank Cipolla on 1/31/14.
//  Copyright (c) 2014 Frank Cipolla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) CoreDataHelper *coreDataHelper;

-(CoreDataHelper *)cdh;
@end
