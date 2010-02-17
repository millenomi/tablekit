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

- (void) willCreateDataSource:(ILKVOTableDataSource *)ds;
{
	self.contents = [NSMutableArray arrayWithObjects:
					 [[ValuedObject new] autorelease],
					 [[ValuedObject new] autorelease],
					 [[ValuedObject new] autorelease],
					 [[ValuedObject new] autorelease],
					 [[ValuedObject new] autorelease],
					 nil];
	
	ds.bindingStyle = kILKVOTableBindingReloadRowsOnChange;
	ds.bindings = [NSDictionary dictionaryWithObjectsAndKeys:
				   @"randomNumberString", @"textLabel.text",
				   nil];
}

- (IBAction) shuffle;
{
	[self.contents makeObjectsPerformSelector:@selector(updateRandomNumber)];
}

- (void) dataSource:(ILKVOTableDataSource *)ds willProduceCell:(UITableViewCell *)cell forObject:(id)o atIndex:(NSInteger)i;
{
	cell.textLabel.opaque = NO;
	cell.textLabel.backgroundColor = [UIColor clearColor];
}

@end
