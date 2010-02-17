//
//  TableKitAppDelegate.m
//  TableKit
//
//  Created by ∞ on 17/02/10.
//  Copyright Emanuele Vulcano (Infinite Labs)2010. All rights reserved.
//

#import "TableKitAppDelegate.h"

@implementation TableKitAppDelegate


- (BOOL) application:(UIApplication*) application didFinishLaunchingWithOptions:(NSDictionary*) launchOptions;
{

	[window addSubview:mainViewController.view];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void) dealloc;
{
    [window release];
	[mainViewController release];
    [super dealloc];
}


@end
