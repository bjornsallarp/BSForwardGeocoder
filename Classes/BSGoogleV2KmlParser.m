//
//  Created by Björn Sållarp on 2010-03-13.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

/**
 
 Kml Parser for Googles geocoding service version 2. Find out more @ Google:
 http://code.google.com/apis/maps/documentation/geocoding/index.html
 
 **/

#import "BSGoogleV2KmlParser.h"


@implementation BSGoogleV2KmlParser

@synthesize name, statusCode;
@synthesize placemarks = placemarkArray;

- (BOOL)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error
{
	BOOL successfull = TRUE;
	
    // Load the data trough NSData, NSXMLParser leaks when loading data
    NSData *xmlData = [[NSData alloc] initWithContentsOfURL:URL];
    
	// Create XML parser
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];

    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];

    // Start parsing
    [parser parse];
    
    NSError *parseError = [parser parserError];
    if (parseError && error) {
        *error = parseError;
		
		successfull = FALSE;
    }
    
    [parser release];
    [xmlData release];
	
	return successfull;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict
{
	if (qName) {
        elementName = qName;
    }
	
	// The response could contain multiple placemarks
	if([elementName isEqualToString:@"Placemark"])
	{
		// Set up an array to hold placemarks
		if(placemarkArray == nil)
		{
			placemarkArray = [[NSMutableArray alloc] init];
		}
				
		// Create a new placemark object to fill with information
		currentPlacemark = [[BSKmlResult alloc] init];
	}
	
	// These are the elements we read information from.
	if([elementName isEqualToString:@"code"] || [elementName isEqualToString:@"name"] || [elementName isEqualToString:@"address"]
	   || [elementName isEqualToString:@"CountryNameCode"] || [elementName isEqualToString:@"CountryName"] 
	   || [elementName isEqualToString:@"SubAdministrativeAreaName"] || [elementName isEqualToString:@"LocalityName"]
	   || [elementName isEqualToString:@"coordinates"])
	{
		// Create a mutable string to hold the contents of the elements.
        // The content is collected in parser:foundCharacters:.
        if(contentsOfCurrentProperty == nil)
		{
			contentsOfCurrentProperty = [NSMutableString string];
		}
		else 
		{
			[contentsOfCurrentProperty setString:@""];
		}
	}
	// Unlike most other information the LatLonBox and AddressDetails elements has interesting data in attributes
	else if([elementName isEqualToString:@"LatLonBox"])
	{
		currentPlacemark.viewportSouthWestLat = [[attributeDict valueForKey:@"south"] floatValue];
		currentPlacemark.viewportSouthWestLon = [[attributeDict valueForKey:@"west"] floatValue];
		currentPlacemark.viewportNorthEastLat = [[attributeDict valueForKey:@"north"] floatValue];
		currentPlacemark.viewportNorthEastLon = [[attributeDict valueForKey:@"east"] floatValue];

	}
	else if([elementName isEqualToString:@"AddressDetails"])
	{
		currentPlacemark.accuracy = [[attributeDict valueForKey:@"Accuracy"] intValue];
	}
	else 
	{
		// If we're not interested in the element we set the variable used 
		// to collect information to nil.
		contentsOfCurrentProperty = nil;
	}

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName
{ 
	if (qName) {
        elementName = qName;
    }
	
	// If we reach the end of a placemark element we add it to our array
	if([elementName isEqualToString:@"Placemark"])
	{
		if(currentPlacemark != nil)
		{
			[placemarkArray addObject:currentPlacemark];
			[currentPlacemark release];
			currentPlacemark = nil;
		}
	}
	
	// If contentsOfCurrentProperty is nil we're not interested in the
	// collected data 
	if(contentsOfCurrentProperty == nil)
		return;
	
	NSString* elementValue = [[NSString alloc] initWithString:contentsOfCurrentProperty];
	
	if ([elementName isEqualToString:@"name"]) {
		self.name = elementValue;
	}
	else if ([elementName isEqualToString:@"code"]) {
		statusCode = [elementValue intValue];
    }
	if ([elementName isEqualToString:@"address"]) {
		currentPlacemark.address = elementValue;
	}
	if ([elementName isEqualToString:@"CountryNameCode"]) {
		currentPlacemark.countryNameCode = elementValue;
	}
	if ([elementName isEqualToString:@"CountryName"]) {
		currentPlacemark.countryName = elementValue;
	}
	if ([elementName isEqualToString:@"SubAdministrativeAreaName"]) {
		currentPlacemark.subAdministrativeAreaName = elementValue;
	}
	if ([elementName isEqualToString:@"LocalityName"]) {
		currentPlacemark.localityName = elementValue;
	}
	if ([elementName isEqualToString:@"coordinates"]) {
		// Coordinates are stored in a comma separated string.
		NSArray *chunks = [elementValue componentsSeparatedByString: @","];
		currentPlacemark.longitude = [[chunks objectAtIndex:0] floatValue];
		currentPlacemark.latitude = [[chunks objectAtIndex:1] floatValue];
	}

	
	[elementValue release];
	contentsOfCurrentProperty = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (contentsOfCurrentProperty) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        [contentsOfCurrentProperty appendString:string];
    }
}



-(void)dealloc
{
    [contentsOfCurrentProperty release];
    [placemarkArray release];
	[name release];
	[super dealloc];
}

@end
