//
//  MGTwitterEngine.m
//  MGTwitterEngine
//
//  Created by Matt Gemmell on 10/02/2008.
//  Copyright 2008 Instinctive Code.
//

#import "MGTwitterEngine.h"
#import "MGTwitterHTTPURLConnection.h"

#import "NSData+Base64.h"

#define USE_LIBXML 0

#if YAJL_AVAILABLE
	#define API_FORMAT @"json"

	#import "MGTwitterStatusesYAJLParser.h"
	#import "MGTwitterMessagesYAJLParser.h"
	#import "MGTwitterUsersYAJLParser.h"
	#import "MGTwitterMiscYAJLParser.h"
	#import "MGTwitterSearchYAJLParser.h"
#else
	#define API_FORMAT @"xml"

	#if USE_LIBXML
		#import "MGTwitterStatusesLibXMLParser.h"
		#import "MGTwitterMessagesLibXMLParser.h"
		#import "MGTwitterUsersLibXMLParser.h"
		#import "MGTwitterMiscLibXMLParser.h"
	#else
		#import "MGTwitterStatusesParser.h"
		#import "MGTwitterUsersParser.h"
		#import "MGTwitterMessagesParser.h"
		#import "MGTwitterMiscParser.h"
	#endif
#endif

#define TWITTER_DOMAIN          @"api.twitter.com/1"
#if YAJL_AVAILABLE
	#define TWITTER_SEARCH_DOMAIN	@"search.twitter.com"
#endif
#define HTTP_POST_METHOD        @"POST"
#define MAX_MESSAGE_LENGTH      140 // Twitter recommends tweets of max 140 chars
#define MAX_NAME_LENGTH			20
#define MAX_EMAIL_LENGTH		40
#define MAX_URL_LENGTH			100
#define MAX_LOCATION_LENGTH		30
#define MAX_DESCRIPTION_LENGTH	160

#define DEFAULT_CLIENT_NAME     @"MGTwitterEngine"
#define DEFAULT_CLIENT_VERSION  @"1.0"
#define DEFAULT_CLIENT_URL      @"http://mattgemmell.com/source"
#define DEFAULT_CLIENT_TOKEN	@"mgtwitterengine"

#define URL_REQUEST_TIMEOUT     25.0 // Twitter usually fails quickly if it's going to fail at all.


@interface MGTwitterEngine (PrivateMethods)

// Utility methods
- (NSDateFormatter *)_HTTPDateFormatter;
- (NSString *)_queryStringWithBase:(NSString *)base parameters:(NSDictionary *)params prefixed:(BOOL)prefixed;
- (NSDate *)_HTTPToDate:(NSString *)httpDate;
- (NSString *)_dateToHTTP:(NSDate *)date;
- (NSString *)_encodeString:(NSString *)string;

// Connection/Request methods
- (NSString *)_sendRequestWithMethod:(NSString *)method 
                                path:(NSString *)path 
                     queryParameters:(NSDictionary *)params
                                body:(NSString *)body 
                         requestType:(MGTwitterRequestType)requestType 
                        responseType:(MGTwitterResponseType)responseType;

// Parsing methods
- (void)_parseDataForConnection:(MGTwitterHTTPURLConnection *)connection;

// Delegate methods
- (BOOL) _isValidDelegateForSelector:(SEL)selector;

@end


@implementation MGTwitterEngine


#pragma mark Constructors


+ (MGTwitterEngine *)twitterEngineWithDelegate:(NSObject *)theDelegate
{
    return [[[MGTwitterEngine alloc] initWithDelegate:theDelegate] autorelease];
}


- (MGTwitterEngine *)initWithDelegate:(NSObject<MGTwitterEngineDelegate>*)newDelegate
{
    if ((self = [super init])) {
        _delegate = (id) newDelegate; // deliberately weak reference
        _connections = [[NSMutableDictionary alloc] initWithCapacity:0];
        _clientName = [DEFAULT_CLIENT_NAME retain];
        _clientVersion = [DEFAULT_CLIENT_VERSION retain];
        _clientURL = [DEFAULT_CLIENT_URL retain];
		_clientSourceToken = [DEFAULT_CLIENT_TOKEN retain];
		_APIDomain = [TWITTER_DOMAIN retain];
#if YAJL_AVAILABLE
		_searchDomain = [TWITTER_SEARCH_DOMAIN retain];
#endif

        _secureConnection = YES;
		_clearsCookies = NO;
#if YAJL_AVAILABLE
		_deliveryOptions = MGTwitterEngineDeliveryAllResultsOption;
#endif
    }
    
    return self;
}


- (void)dealloc
{
    _delegate = nil;
    
    [[_connections allValues] makeObjectsPerformSelector:@selector(cancel)];
    [_connections release];
    
    [_username release];
    [_password release];
    [_clientName release];
    [_clientVersion release];
    [_clientURL release];
    [_clientSourceToken release];
	[_APIDomain release];
#if YAJL_AVAILABLE
	[_searchDomain release];
#endif
    
    [super dealloc];
}


#pragma mark Configuration and Accessors


+ (NSString *)version
{
    // 1.0.0 = 22 Feb 2008
    // 1.0.1 = 26 Feb 2008
    // 1.0.2 = 04 Mar 2008
    // 1.0.3 = 04 Mar 2008
	// 1.0.4 = 11 Apr 2008
	// 1.0.5 = 06 Jun 2008
	// 1.0.6 = 05 Aug 2008
	// 1.0.7 = 28 Sep 2008
	// 1.0.8 = 01 Oct 2008
    return @"1.0.8";
}


- (NSString *)username
{
   
    return [[_username retain] autorelease];
    
}


- (NSString *)password
{
    return [[_password retain] autorelease];
}


- (void)setUsername:(NSString *)newUsername password:(NSString *)newPassword
{
    // Set new credentials.
    [_username release];
    _username = [newUsername retain];
    [_password release];
    _password = [newPassword retain];
    
	if ([self clearsCookies]) {
		// Remove all cookies for twitter, to ensure next connection uses new credentials.
		NSString *urlString = [NSString stringWithFormat:@"%@://%@", 
							   (_secureConnection) ? @"https" : @"http", 
							   _APIDomain];
		NSURL *url = [NSURL URLWithString:urlString];
		
		NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
		NSEnumerator *enumerator = [[cookieStorage cookiesForURL:url] objectEnumerator];
		NSHTTPCookie *cookie = nil;
		while ((cookie = [enumerator nextObject])) {
			[cookieStorage deleteCookie:cookie];
		}
	}
}


