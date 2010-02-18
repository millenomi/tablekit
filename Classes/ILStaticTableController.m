//
//  ILStaticTableController.m
//  TableKit
//
//  Created by ∞ on 18/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ILStaticTableController.h"


@implementation ILStaticTableController

- (NSBundle*) tableBundle;
{
	return [NSBundle bundleForClass:[self class]];
}

- (NSString*) tableName;
{
	NSAssert(NO, @"Override this method to set the table name!");
	return nil;
}

- (Class) dataSourceClass;
{
	return [ILStaticTableDataSource class];
}

- (ILStaticTableDataSource *) dataSource;
{
	if (!dataSource) {
		ILStaticTableDataSource* d = [[[self dataSourceClass] alloc] initWithTableDescriptionInResource:self.tableName ofType:@"table" bundle:self.tableBundle target:self];
		[self didCreateDataSource:d];
		self.dataSource = d;
	}
	
	return dataSource;
}

- (void) setDataSource:(ILStaticTableDataSource *) d;
{
	if (dataSource != d) {
		self.tableView.dataSource = nil;
		[dataSource release];
		dataSource = [d retain];
		self.tableView.dataSource = d;
	}
}

- (void) updateTableDataSource;
{
	self.tableView.dataSource = self.dataSource;
}

- (void) viewDidLoad;
{
	[super viewDidLoad];
	[self updateTableDataSource];
}

- (void) didCreateDataSource:(ILStaticTableDataSource*) ds;
{
	// Overridden by subclasses.
}

- (void) deselectAnimated:(BOOL) a;
{
	NSIndexPath* p = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:p animated:a];
}

- (void) deselect;
{
	[self deselectAnimated:YES];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
	id cell = [tableView cellForRowAtIndexPath:indexPath];
	if ([cell isKindOfClass:[ILActionCell class]] && [cell action])
		[self.dataSource.target performSelector:[cell action] withObject:cell];
}

@end

