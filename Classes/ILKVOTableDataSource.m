//
//  ILTableViewDataSource.m
//  Tables
//
//  Created by ∞ on 15/02/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs) All rights reserved.
//

#import "ILKVOTableDataSource.h"

static int ILKVOTableDataSourceUniqueVarA = 0, ILKVOTableDataSourceUniqueVarB = 0;

static void* ILKVOTableDataSource_BoundObjectContext = &ILKVOTableDataSourceUniqueVarA;
static void* ILKVOTableDataSource_ModelObjectContext = &ILKVOTableDataSourceUniqueVarB;


@interface ILKVOTableDataSource ()
- (void) beginObserving;
- (void) endObserving;

- (NSIndexSet*) indexSetForObject:(id) o;
- (void) addIndex:(NSInteger) row forObject:(id) o;
- (void) removeIndex:(NSInteger) row forObject:(id) o;

- (void) handleCollectionChange:(NSKeyValueChange) c atIndexes:(NSIndexSet*) indexes newObjects:(NSArray*) newOnes oldObjects:(NSArray*) oldOnes;

@property(readonly) BOOL isOneShot;
@end


@implementation ILKVOTableDataSource

#pragma mark -
#pragma mark Constructors and setters

- (id) initWithTableView:(UITableView *)tv;
{
	self = [super init]; if (!self) return nil;
	
	tableView = [tv retain];
	cellClass = [UITableViewCell class];
	[self setAnimation:UITableViewRowAnimationFade];
	objectsToRows = [L0Map new];
	return self;
}

@synthesize delegate;
@synthesize boundObject, keyPath, cellClass, bindings;
@synthesize insertionAnimation, deletionAnimation;
@synthesize bindingStyle;

- (void) dealloc;
{
	if (tableView.dataSource == self)
		tableView.dataSource = nil;
	
	[self endObserving];
	[keyPath release];
	[bindings release];
	
	[addedIndexes release];
	[removedIndexes release];
	[replacedIndexes release];
	
	[objectsToRows release];
	
	[tableView release];
	
	[super dealloc];
}

- (void) setBoundObject:(id) o;
{
	if (o != boundObject) {
		[self endObserving];
		boundObject = o;
		[self beginObserving];
	}
}

- (void) setBindingStyle:(ILKVOTableBindingStyle) s;
{
	[self endObserving];
	bindingStyle = s;
	[self beginObserving];
}

- (void) setKeyPath:(NSString*) s;
{
	if (s != keyPath) {
		[self endObserving];
		[keyPath release];
		keyPath = [s copy];
		[self beginObserving];
	}
}

- (void) setCellClass:(Class) c;
{
	if (!c)
		c = [UITableViewCell class];
	
	cellClass = c;
}

- (void) setAnimation:(UITableViewRowAnimation) a;
{
	self.insertionAnimation = a;
	self.deletionAnimation = a;
}

- (void) setBindings:(NSDictionary*) d;
{
	if (d != bindings) {
		[self endObserving];
		[bindings release];
		bindings = [d copy];
		[self beginObserving];
	}
}

#pragma mark -
#pragma mark KVO tools

- (void) beginObserving;
{
	[objectsToRows removeAllObjects];
	
	if (self.boundObject && self.keyPath) {
		NSKeyValueObservingOptions styleOptions = 0;
		if (!self.isOneShot)
			styleOptions = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
		
		[self.boundObject addObserver:self forKeyPath:self.keyPath options:NSKeyValueObservingOptionInitial|styleOptions context:ILKVOTableDataSource_BoundObjectContext];
	}
	
	if (!self.isOneShot) {
		for (NSString* key in self.bindings) {
			NSMutableArray* a = [self.boundObject mutableArrayValueForKey:self.keyPath];
			[a addObserver:self toObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [a count])] forKeyPath:[self.bindings objectForKey:key] options:0 context:ILKVOTableDataSource_ModelObjectContext];
		}
	}
	
	[tableView reloadData];
}

- (BOOL) isOneShot;
{
	ILKVOTableBindingStyle style = self.bindingStyle;
	return style == kILKVOTableBindingOneShot || style == kILKVOTableBindingOneShotReloadRowsOnReplace;
}