- (NSString *)clientName
{
    return [[_clientName retain] autorelease];
}


- (NSString *)clientVersion
{
    return [[_clientVersion retain] autorelease];
}


- (NSString *)clientURL
{
    return [[_clientURL retain] autorelease];
}


- (NSString *)clientSourceToken
{
    return [[_clientSourceToken retain] autorelease];
}


- (void)setClientName:(NSString *)name version:(NSString *)version URL:(NSString *)url token:(NSString *)token;
{
    [_clientName release];
    _clientName = [name retain];
    [_clientVersion release];
    _clientVersion = [version retain];
    [_clientURL release];
    _clientURL = [url retain];
    [_clientSourceToken release];
    _clientSourceToken = [token retain];
}


- (NSString *)APIDomain
{
	return [[_APIDomain retain] autorelease];
}


- (void)setAPIDomain:(NSString *)domain
{
	[_APIDomain release];
	if (!domain || [domain length] == 0) {
		_APIDomain = [TWITTER_DOMAIN retain];
	} else {
		_APIDomain = [domain retain];
	}
}


#if YAJL_AVAILABLE

- (NSString *)searchDomain
{
	return [[_searchDomain retain] autorelease];
}


- (void)setSearchDomain:(NSString *)domain
{
	[_searchDomain release];
	if (!domain || [domain length] == 0) {
		_searchDomain = [TWITTER_SEARCH_DOMAIN retain];
	} else {
		_searchDomain = [domain retain];
	}
}

#endif


- (BOOL)usesSecureConnection
{
    return _secureConnection;
}


- (void)setUsesSecureConnection:(BOOL)flag
{
    _secureConnection = flag;
}


- (BOOL)clearsCookies
{
	return _clearsCookies;
}


- (void)setClearsCookies:(BOOL)flag
{
	_clearsCookies = flag;
}

#if YAJL_AVAILABLE

- (MGTwitterEngineDeliveryOptions)deliveryOptions
{
	return _deliveryOptions;
}

- (void)setDeliveryOptions:(MGTwitterEngineDeliveryOptions)deliveryOptions
{
	_deliveryOptions = deliveryOptions;
}

#endif

#pragma mark Connection methods


- (int)numberOfConnections
{
    return (int)[_connections count];
}


- (NSArray *)connectionIdentifiers
{
    return [_connections allKeys];
}


- (void)closeConnection:(NSString *)connectionIdentifier
{
    MGTwitterHTTPURLConnection *connection = [_connections objectForKey:connectionIdentifier];
    if (connection) {
        [connection cancel];
        [_connections removeObjectForKey:connectionIdentifier];
		if ([self _isValidDelegateForSelector:@selector(connectionFinished:)])
			[_delegate connectionFinished:connectionIdentifier];
    }
}


- (void)closeAllConnections
{
    [[_connections allValues] makeObjectsPerformSelector:@selector(cancel)];
    [_connections removeAllObjects];
}


#pragma mark Utility methods


- (NSDateFormatter *)_HTTPDateFormatter
{
    // Returns a formatter for dates in HTTP format (i.e. RFC 822, updated by RFC 1123).
    // e.g. "Sun, 06 Nov 1994 08:49:37 GMT"
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	//[dateFormatter setDateFormat:@"%a, %d %b %Y %H:%M:%S GMT"]; // won't work with -init, which uses new (unicode) format behaviour.
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss GMT"];
	return dateFormatter;
}


- (NSString *)_queryStringWithBase:(NSString *)base parameters:(NSDictionary *)params prefixed:(BOOL)prefixed
{
    // Append base if specified.
    NSMutableString *str = [NSMutableString stringWithCapacity:0];
    if (base) {
        [str appendString:base];
    }
    
    // Append each name-value pair.
    if (params) {
        int i;
        NSArray *names = [params allKeys];
        for (i = 0; i < [names count]; i++) {
            if (i == 0 && prefixed) {
                [str appendString:@"?"];
            } else if (i > 0) {
                [str appendString:@"&"];
            }
            NSString *name = [names objectAtIndex:i];
            [str appendString:[NSString stringWithFormat:@"%@=%@", 
             name, [self _encodeString:[params objectForKey:name]]]];
        }
    }
    
    return str;
}


- (NSDate *)_HTTPToDate:(NSString *)httpDate
{
    NSDateFormatter *dateFormatter = [self _HTTPDateFormatter];
    return [dateFormatter dateFromString:httpDate];
}


- (NSString *)_dateToHTTP:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [self _HTTPDateFormatter];
    return [dateFormatter stringFromDate:date];
}


- (NSString *)_encodeString:(NSString *)string
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
                                                                 (CFStringRef)string, 
                                                                 NULL, 
                                                                 (CFStringRef)@";/?:@&=$+{}<>,",
                                                                 kCFStringEncodingUTF8);
    return [result autorelease];
}


- (NSString *)getImageAtURL:(NSString *)urlString
{
    // This is a method implemented for the convenience of the client, 
    // allowing asynchronous downloading of users' Twitter profile images.
	NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encodedUrlString];
    if (!url) {
        return nil;
    }
    
    // Construct an NSMutableURLRequest for the URL and set appropriate request method.
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url 
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                          timeoutInterval:URL_REQUEST_TIMEOUT];
    
    // Create a connection using this request, with the default timeout and caching policy, 
    // and appropriate Twitter request and response types for parsing and error reporting.
    MGTwitterHTTPURLConnection *connection;
    connection = [[MGTwitterHTTPURLConnection alloc] initWithRequest:theRequest 
                                                            delegate:self 
                                                         requestType:MGTwitterImageRequest 
                                                        responseType:MGTwitterImage];
    
    if (!connection) {
        return nil;
    } else {
        [_connections setObject:connection forKey:[connection identifier]];
        [connection release];
    }
    
    return [connection identifier];
}


