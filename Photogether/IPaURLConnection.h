//
//  IPaURLConnection.h
//  IPaURLConnection
//
//  Created by 陳 尤中 on 11/10/27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
// callback format is    - (void) xxxxxx : (IPaURLConnection*)sender:sender isSucceed:(BOOL)isSucceed;

#import <Foundation/Foundation.h>

@interface IPaURLConnection : NSURLConnection <NSURLConnectionDelegate,NSURLConnectionDataDelegate> {
    

  
}
@property (nonatomic,readonly) NSData* receiveData;

- (id)initWithURL:(NSString*)URL
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval
         callback:(void (^)(NSURLResponse *,NSData*))callback;

- (id)initWithURL:(NSString*)URL
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval
         callback:(void (^)(NSURLResponse *,NSData*))callback
     failCallback:(void (^)(NSError*))failCallback;

- (id)initWithURL:(NSString*)URL
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval
         callback:(void (^)(NSURLResponse *,NSData*))callback
     failCallback:(void (^)(NSError*))failCallback
  receiveCallback:(void (^)(NSURLResponse *,NSData*,NSData*))receiveCallback;


- (id)initWithURLRequest:(NSURLRequest*)request
                callback:(void (^)(NSURLResponse *,NSData*))callback
            failCallback:(void (^)(NSError*))failCallback
         receiveCallback:(void (^)(NSURLResponse *,NSData *,NSData*))receiveCallback;


- (id)initWithURLRequest:(NSURLRequest*)request
                callback:(void (^)(NSURLResponse *,NSData*))callback
            failCallback:(void (^)(NSError*))failCallback
         receiveCallback:(void (^)(NSURLResponse *,NSData *,NSData*))receiveCallback
            sendCallback:(void (^)(NSInteger,NSInteger,NSInteger))sendCallback;


+ (id)IPaURLConnectionWithURL:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse *,NSData*))callback;

+ (id)IPaURLConnectionWithURL:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse *,NSData*))callback
              failCallback:(void (^)(NSError*))failCallback;

+ (id)IPaURLConnectionWithURL:(NSString*)URL
               cachePolicy:(NSURLRequestCachePolicy)cachePolicy
           timeoutInterval:(NSTimeInterval)timeoutInterval
                  callback:(void (^)(NSURLResponse *,NSData* ))callback
              failCallback:(void (^)(NSError*))failCallback
           receiveCallback:(void (^)(NSURLResponse *,NSData*,NSData* ))receiveCallback;




+ (id)IPaURLConnectionWithURLRequest:(NSURLRequest*)request
                         callback:(void (^)(NSURLResponse *,NSData*))callback
                     failCallback:(void (^)(NSError*))failCallback
                     receiveCallback:(void (^)(NSURLResponse *,NSData*,NSData*))receiveCallback;



@end
