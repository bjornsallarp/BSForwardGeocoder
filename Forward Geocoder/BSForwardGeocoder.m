//
//  Created by Björn Sållarp on 2010-03-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "BSForwardGeocoder.h"

@interface BSForwardGeocoder ()
@property (nonatomic, retain) NSURLConnection *geocodeConnection;
@property (nonatomic, retain) NSMutableData *geocodeConnectionData;
#if NS_BLOCKS_AVAILABLE
@property (nonatomic, copy) BSForwardGeocoderSuccess successBlock;
@property (nonatomic, copy) BSForwardGeocoderFailed failureBlock;
#endif
@end

@implementation BSForwardGeocoder
@synthesize geocodeConnection = _geocodeConnection;
@synthesize geocodeConnectionData = _geocodeConnectionData;
@synthesize delegate = _delegate;
@synthesize useHTTP = _useHTTP;

#if NS_BLOCKS_AVAILABLE
@synthesize successBlock = _successBlock;
@synthesize failureBlock = _failureBlock;
#endif

- (void)dealloc
{    
#if NS_BLOCKS_AVAILABLE    
    [_successBlock release];
    [_failureBlock release];
#endif
    
    [self.geocodeConnection cancel];    
    [_geocodeConnection release];
    [_geocodeConnectionData release];
    
	[super dealloc];
}

- (id)initWithDelegate:(id<BSForwardGeocoderDelegate>)aDelegate
{
	if ((self = [super init])) {
		_delegate = aDelegate;
	}
	return self;
}

// Use Core Foundation method to URL-encode strings, since -stringByAddingPercentEscapesUsingEncoding:
// doesn't do a complete job. This code is copied from AFNetworking
- (NSString *)URLEncodedString:(NSString *)string
{
    static NSString * const kBSGeocodingLegalCharactersToBeEscaped = @"?!@#$^&%*+=,:;'\"`<>()[]{}/\\|~ ";
    
	return [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, (CFStringRef)kBSGeocodingLegalCharactersToBeEscaped, kCFStringEncodingUTF8) autorelease];
}

- (void)forwardGeocodeWithQuery:(NSString *)searchQuery regionBiasing:(NSString *)regionBiasing viewportBiasing:(BSForwardGeocoderCoordinateBounds *)viewportBiasing
{
    if (self.geocodeConnection) {
        [self.geocodeConnection cancel];
    }
    
    // Create the url object for our request. It's important to escape the 
    // search string to support spaces and international characters
    NSString *geocodeUrl = [NSString stringWithFormat:@"%@://maps.google.com/maps/api/geocode/xml?address=%@&sensor=false", self.useHTTP ? @"http" : @"https", [self URLEncodedString:searchQuery]];
    
    if (regionBiasing && ![regionBiasing isEqualToString:@""]) {
        geocodeUrl = [geocodeUrl stringByAppendingFormat:@"&region=%@", regionBiasing];
    }
    
    if (viewportBiasing) {
        NSString *boundsString = [NSString stringWithFormat:@"%f,%f|%f,%f", viewportBiasing.southwest.latitude, viewportBiasing.southwest.longitude, viewportBiasing.northeast.latitude, viewportBiasing.northeast.longitude];
        
        // We need to escape the parameters
        geocodeUrl = [geocodeUrl stringByAppendingFormat:@"&bounds=%@", [self URLEncodedString:boundsString]];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:geocodeUrl] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0];
    self.geocodeConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

#if NS_BLOCKS_AVAILABLE
- (void)forwardGeocodeWithQuery:(NSString *)location regionBiasing:(NSString *)regionBiasing viewportBiasing:(BSForwardGeocoderCoordinateBounds *)viewportBiasing success:(BSForwardGeocoderSuccess)success failure:(BSForwardGeocoderFailed)failure
{
    self.successBlock = success;
    self.failureBlock = failure;
    [self forwardGeocodeWithQuery:location regionBiasing:regionBiasing viewportBiasing:viewportBiasing];
}
#endif

- (void)parseGeocodeResponseWithData:(NSData *)responseData
{
	NSError *parseError = nil;
	
    // Run the KML parser
    BSGoogleV3KmlParser *parser = [[BSGoogleV3KmlParser alloc] init];
    [parser parseXMLData:responseData parseError:&parseError ignoreAddressComponents:NO];
	
    BOOL handeledByBlocks = NO;
    
#if NS_BLOCKS_AVAILABLE
    if (self.successBlock && parser.statusCode == G_GEO_SUCCESS) {
        self.successBlock(parser.results);
        handeledByBlocks = YES;
    }
    else if (self.failureBlock) {
        self.failureBlock(parser.statusCode, [parseError localizedDescription]);
        handeledByBlocks = YES;
    }
#endif
	
    if (!handeledByBlocks && self.delegate) {
        if (!parseError && parser.statusCode == G_GEO_SUCCESS) {
            [self.delegate forwardGeocodingDidSucceed:self withResults:parser.results];
        }
        else if ([self.delegate respondsToSelector:@selector(forwardGeocoderDidFail:withErrorMessage:)]) {
            [self.delegate forwardGeocodingDidFail:self withErrorCode:parser.statusCode andErrorMessage:[parseError localizedDescription]];
        }        
    }
    
    [parser release];
}

- (void)geocoderConnectionFailedWithErrorMessage:(NSString *)errorMessage
{
    BOOL handeledByBlocks = NO;
    
#if NS_BLOCKS_AVAILABLE
    if (self.failureBlock) {
        self.failureBlock(G_GEO_NETWORK_ERROR, errorMessage);
        handeledByBlocks = YES;
    }
    else if (self.delegate && [self.delegate respondsToSelector:@selector(forwardGeocoderConnectionDidFail:withErrorMessage:)]) {
        [self.delegate forwardGeocoderConnectionDidFail:self withErrorMessage:errorMessage];
        handeledByBlocks = YES;
    }
#endif
    
    if (!handeledByBlocks && self.delegate && [self.delegate respondsToSelector:@selector(forwardGeocoderConnectionDidFail:withErrorMessage:)]) {
        [self.delegate forwardGeocoderConnectionDidFail:self withErrorMessage:errorMessage];
    }

    self.geocodeConnectionData = nil;
    self.geocodeConnection = nil;
}

#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    if (response.statusCode != 200) {
        [self.geocodeConnection cancel];
        [self geocoderConnectionFailedWithErrorMessage:@"Google returned an invalid status code"];
    }
    else {
        self.geocodeConnectionData = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.geocodeConnectionData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self geocoderConnectionFailedWithErrorMessage:[error localizedDescription]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.geocodeConnection = nil;    
    [self parseGeocodeResponseWithData:self.geocodeConnectionData];
    self.geocodeConnectionData = nil;
}

@end

@implementation BSForwardGeocoderCoordinateBounds
@synthesize southwest = _southwest;
@synthesize northeast = _northeast;

- (id)initWithSouthWest:(CLLocationCoordinate2D)southwest northEast:(CLLocationCoordinate2D)northeast
{
    if ((self = [super init])) {
        self.southwest = southwest;
        self.northeast = northeast;
    }
    
    return self;
}

+ (BSForwardGeocoderCoordinateBounds *)boundsWithSouthWest:(CLLocationCoordinate2D)southwest northEast:(CLLocationCoordinate2D)northeast
{
    return [[[self alloc] initWithSouthWest:southwest northEast:northeast] autorelease];
}
@end
