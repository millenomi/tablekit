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
	static unsigned char nameChar = 'A';
	
	self = [super init];
	if (self != nil) {
		label = [[NSString alloc] initWithFormat:@"%c", nameChar];
		nameChar++;
		
		[self updateRandomNumber];
	}
	return self;
}

- (void) dealloc
{
	[label release];
	[super dealloc];
}

- (NSString*) description;
{
	return [NSString stringWithFormat:@"%@ { label = %@ }", [super description], label];
}


@synthesize randomNumber;
- (NSString*) randomNumberString;
{
	return [NSString stringWithFormat:@"(%@) %ld", label, (long) randomNumber];
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
