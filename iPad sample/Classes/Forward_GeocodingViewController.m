//
//  Created by Björn Sållarp on 2010-03-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "Forward_GeocodingViewController.h"

@implementation Forward_GeocodingViewController
@synthesize forwardGeocoder = _forwardGeocoder;
@synthesize mapView = _mapView;
@synthesize searchBar = _searchBar;

- (void)viewDidLoad 
{
    [super viewDidLoad];

	self.mapView.showsUserLocation = YES;
	self.mapView.delegate = self;
	self.searchBar.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

#pragma mark - BSForwardGeocoderDelegate methods

- (void)forwardGeocoderConnectionDidFail:(BSForwardGeocoder *)geocoder withErrorMessage:(NSString *)errorMessage
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
													message:errorMessage
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];    
}


- (void)forwardGeocodingDidSucceed:(BSForwardGeocoder *)geocoder withResults:(NSArray *)results
{
    // Add placemarks for each result
    for (int i = 0, resultCount = [results count]; i < resultCount; i++) {
        BSKmlResult *place = [results objectAtIndex:i];
        
        // Add a placemark on the map
        CustomPlacemark *placemark = [[[CustomPlacemark alloc] initWithRegion:place.coordinateRegion] autorelease];
        placemark.title = place.address;
        placemark.subtitle = place.countryName;
        [self.mapView addAnnotation:placemark];	
    }
    
    if ([results count] == 1) {
        BSKmlResult *place = [results objectAtIndex:0];
        
        // Zoom into the location		
        [self.mapView setRegion:place.coordinateRegion animated:YES];
    }
    
    // Dismiss the keyboard
    [self.searchBar resignFirstResponder];
}

- (void)forwardGeocodingDidFail:(BSForwardGeocoder *)geocoder withErrorCode:(int)errorCode andErrorMessage:(NSString *)errorMessage
{
    NSString *message = @"";
    
    switch (errorCode) {
        case G_GEO_BAD_KEY:
            message = @"The API key is invalid.";
            break;
            
        case G_GEO_UNKNOWN_ADDRESS:
            message = [NSString stringWithFormat:@"Could not find %@", @"searchQuery"];
            break;
            
        case G_GEO_TOO_MANY_QUERIES:
            message = @"Too many queries has been made for this API key.";
            break;
            
        case G_GEO_SERVER_ERROR:
            message = @"Server error, please try again.";
            break;
            
            
        default:
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" 
                                                    message:message
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles: nil];
    [alert show];
    [alert release];
}


#pragma mark - UI Events
- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar 
{
	NSLog(@"Searching for: %@", self.searchBar.text);
	if (self.forwardGeocoder == nil) {
		self.forwardGeocoder = [[[BSForwardGeocoder alloc] initWithDelegate:self] autorelease];
	}
	
    // If you want to bias on coordinates pass a bounds object. This example is proof that the "Winnetka" example works (see https://developers.google.com/maps/documentation/geocoding/#Viewports) 
    CLLocationCoordinate2D southwest, northeast;
    southwest.latitude = 34.172684;
    southwest.longitude = -118.604794;
    northeast.latitude = 34.236144;
    northeast.longitude = -118.500938;
    BSForwardGeocoderCoordinateBounds *bounds = [BSForwardGeocoderCoordinateBounds boundsWithSouthWest:southwest northEast:northeast];

	// Forward geocode!
#if NS_BLOCKS_AVAILABLE
    [self.forwardGeocoder forwardGeocodeWithQuery:self.searchBar.text regionBiasing:nil viewportBiasing:bounds success:^(NSArray *results) {
        [self forwardGeocodingDidSucceed:self.forwardGeocoder withResults:results];
    } failure:^(int status, NSString *errorMessage) {
        if (status == G_GEO_NETWORK_ERROR) {
            [self forwardGeocoderConnectionDidFail:self.forwardGeocoder withErrorMessage:errorMessage];
        }
        else {
            [self forwardGeocodingDidFail:self.forwardGeocoder withErrorCode:status andErrorMessage:errorMessage];
        }
    }];
#else
    [self.forwardGeocoder forwardGeocodeWithQuery:self.searchBar.text regionBiasing:nil viewportBiasing:nil];
#endif
}

#pragma mark - MKMap methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
	if ([annotation isKindOfClass:[CustomPlacemark class]]) {
		MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[annotation title]];
		newAnnotation.pinColor = MKPinAnnotationColorGreen;
		newAnnotation.animatesDrop = YES; 
		newAnnotation.canShowCallout = YES;
		newAnnotation.enabled = YES;
		
		NSLog(@"Created annotation at: %f %f", ((CustomPlacemark*)annotation).coordinate.latitude, ((CustomPlacemark*)annotation).coordinate.longitude);
		
		[newAnnotation addObserver:self
						forKeyPath:@"selected"
						   options:NSKeyValueObservingOptionNew
						   context:@"GMAP_ANNOTATION_SELECTED"];
		
		[newAnnotation autorelease];
		
		return newAnnotation;
	}
	
	return nil;
}


- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context{
	
	NSString *action = (NSString*)context;
	
	// We only want to zoom to location when the annotation is actaully selected. This will trigger also for when it's deselected
	if([[change valueForKey:@"new"] intValue] == 1 && [action isEqualToString:@"GMAP_ANNOTATION_SELECTED"])  {
		if ([((MKAnnotationView*) object).annotation isKindOfClass:[CustomPlacemark class]]) {
			CustomPlacemark *place = ((MKAnnotationView*) object).annotation;
			
			// Zoom into the location		
			[self.mapView setRegion:place.coordinateRegion animated:TRUE];
			NSLog(@"annotation selected: %f %f", ((MKAnnotationView*) object).annotation.coordinate.latitude, ((MKAnnotationView*) object).annotation.coordinate.longitude);
		}
	}
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
    self.mapView = nil;
    self.searchBar = nil;
}

- (void)dealloc 
{
    [_mapView release];
	[_searchBar release];
    [_forwardGeocoder release];
	[super dealloc];	
}

@end