#pragma mark Request sending methods

#define SET_AUTHORIZATION_IN_HEADER 1

- (NSString *)_sendRequestWithMethod:(NSString *)method 
                                path:(NSString *)path 
                     queryParameters:(NSDictionary *)params 
                                body:(NSString *)body 
                         requestType:(MGTwitterRequestType)requestType 
                        responseType:(MGTwitterResponseType)responseType
{
    // Construct appropriate URL string.
    NSString *fullPath = path;
    if (params) {
        fullPath = [self _queryStringWithBase:fullPath parameters:params prefixed:YES];
    }

#if YAJL_AVAILABLE
	NSString *domain = nil;
	NSString *connectionType = nil;
	if (requestType == MGTwitterSearchRequest || requestType == MGTwitterSearchCurrentTrendsRequest)
	{
		domain = _searchDomain;
		connectionType = @"http";
	}
	else
	{
		domain = _APIDomain;
		if (_secureConnection)
		{
			connectionType = @"https";
		}
		else
		{
			connectionType = @"http";
		}
	}
#else
	NSString *domain = _APIDomain;
	NSString *connectionType = nil;
	if (_secureConnection)
	{
		connectionType = @"https";
	}
	else
	{
		connectionType = @"http";
	}
#endif
	
#if SET_AUTHORIZATION_IN_HEADER
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/%@", 
                           connectionType,
                           domain, fullPath];
#else    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@:%@@%@/%@", 
                           connectionType, 
                           [self _encodeString:_username], [self _encodeString:_password], 
                           domain, fullPath];
#endif
    
    NSURL *finalURL = [NSURL URLWithString:urlString];
    if (!finalURL) {
        return nil;
    }

#if DEBUG
    if (YES) {
		//NSLog(@"MGTwitterEngine: finalURL = %@", finalURL);
	}
#endif

    // Construct an NSMutableURLRequest for the URL and set appropriate request method.
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:finalURL 
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                          timeoutInterval:URL_REQUEST_TIMEOUT];
    if (method) {
        [theRequest setHTTPMethod:method];
    }
    [theRequest setHTTPShouldHandleCookies:NO];
    
    // Set headers for client information, for tracking purposes at Twitter.
    [theRequest setValue:_clientName    forHTTPHeaderField:@"X-Twitter-Client"];
    [theRequest setValue:_clientVersion forHTTPHeaderField:@"X-Twitter-Client-Version"];
    [theRequest setValue:_clientURL     forHTTPHeaderField:@"X-Twitter-Client-URL"];
    
#if SET_AUTHORIZATION_IN_HEADER
	if ([self username] && [self password]) {
		// Set header for HTTP Basic authentication explicitly, to avoid problems with proxies and other intermediaries
		NSString *authStr = [NSString stringWithFormat:@"%@:%@", [self username], [self password]];
		NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
		NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
		[theRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
	}
#endif

    // Set the request body if this is a POST request.
    BOOL isPOST = (method && [method isEqualToString:HTTP_POST_METHOD]);
    if (isPOST) {
        // Set request body, if specified (hopefully so), with 'source' parameter if appropriate.
        NSString *finalBody = @"";
		if (body) {
			finalBody = [finalBody stringByAppendingString:body];
		}
        if (_clientSourceToken) {
            finalBody = [finalBody stringByAppendingString:[NSString stringWithFormat:@"%@source=%@", 
                                                            (body) ? @"&" : @"?" , 
                                                            _clientSourceToken]];
        }
        
        if (finalBody) {
            [theRequest setHTTPBody:[finalBody dataUsingEncoding:NSUTF8StringEncoding]];
#if DEBUG
			if (YES) {
				//NSLog(@"MGTwitterEngine: finalBody = %@", finalBody);
			}
#endif
        }
    }
    
    
    // Create a connection using this request, with the default timeout and caching policy, 
    // and appropriate Twitter request and response types for parsing and error reporting.
    MGTwitterHTTPURLConnection *connection;
    connection = [[MGTwitterHTTPURLConnection alloc] initWithRequest:theRequest 
                                                            delegate:self 
                                                         requestType:requestType 
                                                        responseType:responseType];
    
    if (!connection) {
        return nil;
    } else {
        [_connections setObject:connection forKey:[connection identifier]];
        [connection release];
    }
    
    return [connection identifier];
}


#pragma mark Parsing methods

