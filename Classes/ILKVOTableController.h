//
//  ILKVOTableController.h
//  TableKit
//
//  Created by ∞ on 17/02/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs) All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILKVOTableDataSource.h"

@interface ILKVOTableController : UITableViewController <ILKVOTableDataSourceDelegate> {
@private
	ILKVOTableDataSource* dataSource;
	NSDictionary* bindings;
	NSMutableArray* contents;
}

@property(retain) ILKVOTableDataSource* dataSource;

@property(copy) NSMutableArray* contents;
@property(copy) NSDictionary* bindings;

// This one is a shortcut to mutableArrayValueForKey:@"contents"
@property(readonly) NSMutableArray* mutableContents;

- (void) willCreateDataSource:(ILKVOTableDataSource*) ds;

@end
