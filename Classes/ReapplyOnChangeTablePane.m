//
//  ReapplyOnChangeTablePane.m
//  TableKit
//
//  Created by ∞ on 17/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ReapplyOnChangeTablePane.h"


@implementation ReapplyOnChangeTablePane

- (void) willCreateDataSource:(ILKVOTableDataSource *)ds;
{
	[super willCreateDataSource:ds];
	
	ds.bindingStyle = kILKVOTableBindingReapplyOnChangeOneWay;
}

@end