#if YAJL_AVAILABLE
- (void)_parseDataForConnection:(MGTwitterHTTPURLConnection *)connection
{
    NSString *identifier = [[[connection identifier] copy] autorelease];
    NSData *jsonData = [[[connection data] copy] autorelease];
    MGTwitterRequestType requestType = [connection requestType];
    MGTwitterResponseType responseType = [connection responseType];

	NSURL *URL = [connection URL];

#if DEBUG
	if (NO) {
		//NSLog(@"MGTwitterEngine: jsonData = %@ from %@", [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease], URL);
	}
#endif

    switch (responseType) {
        case MGTwitterStatuses:
        case MGTwitterStatus:
            [MGTwitterStatusesYAJLParser parserWithJSON:jsonData delegate:self 
                              connectionIdentifier:identifier requestType:requestType 
                                      responseType:responseType URL:URL deliveryOptions:_deliveryOptions];
            break;
        case MGTwitterUsers:
        case MGTwitterUser:
            [MGTwitterUsersYAJLParser parserWithJSON:jsonData delegate:self 
                           connectionIdentifier:identifier requestType:requestType 
                                   responseType:responseType URL:URL deliveryOptions:_deliveryOptions];
            break;
        case MGTwitterDirectMessages:
        case MGTwitterDirectMessage:
            [MGTwitterMessagesYAJLParser parserWithJSON:jsonData delegate:self 
                              connectionIdentifier:identifier requestType:requestType 
                                      responseType:responseType URL:URL deliveryOptions:_deliveryOptions];
            break;
		case MGTwitterMiscellaneous:
			[MGTwitterMiscYAJLParser parserWithJSON:jsonData delegate:self 
						  connectionIdentifier:identifier requestType:requestType 
								  responseType:responseType URL:URL deliveryOptions:_deliveryOptions];
			break;
        case MGTwitterSearchResults:
 			[MGTwitterSearchYAJLParser parserWithJSON:jsonData delegate:self 
						  connectionIdentifier:identifier requestType:requestType 
								  responseType:responseType URL:URL deliveryOptions:_deliveryOptions];
			break;
       default:
            break;
    }
}
#else
- (void)_parseDataForConnection:(MGTwitterHTTPURLConnection *)connection
{
    NSString *identifier = [[[connection identifier] copy] autorelease];
    NSData *xmlData = [[[connection data] copy] autorelease];
    MGTwitterRequestType requestType = [connection requestType];
    MGTwitterResponseType responseType = [connection responseType];
    
#if USE_LIBXML
	NSURL *URL = [connection URL];

    switch (responseType) {
        case MGTwitterStatuses:
        case MGTwitterStatus:
            [MGTwitterStatusesLibXMLParser parserWithXML:xmlData delegate:self 
                              connectionIdentifier:identifier requestType:requestType 
                                      responseType:responseType URL:URL];
            break;
        case MGTwitterUsers:
        case MGTwitterUser:
            [MGTwitterUsersLibXMLParser parserWithXML:xmlData delegate:self 
                           connectionIdentifier:identifier requestType:requestType 
                                   responseType:responseType URL:URL];
            break;
        case MGTwitterDirectMessages:
        case MGTwitterDirectMessage:
            [MGTwitterMessagesLibXMLParser parserWithXML:xmlData delegate:self 
                              connectionIdentifier:identifier requestType:requestType 
                                      responseType:responseType URL:URL];
            break;
		case MGTwitterMiscellaneous:
			[MGTwitterMiscLibXMLParser parserWithXML:xmlData delegate:self 
						  connectionIdentifier:identifier requestType:requestType 
								  responseType:responseType URL:URL];
			break;
        default:
            break;
    }
#else
    // Determine which type of parser to use.
    switch (responseType) {
        case MGTwitterStatuses:
        case MGTwitterStatus:
            [MGTwitterStatusesParser parserWithXML:xmlData delegate:self 
                              connectionIdentifier:identifier requestType:requestType 
                                      responseType:responseType];
            break;
        case MGTwitterUsers:
        case MGTwitterUser:
            [MGTwitterUsersParser parserWithXML:xmlData delegate:self 
                           connectionIdentifier:identifier requestType:requestType 
                                   responseType:responseType];
            break;
        case MGTwitterDirectMessages:
        case MGTwitterDirectMessage:
            [MGTwitterMessagesParser parserWithXML:xmlData delegate:self 
                              connectionIdentifier:identifier requestType:requestType 
                                      responseType:responseType];
            break;
		case MGTwitterMiscellaneous:
			[MGTwitterMiscParser parserWithXML:xmlData delegate:self 
						  connectionIdentifier:identifier requestType:requestType 
								  responseType:responseType];
			break;
        default:
            break;
    }
#endif
}
#endif

#pragma mark Delegate methods

- (BOOL) _isValidDelegateForSelector:(SEL)selector
{
	return ((_delegate != nil) && [_delegate respondsToSelector:selector]);
}

#pragma mark MGTwitterParserDelegate methods

- (void)parsingSucceededForRequest:(NSString *)identifier 
                    ofResponseType:(MGTwitterResponseType)responseType 
                 withParsedObjects:(NSArray *)parsedObjects
{
    // Forward appropriate message to _delegate, depending on responseType.
    switch (responseType) {
        case MGTwitterStatuses:
        case MGTwitterStatus:
			if ([self _isValidDelegateForSelector:@selector(statusesReceived:forRequest:)])
				[_delegate statusesReceived:parsedObjects forRequest:identifier];
            break;
        case MGTwitterUsers:
        case MGTwitterUser:
			if ([self _isValidDelegateForSelector:@selector(userInfoReceived:forRequest:)])
				[_delegate userInfoReceived:parsedObjects forRequest:identifier];
            break;
        case MGTwitterDirectMessages:
        case MGTwitterDirectMessage:
			if ([self _isValidDelegateForSelector:@selector(directMessagesReceived:forRequest:)])
				[_delegate directMessagesReceived:parsedObjects forRequest:identifier];
            break;
		case MGTwitterMiscellaneous:
			if ([self _isValidDelegateForSelector:@selector(miscInfoReceived:forRequest:)])
				[_delegate miscInfoReceived:parsedObjects forRequest:identifier];
			break;
#if YAJL_AVAILABLE
		case MGTwitterSearchResults:
			if ([self _isValidDelegateForSelector:@selector(searchResultsReceived:forRequest:)])
				[_delegate searchResultsReceived:parsedObjects forRequest:identifier];
			break;
#endif
        default:
            break;
    }
}

- (void)parsingFailedForRequest:(NSString *)requestIdentifier 
                 ofResponseType:(MGTwitterResponseType)responseType 
                      withError:(NSError *)error
{
	if ([self _isValidDelegateForSelector:@selector(requestFailed:withError:)])
		[_delegate requestFailed:requestIdentifier withError:error];
}

#if YAJL_AVAILABLE

- (void)parsedObject:(NSDictionary *)dictionary forRequest:(NSString *)requestIdentifier 
                 ofResponseType:(MGTwitterResponseType)responseType
{
	if ([self _isValidDelegateForSelector:@selector(receivedObject:forRequest:)])
		[_delegate receivedObject:dictionary forRequest:requestIdentifier];
}

#endif

