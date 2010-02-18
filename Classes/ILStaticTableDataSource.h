//
//  ILStaticTableDataSource.h
//  TableKit
//
//  Created by ∞ on 18/02/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ILStaticTableDataSource : NSObject <UITableViewDataSource> {
	NSArray* sections;
	id target;
	NSDictionary* keyedCells;
}

- (id) initWithTableDescriptionInResource:(NSString*) resource ofType:(NSString*) type bundle:(NSBundle*) b target:(id) target;

- (id) initWithContent:(NSArray*) sections keyedCells:(NSDictionary*) keyedCells target:(id) target;
- (id) initWithTableDescription:(NSDictionary*) desc target:(id) target;

@property(readonly) NSArray* sections;
@property(readonly) id target;
@property(readonly) NSDictionary* keyedCells;

- (id) cellForKey:(NSString*) name;

@end


@interface ILActionCell : UITableViewCell {
	SEL action;
}

@property(assign) SEL action;
@property(copy) NSString* actionName;

@end
