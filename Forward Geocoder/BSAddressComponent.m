//
//  Created by Björn Sållarp on 2010-03-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "BSAddressComponent.h"


@implementation BSAddressComponent
@synthesize shortName = _shortName;
@synthesize longName = _longName;
@synthesize types = _types;

- (void)dealloc
{
	[_shortName release];
	[_longName release];
	[_types release];
	[super dealloc];
}
@end
