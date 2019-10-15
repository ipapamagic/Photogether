//
//  IPaOFFlickrAPIRequest.m
//  PhotoShare
//
//  Created by IPaPa on 12/10/17.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrAPIRequest.h"
#import "IPaAlertView.h"
#import "IPaKeyChain.h"
#import "IPaOFFlickrAuthAPIRequest.h"
#import "IPaOFFlickrImageULAPIRequest.h"
#import "IPaOFFLickrPublicPhotoListAPIRequest.h"
#import "IPaOFFlickrSearchTagAPIRequest.h"
#import "IPaOFFlickrGetPhotoAPIRequest.h"
#import "IPaOFFlickrGetContactListAPIRequest.h"
#import "IPaOFFlickrPhotoAddTagAPIRequest.h"
#import "IPaURLConnection.h"
#import "FlickrPhoto.h"
#import "IPaOFFlickrPhotoAddTagAPIRequest.h"
#import "IPaOFFlickrGetUserNameAPIRequest.h"
#define OBJECTIVE_FLICKR_API_KEY             @"a91818bcf3af0594fb7d9b995917ed9a"
#define OBJECTIVE_FLICKR_API_SHARED_SECRET   @"5244d6dded596d23"
#define OBJECTIVE_FLICKR_TOKEN_KEYCHAIN_NAME @"com.photogether.authToken"
#define OBJECTIVE_FLICKR_TOKEN_SEC_KEYCHAIN_NAME @"com.photogether.authTokenSecret"
#define OBJECTIVE_FLICKR_NSID @"com.photogether.nsid"
#define OBJECTIVE_FLICKR_USERNAME @"@com.photogether.username"
#define FLICKR_USER_BUDDYICON_API @"http://flickr.com/buddyicons/%@.jpg"

NSMutableArray* IPaFlickrAPIRequestList;
IPaOFFlickrAPIRequest *defaultAPIRequest;
@interface IPaOFFlickrAPIRequest()
@end
@implementation IPaOFFlickrAPIRequest
+(void)newRequest:(IPaOFFlickrAPIRequest*)request
{
    if (IPaFlickrAPIRequestList == nil) {
        IPaFlickrAPIRequestList = [@[] mutableCopy];
    }
    if ([IPaFlickrAPIRequestList indexOfObject:request] == NSNotFound)
    {
        [IPaFlickrAPIRequestList addObject:request];
    }
}
+(void)removeRequest:(IPaOFFlickrAPIRequest*)request
{
    [IPaFlickrAPIRequestList removeObject:request];
}
+ (OFFlickrAPIContext *)flickrContext
{
    static OFFlickrAPIContext *flickrContext = nil;
    if (flickrContext == nil) {
        flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_API_KEY sharedSecret:OBJECTIVE_FLICKR_API_SHARED_SECRET];
        NSString *authToken = [IPaKeyChain load:OBJECTIVE_FLICKR_TOKEN_KEYCHAIN_NAME];
        NSString *authTokenSecret = [IPaKeyChain load:OBJECTIVE_FLICKR_TOKEN_SEC_KEYCHAIN_NAME];
        if (([authToken length] > 0) && ([authTokenSecret length] > 0)) {
            flickrContext.OAuthToken = authToken;
            flickrContext.OAuthTokenSecret = authTokenSecret;
        }
    }
    
    return flickrContext;
}

