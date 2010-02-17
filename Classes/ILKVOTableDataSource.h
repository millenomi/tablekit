//
//  ILTableViewDataSource.h
//  Tables
//
//  Created by ∞ on 15/02/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs) All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
	/* Use the bindings in .bindings only at cell creation time.
	 Changing the model object will not affect the cell.
	 Default.
	 */
	kILKVOTableBindingOneShot = 0,
	
	/* Same as above, but if you replace an object, the
	 corresponding row will be reloaded. This is just
	 like kILKVOTableBindingReloadRowsOnChange, but
	 it works without having to observe objects in the
	 array.
	 */
	kILKVOTableBindingOneShotReloadRowsOnReplace,
	
	/* -- Constants below are expensive, and
	 require the whole object graph to be available in memory. 
	 (You can avoid that for the above two constants by
	 implementing KVC accessor methods for the observed
	 key path.) --
	 */
	
	/* Reload the corresponding rows whenever a model object
	 changes.
	 This creates an entirely new cell for each affected
	 row; if onscreen, the .insertionAnimation will be
	 used to animate the change.
	 
	 Example: the Wi-Fi networks list in Settings.
	 */
	kILKVOTableBindingReloadRowsOnChange,
	
	/* Whenever an object's bound key paths change, and the
	 corresponding cell is displayed, alter the bound key
	 paths on the cell again so that they match.
	 This is one-way; altering the cell will not change
	 the model object.
	 
	 Example: the downloads list in the iTunes (store) app.
	 */
	kILKVOTableBindingReapplyOnChangeOneWay,
};
typedef NSInteger ILKVOTableBindingStyle;

@class ILKVOTableDataSource;

@protocol ILKVOTableDataSourceDelegate <NSObject>
@optional

- (void) dataSource:(ILKVOTableDataSource*) ds willProduceCell:(UITableViewCell*) cell forObject:(id) o atIndex:(NSInteger) i;

@end


@interface ILKVOTableDataSource : NSObject <UITableViewDataSource> {
	UITableView* tableView;
	
	id boundObject;
	NSString* keyPath;
	Class cellClass;
	NSDictionary* bindings;
	
	UITableViewRowAnimation insertionAnimation;
	UITableViewRowAnimation deletionAnimation;
	
	NSInteger editingCalls;
	
	NSMutableIndexSet* addedIndexes, * removedIndexes, * replacedIndexes;
	
	ILKVOTableBindingStyle bindingStyle;
	
	id <ILKVOTableDataSourceDelegate> delegate;
	
	BOOL editable;
}

- (id) initWithTableView:(UITableView*) tv;

@property(assign) id <ILKVOTableDataSourceDelegate> delegate;

// This must be an ordered property. Each object will be used
// to construct a single cell (see below).
@property(assign) id boundObject;
@property(copy) NSString* keyPath;

// Default is UITableViewCell.
@property(assign) Class cellClass;

/*
 Each entry of the dictionary maps a key path of the cell
 to a key path from the bound objects array. For example:
 
	{ @"textLabel.text" => @"title" }
 
 will cause each cell's textLabel.text to be set to the
 corresponding object's title key.
 */
@property(copy) NSDictionary* bindings;

// Set all animations.
- (void) setAnimation:(UITableViewRowAnimation) a;

// Both default to UITableViewRowAnimationFade.
@property UITableViewRowAnimation insertionAnimation;
@property UITableViewRowAnimation deletionAnimation;

// Binding style. See the constants for this type for details.
@property ILKVOTableBindingStyle bindingStyle;

/* Call these if you want to group updates done to the keyPath.

 WARNING: do NOT call these methods if you modify the key
 wholesale (via setting: setValue:forKey:, or setKey:blah, or
 anything else that causes a NSKeyValueChangeSetting), as these
 require a full table reload. For now. Insertion, removal and
 replacement are fine.
 
 Unlike the UITableView counterparts, you CAN nest calls to these
 methods. The last endUpdates will behave like endUpdates on the
 table.
 */
- (void) beginUpdates;
- (void) endUpdates;


/* If YES, editing will be allowed on all rows. Only deletion
 is supported, and will cause the object to be removed from
 the watched key path (which must be mutable).
 
 Default is NO.
 */
@property BOOL editable;

@end
