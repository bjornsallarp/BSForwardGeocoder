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
@synthesize coordinate = _coordinate;
@synthesize coordinateRegion = _coordinateRegion;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

- (id)initWithRegion:(MKCoordinateRegion)coordRegion 
{
	if ((self = [super init])) {
		_coordinate = coordRegion.center;
		_coordinateRegion = coordRegion;        
    }
	
	return self;
}

- (void)dealloc 
{
    [_title release];
    [_subtitle release];
	[super dealloc];
}
@end
