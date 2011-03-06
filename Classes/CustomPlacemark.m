//
//  Created by Björn Sållarp on 2010-03-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "CustomPlacemark.h"


@implementation CustomPlacemark
@synthesize title, subtitle, coordinate, coordinateRegion;

-(id)initWithRegion:(MKCoordinateRegion) coordRegion {
	self = [super init];
	
	if (self != nil) {
		coordinate = coordRegion.center;
		coordinateRegion = coordRegion;
	}
	
	return self;
}

- (void)dealloc {
	[title release];
	[subtitle release];
	
	[super dealloc];
}
@end
