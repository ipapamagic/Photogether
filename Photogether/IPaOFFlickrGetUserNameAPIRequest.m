//
//  IPaOFFlickrGetUserNameAPIRequest.m
//  Photogether
//
//  Created by IPaPa on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrGetUserNameAPIRequest.h"
@interface IPaOFFlickrGetUserNameAPIRequest()
@property(nonatomic,copy) void (^onGetUserName)(NSString*);
@end
@implementation IPaOFFlickrGetUserNameAPIRequest
-(BOOL)getUserNameWithNSID:(NSString*)NSID callback:(void (^)(NSString*))callback
{
    self.onGetUserName = callback;
    return [self callAPIMethodWithGET:@"flickr.people.getInfo" arguments:@{@"user_id":NSID}];
}

-(void)releaseMe
{
    self.onGetUserName = nil;
    [super releaseMe];
}
#pragma mark OFFlickrAPIRequest delegate methods

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
//    id Value = [inResponseDictionary valueForKeyPath:@"person.username"];
    NSString *userName = [inResponseDictionary valueForKeyPath:@"person.username._text"];

    if (self.onGetUserName)
    {
        self.onGetUserName(userName);
    }
    [super flickrAPIRequest:inRequest didCompleteWithResponse:inResponseDictionary];
}
@end