#pragma mark NSURLConnection delegate methods


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if (_username && _password && [challenge previousFailureCount] == 0 && ![challenge proposedCredential]) {
		NSURLCredential *credential = [NSURLCredential credentialWithUser:_username password:_password 
															  persistence:NSURLCredentialPersistenceForSession];
		[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
	} else {
		[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
	}
}


- (void)connection:(MGTwitterHTTPURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it has enough information to create the NSURLResponse.
    // it can be called multiple times, for example in the case of a redirect, so each time we reset the data.
    [connection resetDataLength];
    
    // Get response code.
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    int statusCode = (int)[resp statusCode];
    
    if (statusCode >= 400) {
        // Assume failure, and report to delegate.
        NSError *error = [NSError errorWithDomain:@"HTTP" code:statusCode userInfo:nil];
		if ([self _isValidDelegateForSelector:@selector(requestFailed:withError:)])
			[_delegate requestFailed:[connection identifier] withError:error];
        
        // Destroy the connection.
        [connection cancel];
		NSString *connectionIdentifier = [connection identifier];
		[_connections removeObjectForKey:connectionIdentifier];
		if ([self _isValidDelegateForSelector:@selector(connectionFinished:)])
			[_delegate connectionFinished:connectionIdentifier];
			        
    } else if (statusCode == 304 || [connection responseType] == MGTwitterGeneric) {
        // Not modified, or generic success.
		if ([self _isValidDelegateForSelector:@selector(requestSucceeded:)])
			[_delegate requestSucceeded:[connection identifier]];
        if (statusCode == 304) {
            [self parsingSucceededForRequest:[connection identifier] 
                              ofResponseType:[connection responseType] 
                           withParsedObjects:[NSArray array]];
        }
        
        // Destroy the connection.
        [connection cancel];
		NSString *connectionIdentifier = [connection identifier];
		[_connections removeObjectForKey:connectionIdentifier];
		if ([self _isValidDelegateForSelector:@selector(connectionFinished:)])
			[_delegate connectionFinished:connectionIdentifier];
    }
    
#if DEBUG
    if (NO) {
        // Display headers for debugging.
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        NSLog(@"MGTwitterEngine: (%ld) [%@]:\r%@", 
              (long)[resp statusCode],
              [NSHTTPURLResponse localizedStringForStatusCode:[resp statusCode]], 
              [resp allHeaderFields]);
    }
#endif
}


- (void)connection:(MGTwitterHTTPURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to the receivedData.
    [connection appendData:data];
}


- (void)connection:(MGTwitterHTTPURLConnection *)connection didFailWithError:(NSError *)error
{
    // Inform delegate.
	if ([self _isValidDelegateForSelector:@selector(requestFailed:withError:)])
		[_delegate requestFailed:[connection identifier] withError:error];
    
    // Release the connection.
	NSString *connectionIdentifier = [connection identifier];
    [_connections removeObjectForKey:connectionIdentifier];
	if ([self _isValidDelegateForSelector:@selector(connectionFinished:)])
		[_delegate connectionFinished:connectionIdentifier];
}


- (void)connectionDidFinishLoading:(MGTwitterHTTPURLConnection *)connection
{
    // Inform delegate.
	if ([self _isValidDelegateForSelector:@selector(requestSucceeded:)])
		[_delegate requestSucceeded:[connection identifier]];
    
    NSData *receivedData = [connection data];
    if (receivedData) {
#if DEBUG
        if (NO) {
            // Dump data as string for debugging.
           // NSString *dataString = [NSString stringWithUTF8String:[receivedData bytes]];
            //NSLog(@"MGTwitterEngine: Succeeded! Received %d bytes of data:\r\r%@", [receivedData length], dataString);
        }
        
        if (NO) {
            // Dump XML to file for debugging.
            NSString *dataString = [NSString stringWithUTF8String:[receivedData bytes]];
            [dataString writeToFile:[[NSString stringWithFormat:@"~/Desktop/twitter_messages.%@", API_FORMAT] stringByExpandingTildeInPath] 
                         atomically:NO encoding:NSUnicodeStringEncoding error:NULL];
        }
#endif
        
        if ([connection responseType] == MGTwitterImage) {
			// Create image from data.
#if TARGET_OS_IPHONE
            UIImage *image = [[[UIImage alloc] initWithData:[connection data]] autorelease];
#else
            NSImage *image = [[[NSImage alloc] initWithData:[connection data]] autorelease];
#endif
            
            // Inform delegate.
			if ([self _isValidDelegateForSelector:@selector(imageReceived:forRequest:)])
				[_delegate imageReceived:image forRequest:[connection identifier]];
        } else {
            // Parse data from the connection (either XML or JSON.)
            [self _parseDataForConnection:connection];
        }
    }
    
    // Release the connection.
	NSString *connectionIdentifier = [connection identifier];
    [_connections removeObjectForKey:connectionIdentifier];
	if ([self _isValidDelegateForSelector:@selector(connectionFinished:)])
		[_delegate connectionFinished:connectionIdentifier];
}


#pragma mark -
#pragma mark REST API methods
#pragma mark -

#pragma mark Status methods


- (NSString *)getPublicTimeline
{
    NSString *path = [NSString stringWithFormat:@"statuses/public_timeline.%@", API_FORMAT];
    
	return [self _sendRequestWithMethod:nil path:path queryParameters:nil body:nil 
                            requestType:MGTwitterPublicTimelineRequest 
                           responseType:MGTwitterStatuses];
}


#pragma mark -


- (NSString *)getFollowedTimelineSinceID:(unsigned long)sinceID startingAtPage:(int)page count:(int)count
{
    return [self getFollowedTimelineSinceID:sinceID withMaximumID:0 startingAtPage:page count:count];
}

- (NSString *)getFollowedTimelineSinceID:(unsigned long)sinceID withMaximumID:(unsigned long)maxID startingAtPage:(int)page count:(int)count
{
	NSString *path = [NSString stringWithFormat:@"statuses/friends_timeline.%@", API_FORMAT];

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (sinceID > 0) {
        [params setObject:[NSString stringWithFormat:@"%lu", sinceID] forKey:@"since_id"];
    }
    if (maxID > 0) {
        [params setObject:[NSString stringWithFormat:@"%lu", maxID] forKey:@"max_id"];
    }
    if (page > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    if (count > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:params body:nil 
                            requestType:MGTwitterFollowedTimelineRequest 
                           responseType:MGTwitterStatuses];
}


#pragma mark -


- (NSString *)getUserTimelineFor:(NSString *)username sinceID:(unsigned long)sinceID startingAtPage:(int)page count:(int)count
{
    return [self getUserTimelineFor:username sinceID:sinceID withMaximumID:0 startingAtPage:0 count:count];
}

- (NSString *)getUserTimelineFor:(NSString *)username sinceID:(unsigned long)sinceID withMaximumID:(unsigned long)maxID startingAtPage:(int)page count:(int)count
{
	NSString *path = [NSString stringWithFormat:@"statuses/user_timeline.%@", API_FORMAT];
    MGTwitterRequestType requestType = MGTwitterUserTimelineRequest;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (sinceID > 0) {
        [params setObject:[NSString stringWithFormat:@"%lu", sinceID] forKey:@"since_id"];
    }
    if (maxID > 0) {
        [params setObject:[NSString stringWithFormat:@"%lu", maxID] forKey:@"max_id"];
    }
	if (page > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    if (count > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
    if (username) {
        path = [NSString stringWithFormat:@"statuses/user_timeline/%@.%@", username, API_FORMAT];
		requestType = MGTwitterUserTimelineForUserRequest;
    }
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:params body:nil 
                            requestType:requestType 
                           responseType:MGTwitterStatuses];
}


#pragma mark -


- (NSString *)getUpdate:(unsigned long)updateID
{
    NSString *path = [NSString stringWithFormat:@"statuses/show/%lu.%@", updateID, API_FORMAT];
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:nil body:nil 
                            requestType:MGTwitterUpdateGetRequest
                           responseType:MGTwitterStatus];
}


- (NSString *)sendUpdate:(NSString *)status
{
    return [self sendUpdate:status inReplyTo:0];
}


- (NSString *)sendUpdate:(NSString *)status inReplyTo:(unsigned long)updateID
{
    if (!status) {
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"statuses/update.%@", API_FORMAT];
    
    NSString *trimmedText = status;
    if ([trimmedText length] > MAX_MESSAGE_LENGTH) {
        trimmedText = [trimmedText substringToIndex:MAX_MESSAGE_LENGTH];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:trimmedText forKey:@"status"];
    if (updateID > 0) {
        [params setObject:[NSString stringWithFormat:@"%lu", updateID] forKey:@"in_reply_to_status_id"];
    }
    NSString *body = [self _queryStringWithBase:nil parameters:params prefixed:NO];
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path 
                        queryParameters:params body:body 
                            requestType:MGTwitterUpdateSendRequest
                           responseType:MGTwitterStatus];
}


#pragma mark -


- (NSString *)getRepliesStartingAtPage:(int)page
{
    return [self getRepliesSinceID:0 startingAtPage:page count:0]; // zero means default
}

- (NSString *)getRepliesSinceID:(unsigned long)sinceID startingAtPage:(int)page count:(int)count
{
    return [self getRepliesSinceID:sinceID withMaximumID:0 startingAtPage:page count:count];
}

- (NSString *)getRepliesSinceID:(unsigned long)sinceID withMaximumID:(unsigned long)maxID startingAtPage:(int)page count:(int)count
{
// NOTE: identi.ca can't handle mentions URL yet...
//	NSString *path = [NSString stringWithFormat:@"statuses/mentions.%@", API_FORMAT];
	NSString *path = [NSString stringWithFormat:@"statuses/replies.%@", API_FORMAT];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (sinceID > 0) {
        [params setObject:[NSString stringWithFormat:@"%lu", sinceID] forKey:@"since_id"];
    }
    if (maxID > 0) {
        [params setObject:[NSString stringWithFormat:@"%lu", maxID] forKey:@"max_id"];
    }
    if (page > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    if (count > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:params body:nil 
                            requestType:MGTwitterRepliesRequest 
                           responseType:MGTwitterStatuses];
}


#pragma mark -


- (NSString *)deleteUpdate:(unsigned long)updateID
{
    NSString *path = [NSString stringWithFormat:@"statuses/destroy/%lu.%@", updateID, API_FORMAT];
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:nil body:nil 
                            requestType:MGTwitterUpdateDeleteRequest
                           responseType:MGTwitterStatus];
}


#pragma mark -


- (NSString *)getFeaturedUsers
{
    NSString *path = [NSString stringWithFormat:@"statuses/featured.%@", API_FORMAT];
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:nil body:nil 
                            requestType:MGTwitterFeaturedUsersRequest 
                           responseType:MGTwitterUsers];
}


