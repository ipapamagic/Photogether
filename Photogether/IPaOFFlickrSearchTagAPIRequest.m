//
//  IPaOFFlickrSearchTagAPIRequest.m
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrSearchTagAPIRequest.h"
#import "FlickrPhoto.h"
@interface IPaOFFlickrSearchTagAPIRequest()
@property (nonatomic,copy) void (^onGetPhotoListCB)(NSUInteger,NSUInteger,NSUInteger,NSArray*);
@property (nonatomic,copy) void (^onGetPhotoCB)(FlickrPhoto*);
@end
@implementation IPaOFFlickrSearchTagAPIRequest
-(BOOL)getPhotoListWithTag:(NSString*)tagName WithPage:(NSUInteger)page NSID:(NSString*)nsid callback:(void (^)(NSUInteger,NSUInteger,NSUInteger,NSArray*))callback
{
    self.onGetPhotoListCB = callback;
    self.onGetPhotoCB = nil;
    
    if (![self callAPIMethodWithGET:@"flickr.photos.search" arguments:@{@"user_id":nsid,@"tags":tagName,@"extras":@"url_sq,url_t,url_s,url_q,url_m,url_n,url_z,url_c,url_l,url_o",@"per_page":[NSString stringWithFormat:@"%d",FLICKR_PHOTO_PER_PAGE]}]) {
        return NO;
    }
    return YES;
    
}
-(BOOL)getSinglePhotoWithTag:(NSString*)tagName callback:(void (^)(FlickrPhoto*))callback
{
    self.onGetPhotoListCB = nil;
    self.onGetPhotoCB = callback;
    
    if (![self callAPIMethodWithGET:@"flickr.photos.search" arguments:@{@"tags":tagName ,@"per_page":@"1",@"page":@"1"}]) {
        return NO;
    }
    return YES;
    
}
-(void)releaseMe
{
    self.onGetPhotoCB = nil;
    self.onGetPhotoListCB = nil;
    [super releaseMe];
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
@end
