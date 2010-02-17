//
//  ILKVOTableController.m
//  TableKit
//
//  Created by ∞ on 17/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ILKVOTableController.h"


@implementation ILKVOTableController

@synthesize bindings, contents;

- (void) dealloc
{
	[contents release];
	[bindings release];
	[super dealloc];
}

- (void) viewDidLoad;
{
	[super viewDidLoad];	
	self.tableView.dataSource = self.dataSource;
}

- (void) viewDidUnload;
{
	[super viewDidUnload];
	self.dataSource = nil;
}


- (Class) dataSourceClass;
{
	return [ILKVOTableDataSource class];
}

- (ILKVOTableDataSource *) dataSource;
{
	if (!dataSource) {
		ILKVOTableDataSource* d = [[[self dataSourceClass] alloc] initWithTableView:self.tableView];
		d.boundObject = self;
		d.keyPath = @"contents";
		d.bindings = self.bindings;
		d.delegate = self;
		[self willCreateDataSource:d];
		self.dataSource = d;
	}
	
	return dataSource;
}

- (void) setDataSource:(ILKVOTableDataSource *) d;
{
	if (dataSource != d) {
		self.tableView.dataSource = nil;
		[dataSource release];
		dataSource = [d retain];
		self.tableView.dataSource = d;
	}
}


- (NSMutableArray*) contents;
{
	if (!contents)
		contents = [NSMutableArray new];
	
	return contents;
}
- (void) setContents:(NSMutableArray *) c;
{
	if (c != contents) {
		[contents release];
		contents = [c mutableCopy];
	}
}
- (NSMutableArray*) mutableContents;
{
	return [self mutableArrayValueForKey:@"contents"];
}

- (NSDictionary*) bindings;
{
	if (!bindings)
		bindings = [NSDictionary new];
	
	return bindings;
}

- (void) willCreateDataSource:(ILKVOTableDataSource *)dataSource;
{
	// overridden by subclasses
}

@end