#pragma mark User methods


- (NSString *)getRecentlyUpdatedFriendsFor:(NSString *)username startingAtPage:(int)page
{
    NSString *path = [NSString stringWithFormat:@"statuses/friends.%@", API_FORMAT];
    MGTwitterRequestType requestType = MGTwitterFriendUpdatesRequest;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (username) {
        path = [NSString stringWithFormat:@"statuses/friends/%@.%@", username, API_FORMAT];
		requestType = MGTwitterFriendUpdatesForUserRequest;
    }
    if (page > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:params body:nil 
                            requestType:requestType 
                           responseType:MGTwitterUsers];
}


#pragma mark -


- (NSString *)getFollowersIncludingCurrentStatus:(BOOL)flag
{
    NSString *path = [NSString stringWithFormat:@"statuses/followers.%@", API_FORMAT];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (!flag) {
        [params setObject:@"true" forKey:@"lite"]; // slightly bizarre, but correct.
    }
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:params body:nil 
                            requestType:MGTwitterFollowerUpdatesRequest
                           responseType:MGTwitterUsers];
}


#pragma mark -


- (NSString *)getUserInformationFor:(NSString *)usernameOrID
{
    if (!usernameOrID) {
        return nil;
    }
    NSString *path = [NSString stringWithFormat:@"users/show/%@.%@", usernameOrID, API_FORMAT];
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:nil body:nil 
                            requestType:MGTwitterUserInformationRequest 
                           responseType:MGTwitterUser];
}


- (NSString *)getUserInformationForEmail:(NSString *)email
{
    NSString *path = [NSString stringWithFormat:@"users/show.%@", API_FORMAT];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (email) {
        [params setObject:email forKey:@"email"];
    } else {
        return nil;
    }
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:params body:nil 
                            requestType:MGTwitterUserInformationRequest 
                           responseType:MGTwitterUser];
}


#pragma mark Direct Message methods


- (NSString *)getDirectMessagesSinceID:(unsigned long)sinceID startingAtPage:(int)page
{
    return [self getDirectMessagesSinceID:sinceID withMaximumID:0 startingAtPage:page count:0];
}

