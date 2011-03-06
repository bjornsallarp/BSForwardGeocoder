//
//  Created by Björn Sållarp on 2010-03-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//


#import <Foundation/Foundation.h>
#import "BSGoogleV2KmlParser.h"
#import "BSGoogleV3KmlParser.h"

// Enum for geocoding status responses
enum {
	G_GEO_SUCCESS = 200,
	G_GEO_BAD_REQUEST = 400,
	G_GEO_SERVER_ERROR = 500,
	G_GEO_MISSING_QUERY = 601,
	G_GEO_UNKNOWN_ADDRESS = 602,
	G_GEO_UNAVAILABLE_ADDRESS = 603,
	G_GEO_UNKNOWN_DIRECTIONS = 604,
	G_GEO_BAD_KEY = 610,
	G_GEO_TOO_MANY_QUERIES = 620	
};

@class BSForwardGeocoder;

@protocol BSForwardGeocoderDelegate<NSObject>
@required
- (void)forwardGeocoderFoundLocation:(BSForwardGeocoder*)geocoder;
@optional
- (void)forwardGeocoderError:(BSForwardGeocoder*)geocoder errorMessage:(NSString *)errorMessage;
@end

@interface BSForwardGeocoder : NSObject {
	NSString *searchQuery;
	NSString *googleAPiKey;
	int status;
	NSArray *results;
	id<BSForwardGeocoderDelegate, NSObject> delegate;
}
-(id) initWithDelegate:(id<BSForwardGeocoderDelegate, NSObject>)del;
-(void) findLocation:(NSString *)searchString;

@property (assign) id<BSForwardGeocoderDelegate, NSObject> delegate;
@property (nonatomic, retain) NSString *searchQuery;
@property (nonatomic, readonly) int status;
@property (nonatomic, retain) NSArray *results;

@end