-(id)initNewRequest
{
    self = [super initWithAPIContext:[IPaOFFlickrAPIRequest flickrContext]];
    self.delegate = self;
    self.requestTimeoutInterval = 60.0;
    [IPaOFFlickrAPIRequest newRequest:self];
    return self;
}
-(void)releaseMe
{
    self.didFailWithErrorCB = nil;
    [IPaOFFlickrAPIRequest removeRequest:self];
    
}
+ (void)setAndStoreFlickrAuthToken:(NSString *)inAuthToken secret:(NSString *)inSecret NSID:(NSString*)NSID userName:(NSString*)userName
{
    OFFlickrAPIContext *flickrContext = [self flickrContext];
	if (![inAuthToken length] || ![inSecret length]) {
		flickrContext.OAuthToken = nil;
        flickrContext.OAuthTokenSecret = nil;
		[IPaKeyChain delete:OBJECTIVE_FLICKR_TOKEN_KEYCHAIN_NAME];
		[IPaKeyChain delete:OBJECTIVE_FLICKR_TOKEN_SEC_KEYCHAIN_NAME];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:OBJECTIVE_FLICKR_NSID];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:OBJECTIVE_FLICKR_USERNAME];
        
        
        //        [IPaKeyChain delete:OBJECTIVE_FLICKR_NSID_KEYCHAIN_NAME];
	}
	else {
        //		flickrContext.OAuthToken = inAuthToken;
        //        flickrContext.OAuthTokenSecret = inSecret;
        //        NSLog(@"inSecret :%@",inSecret);
        [IPaKeyChain save:OBJECTIVE_FLICKR_TOKEN_KEYCHAIN_NAME data:inAuthToken];
        [IPaKeyChain save:OBJECTIVE_FLICKR_TOKEN_SEC_KEYCHAIN_NAME data:inSecret];
        //        [IPaKeyChain save:OBJECTIVE_FLICKR_NSID_KEYCHAIN_NAME data:NSID];
        
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:OBJECTIVE_FLICKR_USERNAME];
        [[NSUserDefaults standardUserDefaults] setObject:NSID forKey:OBJECTIVE_FLICKR_NSID];
        
	}
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(BOOL)isLogin
{
    OFFlickrAPIContext *flickrContext = [IPaOFFlickrAPIRequest flickrContext];
    
    return ([flickrContext.OAuthToken length] > 0);
}
+(void)doLogin:(void (^)(BOOL)) callback
{
    if (defaultAPIRequest != nil) {
        NSLog(@"Flickr Request is busy now!");
        callback(NO);
        return ;
    }
    NSString *NSID = [[NSUserDefaults standardUserDefaults] objectForKey:OBJECTIVE_FLICKR_NSID];
    if (NSID == nil) {
        //第一次開啟(或是重新安裝也算，要把keychain內的資料清除)
        [self setAndStoreFlickrAuthToken:nil secret:nil NSID:nil userName:nil];
    }
    IPaOFFlickrAuthAPIRequest *authRequest = [[IPaOFFlickrAuthAPIRequest alloc] initNewRequest];
    defaultAPIRequest = authRequest;
    [authRequest doLogin:^(NSString* inAccessToken ,NSString *inSecret,NSString *inUserName ,NSString *inNSID){
        [self setAndStoreFlickrAuthToken:inAccessToken secret:inSecret NSID:inNSID userName:inUserName];
        defaultAPIRequest = nil;
        callback(YES);
    }failCallback:^(NSError* error){
        NSLog(@"Flickr API login fail...!");
        [self setAndStoreFlickrAuthToken:nil secret:nil NSID:nil userName:nil];
        defaultAPIRequest = nil;
        callback(NO);
    }];
}
+(BOOL)handleFlickrOpenURL:(NSURL*)url
{
    if (defaultAPIRequest == nil) {
        return NO;
    }
    NSAssert([defaultAPIRequest isKindOfClass:[IPaOFFlickrAuthAPIRequest class]], @"auth api request not exist!!");
    
    
    NSString *token = nil;
    NSString *verifier = nil;
    BOOL result = OFExtractOAuthCallback(url, [NSURL URLWithString:PHOTOSHARE_URL_SCHEMA], &token, &verifier);
    
    if (!result) {
        NSLog(@"Cannot obtain token/secret from URL: %@", [url absoluteString]);
        return NO;
    }
    
    
    [defaultAPIRequest fetchOAuthAccessTokenWithRequestToken:token verifier:verifier];
    
    return YES;
}

+(IPaOFFlickrImageULAPIRequest*)uploadImage:(UIImage*)image withTag:(NSString*)tag sentBytesCB:(void (^)(NSUInteger,NSUInteger))sentBytesCB imageDidUploadCB:(void (^)(NSString*))imageDidUploadCB failCallback:(void (^)(NSError*))failCallback
{
    IPaOFFlickrImageULAPIRequest *request = [[IPaOFFlickrImageULAPIRequest alloc] initNewRequest];
    [request uploadImage:image withTag:tag sentBytesCB:sentBytesCB imageDidUploadCB:imageDidUploadCB failCallback:failCallback];
    return request;
}
+(BOOL)getPublicPhotoListWithPage:(NSUInteger)page callback:(void (^)(NSUInteger,NSUInteger,NSUInteger,NSArray*))callback
{
    IPaOFFLickrPublicPhotoListAPIRequest *request = [[IPaOFFLickrPublicPhotoListAPIRequest alloc] initNewRequest];
    
    return [request getPublicPhotoListWithPage:page callback:callback];
}
+(BOOL)getSinglePhotoWithCallback:(void (^)(FlickrPhoto*))callback
{
    IPaOFFLickrPublicPhotoListAPIRequest *request = [[IPaOFFLickrPublicPhotoListAPIRequest alloc] initNewRequest];
    return [request getSinglePhotoWithCallback:callback];
    
}