- (NSString *)getDirectMessagesSinceID:(unsigned long)sinceID withMaximumID:(unsigned long)maxID startingAtPage:(int)page count:(int)count
{
    NSString *path = [NSString stringWithFormat:@"direct_messages.%@", API_FORMAT];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (sinceID > 0) {
        [params setObject:[NSString stringWithFormat:@"%lu", sinceID] forKey:@"since_id"];
    }
    if (maxID > 0) {
        [params setObject:[NSString stringWithFormat:@"%lu", maxID] forKey:@"max_id"];
    }
    if (page > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    if (count > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:params body:nil 
                            requestType:MGTwitterDirectMessagesRequest 
                           responseType:MGTwitterDirectMessages];
}


#pragma mark -

- (NSString *)getSentDirectMessagesSinceID:(unsigned long)sinceID startingAtPage:(int)page
{
    return [self getSentDirectMessagesSinceID:sinceID withMaximumID:0 startingAtPage:page count:0];
}

- (NSString *)getSentDirectMessagesSinceID:(unsigned long)sinceID withMaximumID:(unsigned long)maxID startingAtPage:(int)page count:(int)count
{
    NSString *path = [NSString stringWithFormat:@"direct_messages/sent.%@", API_FORMAT];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (sinceID > 0) {
        [params setObject:[NSString stringWithFormat:@"%lu", sinceID] forKey:@"since_id"];
    }
    if (maxID > 0) {
        [params setObject:[NSString stringWithFormat:@"%lu", maxID] forKey:@"max_id"];
    }
    if (page > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    if (count > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    }
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:params body:nil 
                            requestType:MGTwitterDirectMessagesSentRequest 
                           responseType:MGTwitterDirectMessages];
}


#pragma mark -


- (NSString *)sendDirectMessage:(NSString *)message to:(NSString *)username
{
    if (!message || !username) {
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"direct_messages/new.%@", API_FORMAT];
    
    NSString *trimmedText = message;
    if ([trimmedText length] > MAX_MESSAGE_LENGTH) {
        trimmedText = [trimmedText substringToIndex:MAX_MESSAGE_LENGTH];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:trimmedText forKey:@"text"];
    [params setObject:username forKey:@"user"];
    NSString *body = [self _queryStringWithBase:nil parameters:params prefixed:NO];
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path 
                        queryParameters:params body:body 
                            requestType:MGTwitterDirectMessageSendRequest
                           responseType:MGTwitterDirectMessage];
}


- (NSString *)deleteDirectMessage:(unsigned long)updateID
{
    NSString *path = [NSString stringWithFormat:@"direct_messages/destroy/%lu.%@", updateID, API_FORMAT];
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:nil body:nil 
                            requestType:MGTwitterDirectMessageDeleteRequest 
                           responseType:MGTwitterDirectMessage];
}


#pragma mark Friendship methods


- (NSString *)enableUpdatesFor:(NSString *)username
{
    // i.e. follow
    if (!username) {
        return nil;
    }
    NSString *path = [NSString stringWithFormat:@"friendships/create/%@.%@", username, API_FORMAT];
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:nil body:nil 
                            requestType:MGTwitterUpdatesEnableRequest 
                           responseType:MGTwitterUser];
}


- (NSString *)disableUpdatesFor:(NSString *)username
{
    // i.e. no longer follow
    if (!username) {
        return nil;
    }
    NSString *path = [NSString stringWithFormat:@"friendships/destroy/%@.%@", username, API_FORMAT];
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:nil body:nil 
                            requestType:MGTwitterUpdatesDisableRequest 
                           responseType:MGTwitterUser];
}


- (NSString *)isUser:(NSString *)username1 receivingUpdatesFor:(NSString *)username2
{
	if (!username1 || !username2) {
        return nil;
    }
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:username1 forKey:@"user_a"];
	[params setObject:username2 forKey:@"user_b"];
	
    NSString *path = [NSString stringWithFormat:@"friendships/exists.%@", API_FORMAT];
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:params body:nil 
                            requestType:MGTwitterUpdatesCheckRequest 
                           responseType:MGTwitterMiscellaneous];
}


#pragma mark Account methods


- (NSString *)checkUserCredentials
{
    NSString *path = [NSString stringWithFormat:@"account/verify_credentials.%@", API_FORMAT];
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:nil body:nil 
                            requestType:MGTwitterAccountRequest 
                           responseType:MGTwitterUser];
}


- (NSString *)endUserSession
{
    NSString *path = @"account/end_session"; // deliberately no format specified
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:nil body:nil 
                            requestType:MGTwitterAccountRequest 
                           responseType:MGTwitterGeneric];
}


#pragma mark -


// TODO: this API is deprecated, change to account/update_profile
- (NSString *)setLocation:(NSString *)location
{
	if (!location) {
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"account/update_location.%@", API_FORMAT];
    
    NSString *trimmedLocation = location;
    if ([trimmedLocation length] > MAX_LOCATION_LENGTH) {
        trimmedLocation = [trimmedLocation substringToIndex:MAX_LOCATION_LENGTH];
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:trimmedLocation forKey:@"location"];
    NSString *body = [self _queryStringWithBase:nil parameters:params prefixed:NO];
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path 
                        queryParameters:params body:body 
                            requestType:MGTwitterAccountLocationRequest 
                           responseType:MGTwitterUser];
}


#pragma mark -


- (NSString *)setNotificationsDeliveryMethod:(NSString *)method
{
	NSString *deliveryMethod = method;
	if (!method || [method length] == 0) {
		deliveryMethod = @"none";
	}
	
	NSString *path = [NSString stringWithFormat:@"account/update_delivery_device.%@", API_FORMAT];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (deliveryMethod) {
        [params setObject:deliveryMethod forKey:@"device"];
    }
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:params body:nil 
                            requestType:MGTwitterAccountDeliveryRequest
                           responseType:MGTwitterUser];
}


#pragma mark -


