//
//  OneShotEditableReloadTablePane.m
//  TableKit
//
//  Created by ∞ on 17/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "OneShotEditableReloadTablePane.h"


@implementation OneShotEditableReloadTablePane

- (void) viewDidLoad;
{
	[super viewDidLoad];
	self.navigationItem.leftBarButtonItem = [self editButtonItem];
}

- (void) willCreateDataSource:(ILKVOTableDataSource *)ds;
{
	[super willCreateDataSource:ds];
	ds.editable = YES;
}

@end

