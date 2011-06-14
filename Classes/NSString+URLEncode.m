//
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
//
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "NSString+URLEncode.h"

@implementation NSString (URLEncode)

// Use Core Foundation method to URL-encode strings, since -stringByAddingPercentEscapesUsingEncoding:
// doesn't do a complete job. For details, see:
//   http://simonwoodside.com/weblog/2009/4/22/how_to_really_url_encode/
//   http://stackoverflow.com/questions/730101/how-do-i-encode-in-a-url-in-an-html-attribute-value/730427#730427
- (NSString *)URLEncodedString
{
    NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                  (CFStringRef)self,
                                                                                  NULL,
                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                  kCFStringEncodingUTF8);
    return [encodedString autorelease];
}

@end