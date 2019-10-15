//
//  IPaURLConnection.m
//  IPaURLConnection
//
//  Created by 陳 尤中 on 11/10/27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "IPaURLConnection.h"
#import "IPaToolManager.h"
@interface IPaURLConnection ()

@end
@implementation IPaURLConnection
{
    NSMutableData* recData;
    NSURLResponse *response;
    void (^Callback)(NSURLResponse*,NSData*);
    void (^FailCallback)(NSError*);
    void (^RecCallback)(NSURLResponse*,NSData*,NSData*);
    void (^SendCallback)(NSInteger,NSInteger,NSInteger);
}
//@synthesize responseData;
//@synthesize userData;
/*+ (id)IPaURLConnectionWithURL:(NSString*)URL
 cachePolicy:(NSURLRequestCachePolicy)cachePolicy
 timeoutInterval:(NSTimeInterval)timeoutInterval
 target:(id)target
 callback:(SEL)callback
 userData:(id)userData
 {
 return [IPaURLConnection IPaURLConnectionWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval target:target callback:callback receiveCallback:nil userData:userData];
 }*/
+ (id)IPaURLConnectionWithURL:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse *,NSData *))callback
{
    return [IPaURLConnection IPaURLConnectionWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval callback:callback failCallback:nil receiveCallback:nil];
}

/*
 + (id)IPaURLConnectionWithURL:(NSString*)URL
 cachePolicy:(NSURLRequestCachePolicy)cachePolicy
 timeoutInterval:(NSTimeInterval)timeoutInterval
 target:(id)target
 callback:(SEL)callback
 {
 
 return [IPaURLConnection IPaURLConnectionWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval target:target callback:callback userData:nil];
 
 }*/
/*
 + (id)IPaURLConnectionWithURL:(NSString*)URL
 cachePolicy:(NSURLRequestCachePolicy)cachePolicy
 timeoutInterval:(NSTimeInterval)timeoutInterval
 target:(id)target
 callback:(SEL)callback
 receiveCallback:(SEL)receiveCallback
 userData:(id)userData
 {
 return [IPaURLConnection IPaURLConnectionWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval target:target callback:callback receiveCallback:receiveCallback receiveData:nil userData:userData];
 
 }*/
+ (id)IPaURLConnectionWithURL:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse*, NSData *))callback
              failCallback:(void (^)(NSError*))failCallback
{
    return [IPaURLConnection IPaURLConnectionWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval callback:callback
                                  failCallback:failCallback receiveCallback:nil];
    
}

/*+ (id)IPaURLConnectionWithURL:(NSString*)URL
 cachePolicy:(NSURLRequestCachePolicy)cachePolicy
 timeoutInterval:(NSTimeInterval)timeoutInterval
 target:(id)target
 callback:(SEL)callback
 receiveCallback:(SEL)receiveCallback
 receiveData:(NSMutableData*)receiveData
 userData:(id)userData
 {
 IPaURLConnection *newRequest = [[IPaURLConnection alloc] initWithURL:URL
 cachePolicy:cachePolicy
 timeoutInterval:timeoutInterval
 target:target
 callback:callback
 receiveCallback:receiveCallback
 reveiveData:receiveData];
 newRequest.userData = userData;
 
 [newRequest StartConnect];
 
 
 return newRequest;
 }*/
+ (id)IPaURLConnectionWithURL:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse*, NSData*))callback
              failCallback:(void (^)(NSError*))failCallback
           receiveCallback:(void (^)(NSURLResponse *,NSData*,NSData *))receiveCallback
{
    IPaURLConnection *connection = [[IPaURLConnection alloc] initWithURL:URL
                                                       cachePolicy:cachePolicy
                                                   timeoutInterval:timeoutInterval
                                                          callback:callback
                                                      failCallback:failCallback
                                                   receiveCallback:receiveCallback];
    
    [connection start];
    
    
    return connection;
}

+ (id)IPaURLConnectionWithURLRequest:(NSURLRequest*)request
                         callback:(void (^)(NSURLResponse *,NSData*))callback
                     failCallback:(void (^)(NSError*))failCallback
                  receiveCallback:(void (^)(NSURLResponse *,NSData*,NSData*))receiveCallback
{
    IPaURLConnection *connection = [[IPaURLConnection alloc] initWithURLRequest:request
                                                                 callback:callback
                                                             failCallback:failCallback
                                                          receiveCallback:receiveCallback];
    
    [connection start];
    
    
    return connection;
}


