//
//  ILStaticTableDataSource.m
//  TableKit
//
//  Created by ∞ on 18/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ILStaticTableDataSource.h"

@implementation ILActionCell
@synthesize action;

- (NSString*) actionName;
{
	return NSStringFromSelector(self.action);
}

- (void) setActionName:(NSString *) s;
{
	self.action = NSSelectorFromString(s);
}

@end

@implementation ILStaticTableDataSource

- (id) initWithTableDescription:(NSDictionary*) desc target:(id) t;
{
	NSArray* cellsBySection = [desc objectForKey:@"Sections"];
	if (!cellsBySection)
		cellsBySection = [NSArray arrayWithObject:[desc objectForKey:@"Cells"]];
	
	NSMutableArray* content = [NSMutableArray array];
	NSMutableDictionary* keyeds = [NSMutableDictionary dictionary];
	
	for (NSArray* section in cellsBySection) {
		NSMutableArray* cells = [NSMutableArray array];
		for (NSDictionary* entry in section) {
			NSString* className = [entry objectForKey:@"class"];
			if (!className)
				className = @"ILActionCell";
			
			UITableViewCellStyle style = UITableViewCellStyleDefault;
			id styleObject = [entry objectForKey:@"style"];
			if (styleObject)
				style = (UITableViewCellStyle) [styleObject intValue];
			
			UITableViewCell* cell = [[[NSClassFromString(className) alloc] initWithStyle:style reuseIdentifier:nil] autorelease];
			
			for (NSString* key in entry) {
				if ([key isEqual:@"class"] || [key isEqual:@"style"] || [key isEqual:@"key"])
					continue;
				
				[cell setValue:[entry objectForKey:key] forKeyPath:key];
			}
			
			[cells addObject:cell];
			
			NSString* key = [entry objectForKey:@"key"];
			if (key)
				[keyeds setObject:cell forKey:key];
		}
		
		[content addObject:cells];
	}
	
	return [self initWithContent:content target:t];
}

- (id) initWithContent:(NSArray*) s keyedCells:(NSDictionary*) keyedCells target:(id) t;
{
	if (self = [super init]) {
		NSMutableArray* a = [NSMutableArray arrayWithCapacity:[s count]];
		for (NSArray* section in s)
			[a addObject:[[section copy] autorelease]];
		
		sections = [a copy];
		keyedCells = [keyedCells copy];
		
		target = t;
	}
	
	return self;
}

- (id) initWithTableDescriptionInResource:(NSString*) resource ofType:(NSString*) type bundle:(NSBundle*) b target:(id) t;
{
	if (!b)
		b = [NSBundle mainBundle];
	
	NSString* res = [b pathForResource:resource ofType:type];
	NSAssert(res, @"The resource must be present in the bundle!");
	
	NSDictionary* d = [NSDictionary dictionaryWithContentsOfFile:res];
	NSAssert(d, @"The resource must be a property list file containing a dictionary as the root!");
	
	return [self initWithTableDescription:d target:t];
}

@synthesize sections, target;

- (void) dealloc
{
	[sections release];
	[super dealloc];
}

// ~ ~ ~

#pragma mark -
#pragma mark Table data source methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView;
{
	return [sections count];
}

- (NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
	return [[sections objectAtIndex:section] count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	return [[sections objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
}

@end
