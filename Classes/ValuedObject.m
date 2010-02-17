//
//  ValuedObject.m
//  TableKit
//
//  Created by ∞ on 17/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ValuedObject.h"


@implementation ValuedObject

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self updateRandomNumber];
	}
	return self;
}

@synthesize randomNumber;
- (NSString*) randomNumberString;
{
	return [NSString stringWithFormat:@"%ld", (long) randomNumber];
}
- (NSSet*) keyPathsForValuesAffectingRandomNumberString;
{
	return [NSSet setWithObject:@"randomNumber"];
}

- (void) updateRandomNumber;
{
	[self willChangeValueForKey:@"randomNumber"];
	[self willChangeValueForKey:@"randomNumberString"];
	srandomdev();
	randomNumber = random();
	[self didChangeValueForKey:@"randomNumberString"];
	[self didChangeValueForKey:@"randomNumber"];
}

@end