- (NSString *)getRateLimitStatus
{
	NSString *path = [NSString stringWithFormat:@"account/rate_limit_status.%@", API_FORMAT];
	
	return [self _sendRequestWithMethod:nil path:path queryParameters:nil body:nil 
                            requestType:MGTwitterAccountStatusRequest 
                           responseType:MGTwitterMiscellaneous];
}


#pragma mark Favorite methods


- (NSString *)getFavoriteUpdatesFor:(NSString *)username startingAtPage:(int)page
{
    NSString *path = [NSString stringWithFormat:@"favorites.%@", API_FORMAT];
    MGTwitterRequestType requestType = MGTwitterFavoritesRequest;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (page > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    if (username) {
        path = [NSString stringWithFormat:@"favorites/%@.%@", username, API_FORMAT];
		requestType = MGTwitterFavoritesForUserRequest;
    }
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:params body:nil 
                            requestType:requestType 
                           responseType:MGTwitterStatuses];
}


#pragma mark -


- (NSString *)markUpdate:(unsigned long)updateID asFavorite:(BOOL)flag
{
	NSString *path = nil;
	MGTwitterRequestType requestType;
	if (flag)
	{
		path = [NSString stringWithFormat:@"favorites/create/%lu.%@", updateID, API_FORMAT];
		requestType = MGTwitterFavoritesEnableRequest;
    }
	else {
		path = [NSString stringWithFormat:@"favorites/destroy/%lu.%@", updateID, API_FORMAT];
		requestType = MGTwitterFavoritesDisableRequest;
	}
	
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:nil body:nil 
                            requestType:requestType 
                           responseType:MGTwitterStatus];
}


#pragma mark Notification methods


- (NSString *)enableNotificationsFor:(NSString *)username
{
    if (!username) {
        return nil;
    }
    NSString *path = [NSString stringWithFormat:@"notifications/follow/%@.%@", username, API_FORMAT];
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:nil body:nil 
                            requestType:MGTwitterNotificationsEnableRequest 
                           responseType:MGTwitterUser];
}


- (NSString *)disableNotificationsFor:(NSString *)username
{
    if (!username) {
        return nil;
    }
    NSString *path = [NSString stringWithFormat:@"notifications/leave/%@.%@", username, API_FORMAT];
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:nil body:nil 
                            requestType:MGTwitterNotificationsDisableRequest 
                           responseType:MGTwitterUser];
}


#pragma mark Block methods


- (NSString *)block:(NSString *)username
{
	if (!username) {
		return nil;
	}
	
	NSString *path = [NSString stringWithFormat:@"blocks/create/%@.%@", username, API_FORMAT];
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:nil body:nil 
                            requestType:MGTwitterBlockEnableRequest
                           responseType:MGTwitterUser];
}


- (NSString *)unblock:(NSString *)username
{
	if (!username) {
		return nil;
	}
	
	NSString *path = [NSString stringWithFormat:@"blocks/destroy/%@.%@", username, API_FORMAT];
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:nil body:nil 
                            requestType:MGTwitterBlockDisableRequest
                           responseType:MGTwitterUser];
}


#pragma mark Help methods


- (NSString *)testService
{
	NSString *path = [NSString stringWithFormat:@"help/test.%@", API_FORMAT];
	
	return [self _sendRequestWithMethod:nil path:path queryParameters:nil body:nil 
                            requestType:MGTwitterAccountRequest
                           responseType:MGTwitterMiscellaneous];
}


- (NSString *)getDowntimeSchedule
{
	NSString *path = [NSString stringWithFormat:@"help/downtime_schedule.%@", API_FORMAT];
	
	return [self _sendRequestWithMethod:nil path:path queryParameters:nil body:nil 
                            requestType:MGTwitterAccountRequest
                           responseType:MGTwitterMiscellaneous];
}


#if YAJL_AVAILABLE

#pragma mark -
#pragma mark Search API methods
#pragma mark -


#pragma mark Search

- (NSString *)getSearchResultsForQuery:(NSString *)query
{
    return [self getSearchResultsForQuery:query sinceID:0 startingAtPage:0 count:0]; // zero means default
}


- (NSString *)getSearchResultsForQuery:(NSString *)query sinceID:(unsigned long)sinceID startingAtPage:(int)page count:(int)count
{
    return [self getSearchResultsForQuery:query sinceID:sinceID startingAtPage:0 count:0 geocode:nil]; // zero means default
}

- (NSString *)getSearchResultsForQuery:(NSString *)query sinceID:(unsigned long)sinceID startingAtPage:(int)page count:(int)count geocode:(NSString *)geocode
{
    NSString *path = [NSString stringWithFormat:@"search.%@", API_FORMAT];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	if (query) {
		[params setObject:query forKey:@"q"];
	}
    if (sinceID > 0) {
        [params setObject:[NSString stringWithFormat:@"%u", sinceID] forKey:@"since_id"];
    }
	if (page > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    if (count > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"rpp"];
    }
    if (geocode) {
        [params setObject:geocode forKey:@"geocode"];
    }
	
	/*
	NOTE: These parameters are also available but not implemented yet:
	
		lang: restricts tweets to the given language, given by an ISO 639-1 code.

			Ex: http://search.twitter.com/search.atom?lang=en&q=devo

		geocode: returns tweets by users located within a given radius of the given latitude/longitude, where the user's
			location is taken from their Twitter profile. The parameter value is specified by "latitide,longitude,radius",
			where radius units must be specified as either "mi" (miles) or "km" (kilometers).

			Note that you cannot use the near operator via the API to geocode arbitrary locations; however you can use this
			geocode parameter to search near geocodes directly.

			Ex: http://search.twitter.com/search.atom?geocode=40.757929%2C-73.985506%2C25km
	*/

	
    return [self _sendRequestWithMethod:nil path:path queryParameters:params body:nil 
                            requestType:MGTwitterSearchRequest 
                           responseType:MGTwitterSearchResults];
}


- (NSString *)getCurrentTrends
{
    NSString *path = [NSString stringWithFormat:@"trends/current.%@", API_FORMAT];
    
    return [self _sendRequestWithMethod:nil path:path queryParameters:nil body:nil 
                            requestType:MGTwitterSearchCurrentTrendsRequest 
                           responseType:MGTwitterSearchResults];
}


#endif

@end
