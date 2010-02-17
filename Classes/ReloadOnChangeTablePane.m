//
//  ReloadOnChangeTablePane.m
//  TableKit
//
//  Created by ∞ on 17/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ReloadOnChangeTablePane.h"
#import "ValuedObject.h"

@implementation ReloadOnChangeTablePane

- (void) viewDidLoad;
{
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
}

- (void) willCreateDataSource:(ILKVOTableDataSource *)ds;
{
	self.contents = [NSMutableArray arrayWithObjects:
					 [[ValuedObject new] autorelease],
					 [[ValuedObject new] autorelease],
					 [[ValuedObject new] autorelease],
					 [[ValuedObject new] autorelease],
					 [[ValuedObject new] autorelease],
					 nil];
	
	ds.editable = YES;
	
	ds.bindingStyle = kILKVOTableBindingReloadRowsOnChange;
	ds.bindings = [NSDictionary dictionaryWithObjectsAndKeys:
				   @"randomNumberString", @"textLabel.text",
				   nil];
}

- (IBAction) shuffle;
{
	[self.contents makeObjectsPerformSelector:@selector(updateRandomNumber)];
}

- (IBAction) add;
{
	[self.mutableContents addObject:[[ValuedObject new] autorelease]];
}

- (IBAction) pickActionFromSegmentedControl:(UISegmentedControl*) ctl;
{
	switch (ctl.selectedSegmentIndex) {
		case 0:
			[self add];
			break;
			
		case 1:
			[self shuffle];
			break;
			
		default:
			break;
	}
}

@end
