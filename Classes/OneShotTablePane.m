//
//  OneShotTablePane.m
//  TableKit
//
//  Created by ∞ on 17/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "OneShotTablePane.h"

@implementation OneShotTablePane

- (void) willCreateDataSource:(ILKVOTableDataSource *) ds;
{
	self.contents = [NSArray arrayWithObjects:
					 @"A", @"B", @"C", @"D", @"E", nil];
	
	ds.bindings = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"self", @"textLabel.text",
						   nil];
}

@end

