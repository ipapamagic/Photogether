//
//  IPaOFFlickrPhotoAddTagAPIRequest.m
//  Photogether
//
//  Created by IPaPa on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrPhotoAddTagAPIRequest.h"
@interface IPaOFFlickrPhotoAddTagAPIRequest()
@property (nonatomic,copy) void (^onCallback)(BOOL);
@end
@implementation IPaOFFlickrPhotoAddTagAPIRequest
-(BOOL)addPhotoID:(NSString*)photoID withTag:(NSString*)tagName callback:(void (^)(BOOL))callback
{
    self.onCallback = callback;
    
    return [self callAPIMethodWithGET:@"flickr.photos.addTags" arguments:@{@"photo_id":photoID,@"tags":tagName}];
}
-(void)releaseMe
{
    self.onCallback = nil;
    [super releaseMe];
}
#pragma mark OFFlickrAPIRequest delegate methods

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    BOOL ret = [[inResponseDictionary valueForKeyPath:@"rsp.stat"] isEqualToString:@"ok"];
    if (self.onCallback)
    {
        self.onCallback(ret);
    }
    [super flickrAPIRequest:inRequest didCompleteWithResponse:inResponseDictionary];
}

@end