- (id)initWithURL:(NSString*)URL
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval
         callback:(void (^)(NSURLResponse*, NSData *))callback
{
    return [self initWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval callback:callback failCallback:nil receiveCallback:nil];
    
}

- (id)initWithURL:(NSString*)URL
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval
         callback:(void (^)(NSURLResponse*, NSData *))callback
     failCallback:(void (^)(NSError*))failCallback
{
    return [self initWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval callback:callback failCallback:failCallback receiveCallback:nil];
    
}

- (id)initWithURL:(NSString*)URL
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval
         callback:(void (^)(NSURLResponse*, NSData *))callback
     failCallback:(void (^)(NSError*))failCallback
  receiveCallback:(void (^)(NSURLResponse *,NSData*,NSData *))receiveCallback
{
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: URL] cachePolicy: cachePolicy timeoutInterval:timeoutInterval];
    return [self initWithURLRequest:theRequest callback:callback failCallback:failCallback receiveCallback:receiveCallback];
}


- (id)initWithURLRequest:(NSURLRequest*)request
                callback:(void (^)(NSURLResponse *,NSData*))callback
            failCallback:(void (^)(NSError*))failCallback
         receiveCallback:(void (^)(NSURLResponse *,NSData *,NSData*))receiveCallback

{
    return [self initWithURLRequest:request callback:callback failCallback:failCallback receiveCallback:receiveCallback sendCallback:nil];
}
- (id)initWithURLRequest:(NSURLRequest*)request
                callback:(void (^)(NSURLResponse *,NSData*))callback
            failCallback:(void (^)(NSError*))failCallback
         receiveCallback:(void (^)(NSURLResponse *,NSData *,NSData*))receiveCallback
            sendCallback:(void (^)(NSInteger,NSInteger,NSInteger))sendCallback
{
    self = [super initWithRequest:request delegate:self startImmediately:NO];
//
    recData = [NSMutableData data];

    
    //    responseHeader = nil;
    Callback = [callback copy];
    FailCallback = [failCallback copy];
    RecCallback = [receiveCallback copy];
    SendCallback = [sendCallback copy];
    return self;
}
-(void)dealloc {
    [self cancel];
    recData = nil;
    //    NSDictionary *responseHeader;
    response = nil;

    //    NSInvocation *Callback;
    //    NSInvocation *recCallback;
    //    id userData;
    Callback = nil;
    FailCallback = nil;
    RecCallback = nil;
    
    
}

-(void) start {
    [super start];
    [IPaToolManager RetainTool:self];
}

-(void) cancel {
    [super cancel];
    [recData setLength:0];
    [IPaToolManager ReleaseTool:self];
}
-(NSData*)receiveData
{
    return recData;
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)_response
{
    //    responseHeader = ((NSHTTPURLResponse*)response).allHeaderFields;
    response = _response;
	[recData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[recData appendData: data];
    
    if (RecCallback != nil) {
        
        /*IPaURLConnection __unsafe_unretained *selfConnect = self;
         [recCallback setArgument:&selfConnect atIndex:2];
         [recCallback setArgument:&data atIndex:3];
         [recCallback invoke];
         */
        RecCallback(response,recData,data);
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (FailCallback != nil) {
        /*BOOL result = NO;
         IPaURLConnection __unsafe_unretained *selfConnect = self;
         [Callback setArgument:&selfConnect atIndex:2];
         [Callback setArgument:&result atIndex:3];
         [Callback invoke];*/
        FailCallback(error);
        
    }
    
    [IPaToolManager ReleaseTool:self];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (Callback != nil) {
        /*BOOL result = YES;
         IPaURLConnection __unsafe_unretained *selfConnect = self;
         [Callback setArgument:&selfConnect atIndex:2];
         [Callback setArgument:&result atIndex:3];
         [Callback invoke];*/
        Callback(response,recData);
        
    }
    
    [IPaToolManager ReleaseTool:self];
}
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (SendCallback != nil) {
        SendCallback(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"Challenge !!");
}

@end
