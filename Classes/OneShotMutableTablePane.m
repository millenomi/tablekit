//
//  OneShotMutableTablePane.m
//  TableKit
//
//  Created by ∞ on 17/02/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs) All rights reserved.
//

#import "OneShotMutableTablePane.h"


@implementation OneShotMutableTablePane

- (IBAction) mutate;
{
	static int i = 0;
	
	[self.dataSource beginUpdates];
	
	// These two are visible
	i++;
	[self.mutableContents addObject:[NSString stringWithFormat:@"%d", i]];
	[self.mutableContents removeObjectAtIndex:0];
	
	// This works, but isn't visible, because we're using ...OneShot as the binding style.
	i++;
	[self.mutableContents replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%d", i]];
	
	[self.dataSource endUpdates];
	
	NSLog(@"%@", self.contents);
}

@end