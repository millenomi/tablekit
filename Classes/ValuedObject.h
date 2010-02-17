//
//  ValuedObject.h
//  TableKit
//
//  Created by ∞ on 17/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ValuedObject : NSObject {
	long randomNumber;
}

@property(readonly) long randomNumber;
@property(readonly) NSString* randomNumberString;

- (void) updateRandomNumber;

@end
