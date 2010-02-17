//
//  L0Map.m
//  MuiKit
//
//  Created by ∞ on 12/09/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0Map.h"

static const void* ILRetain(CFAllocatorRef allocator, const void* value) {
	return [(id)value retain];
}

static void ILRelease(CFAllocatorRef allocator, const void* value) {
	[(id)value release];
}

static CFStringRef ILCopyDescription(const void* value) {
	NSString* s = [(id)value description];
	return (CFStringRef) [s copy];
}

static Boolean ILAreEqualPointers(const void* v1, const void* v2) {
	return v1 == v2;
}

static Boolean ILEquals(const void* v1, const void* v2) {
	return [(id)v1 isEqual:(id)v2];
}

static CFHashCode ILHash(const void *value) {
	return (CFHashCode) [(id)value hash];
}

@implementation L0Map

- (id) initWithKeyCallbacks:(const CFDictionaryKeyCallBacks*) kcbs valueCallbacks:(const CFDictionaryValueCallBacks*) vcbs;
{
	if (self = [super init])
		dict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, kcbs, vcbs);
	
	return self;
}


- (id) init;
{
	static const CFDictionaryKeyCallBacks keyCallbacks = {
		0,
		&ILRetain,
		&ILRelease,
		&ILCopyDescription,
		&ILAreEqualPointers,
		&ILHash
	};
	
	static const CFDictionaryValueCallBacks valueCallbacks = {
		0,
		&ILRetain,
		&ILRelease,
		&ILCopyDescription,
		&ILEquals
	};
	
	return [self initWithKeyCallbacks:&keyCallbacks valueCallbacks:&valueCallbacks];
}

- (void) dealloc;
{
	CFRelease(dict);
	[super dealloc];
}

+ map;
{
	return [[self new] autorelease];
}

#pragma mark -
#pragma mark Accessors

- (NSUInteger) count;
{
	return CFDictionaryGetCount(dict);
}

- (void) setObject:(id) o forKey:(id) k;
{
	[self setPointer:o forPointerKey:k];
}

- (id) objectForKey:(id) k;
{
	return (id) [self pointerForPointerKey:k];
}

- (void) removeObjectForKey:(id) k;
{
	[self removeObjectForPointerKey:k];
}

- (void) setPointer:(void*) o forPointerKey:(void*) k;
{
	CFDictionarySetValue(dict, k, o);
}

- (void*) pointerForPointerKey:(void*) k;
{
	return (void*) CFDictionaryGetValue(dict, k);
}

- (void) removeObjectForPointerKey:(void*) k;
{
	CFDictionaryRemoveValue(dict, (const void*) k);
}

- (void) removeAllObjects;
{
	CFDictionaryRemoveAllValues(dict);
}

- (void) getKeys:(void **)keys values:(void **)objects;
{
	CFDictionaryGetKeysAndValues(dict, (const void**) keys, (const void**) objects);
}

- (void) getEnumeratorForKeys:(NSEnumerator**) keysEnu values:(NSEnumerator**) valuesEnu;
{
	NSUInteger c = [self count];
	void** values = malloc(c * sizeof(void*));
	void** keys = malloc(c * sizeof(void*));
	
	[self getKeys:keys values:values];
	
	if (keysEnu) {
		NSArray* a = [NSArray arrayWithObjects:(const id*) keys count:c];
		*keysEnu = [a objectEnumerator];
	}

	if (valuesEnu) {
		NSArray* a = [NSArray arrayWithObjects:(const id*) values count:c];
		*valuesEnu = [a objectEnumerator];
	}
	
	free(keys);
	free(values);
}

- (NSEnumerator*) allValues;
{
	NSEnumerator* vals; [self getEnumeratorForKeys:NULL values:&vals];
	return vals;
}

- (NSEnumerator*) allKeys;
{
	NSEnumerator* vals; [self getEnumeratorForKeys:&vals values:NULL];
	return vals;
}

@end