- (void) endObserving;
{
	[objectsToRows removeAllObjects];
	
	if (self.boundObject && self.keyPath) {
		NSMutableArray* a = [self.boundObject mutableArrayValueForKey:self.keyPath];
		
		if (!self.isOneShot) {
			for (NSString* key in self.bindings) {
				[a removeObserver:self fromObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [a count])] forKeyPath:[self.bindings objectForKey:key]];
			}
		}
		 
		[self.boundObject removeObserver:self forKeyPath:self.keyPath];
	}
	
	[tableView reloadData];
}

- (void) observeValueForKeyPath:(NSString*) objectKeyPath ofObject:(id) object change:(NSDictionary*) change context:(void*) context;
{
	NSLog(@"%@", change);
	
	if (context == ILKVOTableDataSource_BoundObjectContext)
		[self handleCollectionChange:[[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue] atIndexes:[change objectForKey:NSKeyValueChangeIndexesKey] newObjects:[change objectForKey:NSKeyValueChangeNewKey] oldObjects:[change objectForKey:NSKeyValueChangeOldKey]];
	else if (context == ILKVOTableDataSource_ModelObjectContext) {
		
		switch (self.bindingStyle) {
			case kILKVOTableBindingReloadRowsOnChange: {
				NSIndexSet* is = [self indexSetForObject:object];
				if (is) {
					NSMutableArray* rows = [NSMutableArray array];
					NSInteger i = [is firstIndex];
					while (i != NSNotFound) {
						[rows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
						i = [is indexGreaterThanIndex:i];
					}
					
					[tableView reloadRowsAtIndexPaths:rows withRowAnimation:self.insertionAnimation];
				}
			}
			break;
				
			case kILKVOTableBindingReapplyOnChangeOneWay: {
				NSIndexSet* is = [self indexSetForObject:object];
				NSMutableArray* cells = nil;
				if (is) {
					cells = [NSMutableArray array];
					NSInteger i = [is firstIndex];
					while (i != NSNotFound) {
						NSIndexPath* rowPath = [NSIndexPath indexPathForRow:i inSection:0];
						UITableViewCell* cell = [tableView cellForRowAtIndexPath:rowPath];
						if (cell)
							[cells addObject:cell];
						
						i = [is indexGreaterThanIndex:i];
					}
				}
				
				if (cells) {
					id value = [object valueForKey:objectKeyPath];
					for (NSString* cellKey in self.bindings) {
						if ([[self.bindings objectForKey:cellKey] isEqual:objectKeyPath]) {
							for (id cell in cells)
								[cell setValue:value forKey:cellKey];
						}
					}
				}
			}
			break;
		}
	}
}

- (NSIndexSet*) indexSetForObject:(id) o;
{
	return [objectsToRows objectForKey:o];
}

- (void) addIndex:(NSInteger) row forObject:(id) o;
{
	NSMutableIndexSet* is = [objectsToRows objectForKey:o];
	if (!is) {
		is = [NSMutableIndexSet indexSet];
		[objectsToRows setObject:is forKey:o];
	}
	
	[is addIndex:row];
}

- (void) removeIndex:(NSInteger) row forObject:(id) o;
{
	NSMutableIndexSet* is = [objectsToRows objectForKey:o];
	[is removeIndex:row];
	
	if (is && [is count] == 0)
		[objectsToRows removeObjectForKey:o];
}

- (void) handleCollectionChange:(NSKeyValueChange) c atIndexes:(NSIndexSet*) indexes newObjects:(NSArray*) newOnes oldObjects:(NSArray*) oldOnes;
{	
	if (c == NSKeyValueChangeSetting) {
		NSAssert(editingCalls == 0, @"You cannot use set changes while grouping changes with beginUpdates/endUpdates!");
		[tableView reloadData];
		return;
	}
	
	if (c == NSKeyValueChangeReplacement) {
		[self beginUpdates];
		
		[replacedIndexes addIndexes:indexes];
		
		if (!self.isOneShot) {
			NSInteger i = [indexes firstIndex], count = [indexes count], j;
			for (j = 0; j < count; j++) {
				id n = [newOnes objectAtIndex:j];
				id o = [oldOnes objectAtIndex:j];
				
				[self addIndex:i forObject:n];
				[self removeIndex:i forObject:o];
				
				i = [indexes indexGreaterThanIndex:i];
			}
		}
		
		[self endUpdates];		
	} else if (c == NSKeyValueChangeRemoval) {
		[self beginUpdates];
		
		NSInteger i = [indexes firstIndex], j = 0;
		
		while (i != NSNotFound) {
			[removedIndexes addIndex:i];
			[addedIndexes shiftIndexesStartingAtIndex:i by:(-1)];
			[replacedIndexes shiftIndexesStartingAtIndex:i by:(-1)];
			
			if (!self.isOneShot)
				[self removeIndex:i forObject:[newOnes objectAtIndex:j]];
			
			i = [indexes indexGreaterThanIndex:i];
			j++;
		}
		
		[self endUpdates];
	} else if (c == NSKeyValueChangeInsertion) {
		[self beginUpdates];
		
		NSInteger i = [indexes firstIndex], j = 0;
		
		while (i != NSNotFound) {
			[addedIndexes addIndex:i];
			[replacedIndexes shiftIndexesStartingAtIndex:i by:(1)];
			
			if (!self.isOneShot)
				[self addIndex:i forObject:[oldOnes objectAtIndex:j]];
			
			i = [indexes indexGreaterThanIndex:i];
			j++;
		}
		
		[self endUpdates];
	}
}

#pragma mark -
#pragma mark Data source methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView;
{
	return 1;
}

- (NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
	if (!boundObject || !keyPath)
		return 0;
	
	return [[boundObject mutableArrayValueForKeyPath:keyPath] count];
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
#define kILTableViewDataSourceReuseIdentifier @"cell"
	
	UITableViewCell* cell = [tv dequeueReusableCellWithIdentifier:kILTableViewDataSourceReuseIdentifier];
	if (!cell)
		cell = [[[self.cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kILTableViewDataSourceReuseIdentifier] autorelease];
	
	id object = nil;
	
	if (boundObject && keyPath)
		object = [[boundObject mutableArrayValueForKeyPath:keyPath] objectAtIndex:[indexPath row]];
	
	for (NSString* cellKeyPath in self.bindings) {
		NSString* objectKeyPath = [self.bindings objectForKey:cellKeyPath];
		id value = [object valueForKeyPath:objectKeyPath];
		[cell setValue:value forKeyPath:cellKeyPath];
	}
	
	if ([delegate respondsToSelector:@selector(dataSource:willProduceCell:forObject:atIndex:)])
		[delegate dataSource:self willProduceCell:cell forObject:object atIndex:[indexPath row]];
	
	return cell;
}

#pragma mark -
#pragma mark Grouping

- (void) beginUpdates;
{
	editingCalls++;
	if (editingCalls == 1) {
		[tableView beginUpdates];
		
		addedIndexes = [NSMutableIndexSet new];
		removedIndexes = [NSMutableIndexSet new];
		
		if (self.bindingStyle != kILKVOTableBindingOneShot)
			replacedIndexes = [NSMutableIndexSet new];
	}
}

- (void) endUpdates;
{
	editingCalls--;
	if (editingCalls < 0) {
		NSLog(@"[ILKVOTableDataSource %@]: I found an -endUpdates call without a paired -beginUpdates call! What's going on?", self);
		editingCalls = 0;
	} else if (editingCalls == 0) {
		
		NSInteger i; 
		NSMutableArray* paths;

		// remove all the deleted rows...
		i = [removedIndexes firstIndex];
		paths = [NSMutableArray array];
		while (i != NSNotFound) {
			[paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
			i = [removedIndexes indexGreaterThanIndex:i];
		}
		
		[tableView deleteRowsAtIndexPaths:paths withRowAnimation:self.deletionAnimation];
		
		// ... then add all the new ones...
		i = [addedIndexes firstIndex];
		paths = [NSMutableArray array];
		while (i != NSNotFound) {
			[paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
			i = [addedIndexes indexGreaterThanIndex:i];
		}
		
		[tableView insertRowsAtIndexPaths:paths withRowAnimation:self.insertionAnimation];
		
		
		[tableView endUpdates];
		
		if (replacedIndexes) {
			// ... and finally reload all replaced ones!
			i = [replacedIndexes firstIndex];
			paths = [NSMutableArray array];
			while (i != NSNotFound) {
				[paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
				i = [replacedIndexes indexGreaterThanIndex:i];
			}
			
			[tableView reloadRowsAtIndexPaths:paths withRowAnimation:self.insertionAnimation];
		}
		
		[addedIndexes release];
		[removedIndexes release];
		[replacedIndexes release];
	}
}

@end
