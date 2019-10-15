//
//  IPaOFFlickrAuthAPIRequest.m
//  PhotoShare
//
//  Created by IPaPa on 12/10/18.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrAuthAPIRequest.h"
@interface IPaOFFlickrAuthAPIRequest()
@property (nonatomic,copy) void (^didObtainOAuthAccessTokenCB)(NSString *,NSString *,NSString *,NSString *);
@end
@implementation IPaOFFlickrAuthAPIRequest
-(void)releaseMe
{
    self.didObtainOAuthAccessTokenCB = nil;
    [super releaseMe];
}
-(void)doLogin:(void (^)(NSString *,NSString *,NSString *,NSString *)) callback failCallback:(void (^)(NSError*)) failCallback
{
    self.didObtainOAuthAccessTokenCB = callback;
    self.didFailWithErrorCB = failCallback;
    OFFlickrAPIContext *flickrContext = self.context;

    if ([flickrContext.OAuthToken length] > 0) {
        //Token已存在，直接登入
        
        if (![self callAPIMethodWithGET:@"flickr.test.login" arguments:nil])
        {
            if (failCallback) {
                NSLog(@"flickr request api test login fail..!");
                failCallback(nil);
                [self releaseMe];
            }
        }
    }
    else {

        if (![self fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:PHOTOSHARE_URL_SCHEMA]])
        {
            if (failCallback) {
                NSLog(@"flickr request api login fail..!");
                failCallback(nil);
                [self releaseMe];
            }
        }
    }
}
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    //check 登入，才會到這裡
    NSString *userName = [inResponseDictionary valueForKeyPath:@"user.username._text"];
    NSString *NSID = [inResponseDictionary valueForKeyPath:@"user.id"];

    if (self.didObtainOAuthAccessTokenCB != nil) {
        self.didObtainOAuthAccessTokenCB(self.context.OAuthToken,self.context.OAuthTokenSecret,userName,NSID);
    }
    [super flickrAPIRequest:inRequest didCompleteWithResponse:inResponseDictionary];
}
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID
{
    if (self.didObtainOAuthAccessTokenCB != nil) {
        self.didObtainOAuthAccessTokenCB(inAccessToken,inSecret,inUserName,inNSID);
    }
    
}
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret
{
    // these two lines are important
    self.context.OAuthToken = inRequestToken;
    self.context.OAuthTokenSecret = inSecret;
    
    NSURL *authURL = [self.context userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    [[UIApplication sharedApplication] openURL:authURL];
}
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    NSLog(@"IPaOFFlickrAuthAPIRequest......api fail....");
    [super flickrAPIRequest:inRequest didFailWithError:inError];
}
@end
