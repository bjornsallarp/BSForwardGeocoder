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
#import <MapKit/MapKit.h>
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
	G_GEO_TOO_MANY_QUERIES = 620,
    G_GEO_NETWORK_ERROR = 900
};

#if NS_BLOCKS_AVAILABLE
typedef void (^BSForwardGeocoderSuccess) (NSArray* results);
typedef void (^BSForwardGeocoderFailed) (int status, NSString* errorMessage);
#endif

@class BSForwardGeocoder;

@protocol BSForwardGeocoderDelegate<NSObject>
@required
- (void)forwardGeocodingDidSucceed:(BSForwardGeocoder *)geocoder withResults:(NSArray *)results;
@optional
- (void)forwardGeocoderConnectionDidFail:(BSForwardGeocoder *)geocoder withErrorMessage:(NSString *)errorMessage;
- (void)forwardGeocodingDidFail:(BSForwardGeocoder *)geocoder withErrorCode:(int)errorCode andErrorMessage:(NSString *)errorMessage;
@end

@interface BSForwardGeocoderCoordinateBounds : NSObject
- (id)initWithSouthWest:(CLLocationCoordinate2D)southwest northEast:(CLLocationCoordinate2D)northeast;
+ (BSForwardGeocoderCoordinateBounds *)boundsWithSouthWest:(CLLocationCoordinate2D)southwest northEast:(CLLocationCoordinate2D)northeast;
@property (nonatomic, assign) CLLocationCoordinate2D southwest;
@property (nonatomic, assign) CLLocationCoordinate2D northeast;
@end

@interface BSForwardGeocoder : NSObject <NSURLConnectionDataDelegate>
- (id)initWithDelegate:(id<BSForwardGeocoderDelegate>)aDelegate;
- (void)forwardGeocodeWithQuery:(NSString *)searchQuery regionBiasing:(NSString *)regionBiasing viewportBiasing:(BSForwardGeocoderCoordinateBounds *)viewportBiasing;

#if NS_BLOCKS_AVAILABLE
- (void)forwardGeocodeWithQuery:(NSString *)searchQuery regionBiasing:(NSString *)regionBiasing viewportBiasing:(BSForwardGeocoderCoordinateBounds *)viewportBiasing success:(BSForwardGeocoderSuccess)success failure:(BSForwardGeocoderFailed)failure;
#endif

@property (nonatomic, assign) id<BSForwardGeocoderDelegate> delegate;
@property (nonatomic, assign) BOOL useHTTP;

@end
