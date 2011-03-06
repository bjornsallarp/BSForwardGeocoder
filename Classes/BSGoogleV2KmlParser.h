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
#import "BSKmlResult.h"

@interface BSGoogleV2KmlParser : NSObject<NSXMLParserDelegate> {
	NSMutableString *contentsOfCurrentProperty;
	int statusCode;
	NSString *name;
	NSMutableArray *placemarkArray;
	BSKmlResult *currentPlacemark;
	
}

@property (nonatomic, readonly) int statusCode;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, readonly) NSMutableArray *placemarks;

- (BOOL)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error;

@end
