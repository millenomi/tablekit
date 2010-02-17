//
//  OneShotMutableReloadTablePane.m
//  TableKit
//
//  Created by ∞ on 17/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "OneShotMutableReloadTablePane.h"


@implementation OneShotMutableReloadTablePane

// This should make the replace swap done silently by the superclass visible.

- (void) willCreateDataSource:(ILKVOTableDataSource *)ds;
{
	[super willCreateDataSource:ds];	
	ds.bindingStyle = kILKVOTableBindingOneShotReloadRowsOnReplace;
}

@end

