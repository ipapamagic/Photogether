//
//  IPaOFFLickrPublicPhotoListAPIRequest.m
//  Photogether
//
//  Created by IPaPa on 12/10/19.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFLickrPublicPhotoListAPIRequest.h"
#import "FlickrPhoto.h"
@interface IPaOFFLickrPublicPhotoListAPIRequest()
@property (nonatomic,copy) void (^onGetPhotoListCB)(NSUInteger,NSUInteger,NSUInteger,NSArray*);
@property (nonatomic,copy) void (^onGetPhotoCB)(FlickrPhoto*);
@end
@implementation IPaOFFLickrPublicPhotoListAPIRequest
-(void)releaseMe
{
    self.onGetPhotoCB = nil;
    self.onGetPhotoListCB = nil;
    [super releaseMe];
}
-(BOOL)getSinglePhotoWithCallback:(void (^)(FlickrPhoto*))callback
{
    NSString *NSID = [IPaOFFlickrAPIRequest getUserNSID];
    if (NSID == nil) {
        return NO;
    }

    self.onGetPhotoListCB = nil;
    
    self.onGetPhotoCB = callback;
    if (![self callAPIMethodWithGET:@"flickr.people.getPublicPhotos" arguments:@{@"user_id":NSID,@"per_page":@"1",@"page":@"1",@"extras":@"url_sq,url_t,url_s,url_q,url_m,url_n,url_z,url_c,url_l,url_o"}]) {
        return NO;
    }
    return YES;
}
-(BOOL)getPublicPhotoListWithPage:(NSUInteger)page callback:(void (^)(NSUInteger,NSUInteger,NSUInteger,NSArray*))callback
{
    NSString *NSID = [IPaOFFlickrAPIRequest getUserNSID];
    if (NSID == nil) {
        return NO;
    }
    
//    18522167@N00   小張的id，先借來用
//#warning 這行記得要拿掉
//    NSID = @"18522167@N00";
    self.onGetPhotoListCB = callback;
    
    self.onGetPhotoCB = nil;
    if (![self callAPIMethodWithGET:@"flickr.people.getPublicPhotos" arguments:@{@"user_id":NSID,@"extras":@"url_sq,url_t,url_s,url_q,url_m,url_n,url_z,url_c,url_l,url_o"}]) {
        return NO;
    }
    return YES;
}

#pragma mark - OFFlickrAPIRequestDelegate
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{

    NSString* page = [inResponseDictionary valueForKeyPath:@"photos.page"];
    NSString* totalpages = [inResponseDictionary valueForKeyPath:@"photos.pages"];
    NSString* totalPhoto = [inResponseDictionary valueForKeyPath:@"photos.total"];
    NSArray *photos = [inResponseDictionary valueForKeyPath:@"photos.photo"];
    NSMutableArray *photoList = [@[] mutableCopy];
    for (NSDictionary *dict in photos) {
        
        FlickrPhoto *photoObj = [[FlickrPhoto alloc] initWithDictionary:dict];
        [photoList addObject:photoObj];
    }
    
    if (self.onGetPhotoCB) {
        if (photoList.count > 0) {
            self.onGetPhotoCB(photoList[0]);
        }
        else {
            self.onGetPhotoCB(nil);
        }

    }
    if (self.onGetPhotoListCB) {
        
        
        self.onGetPhotoListCB([page integerValue],[totalpages integerValue],[totalPhoto integerValue],photoList);
    }
    [super flickrAPIRequest:inRequest didCompleteWithResponse:inResponseDictionary];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    if (self.onGetPhotoListCB) {
        self.onGetPhotoListCB(1,0,0,@[]);
    }
    [super flickrAPIRequest:inRequest didFailWithError:inError];
}
@end
