//
//  ILStaticTableController.h
//  TableKit
//
//  Created by ∞ on 18/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILStaticTableDataSource.h"

@interface ILStaticTableController : UITableViewController {
	ILStaticTableDataSource* dataSource;
}

@property(retain) ILStaticTableDataSource* dataSource;
- (void) updateTableDataSource;
- (void) didCreateDataSource:(ILStaticTableDataSource*) ds;

@property(readonly) NSString* tableName; // MUST be overridden by a subclass!
@property(readonly) NSBundle* tableBundle;

- (void) deselectAnimated:(BOOL) a;
- (void) deselect;

@end