+(BOOL)getFlickrPhotoListWithTag:(NSString*)tagName NSID:(NSString*)nsid WithPage:(NSUInteger)page callback:(void (^)(NSUInteger,NSUInteger,NSUInteger,NSArray*))callback
{
    IPaOFFlickrSearchTagAPIRequest *request = [[IPaOFFlickrSearchTagAPIRequest alloc] initNewRequest];
    
//    NSArray* array2 = [[NSArray alloc] initWithObjects:[IPaOFFlickrAPIRequest getUserNSID], nil];
    
    return [request getPhotoListWithTag:tagName WithPage:page NSID:nsid callback:callback];
}
+(NSString*)getUserName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:OBJECTIVE_FLICKR_USERNAME];
}
+(NSString*)getUserNSID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:OBJECTIVE_FLICKR_NSID];
}
+(NSString*)getFlickrAuth
{
    return [self flickrContext].OAuthToken;
}
+(void)getFlickrUserBuddyIcon:(NSString*)NSID callback:(void (^)(UIImage*))callback
{
    NSString* urlString = [NSString stringWithFormat:FLICKR_USER_BUDDYICON_API,NSID];
    
    IPaURLConnection *urlConnection = [[IPaURLConnection alloc] initWithURL:urlString cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20 callback:^(NSURLResponse* response,NSData* data){
        UIImage *image = [[UIImage alloc] initWithData:data];
        callback(image);
    }failCallback:^(NSError* error){
        callback(nil);
    }];
    
    [urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                             forMode:NSRunLoopCommonModes];
    [urlConnection start];
    
    
}
+(BOOL)getPhotoWithID:(NSString*)photoID withSize:(FLICKR_PHOTO_SIZE)photoSize callback:(void (^)(UIImage*))callback
{
    IPaOFFlickrGetPhotoAPIRequest *request = [[IPaOFFlickrGetPhotoAPIRequest alloc] initNewRequest];
    return [request getPhotoWithID:photoID withSize:photoSize callback:callback];
    
}
+(BOOL)getSinglePhotoWithTag:(NSString*)tagName withSize:(FLICKR_PHOTO_SIZE)photoSize callback:(void (^)(FlickrPhoto*))callback
{
    IPaOFFlickrSearchTagAPIRequest *request = [[IPaOFFlickrSearchTagAPIRequest alloc] initNewRequest];
    return [request getSinglePhotoWithTag:tagName callback:callback];
    
}
+(BOOL)getContactList:(void (^)(NSData*))callback
{
    IPaOFFlickrGetContactListAPIRequest *request = [[IPaOFFlickrGetContactListAPIRequest alloc] initNewRequest];
    
    return [request getContactList:callback];
}
+(BOOL)addPhotoID:(NSString*)photoID withTag:(NSString*)tagName callback:(void (^)(BOOL))callback
{
    IPaOFFlickrPhotoAddTagAPIRequest *request = [[IPaOFFlickrPhotoAddTagAPIRequest alloc] initNewRequest];
    return [request addPhotoID:photoID withTag:tagName callback:callback];
    
}
+(BOOL)getUserNameWithNSID:(NSString*)NSID callback:(void (^)(NSString*))callback
{
    IPaOFFlickrGetUserNameAPIRequest *request = [[IPaOFFlickrGetUserNameAPIRequest alloc] initNewRequest];
    
    return [request getUserNameWithNSID:NSID callback:callback];
}
#pragma mark OFFlickrAPIRequest delegate methods

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    [self releaseMe];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    
    if (self.didFailWithErrorCB) {
        self.didFailWithErrorCB(inError);
    }
    NSLog(@"%@ api fail",self);
    [IPaAlertView IPaAlertViewWithTitle:@"Flickr API Failed!" message:[inError description] cancelButtonTitle:@"確定"];
    [self releaseMe];
}
-(void)cancel
{
    [super cancel];
    [self releaseMe];
}



@end
