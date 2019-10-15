//
//  IPaOFFlickrGetPhotoAPIRequest.m
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrGetPhotoAPIRequest.h"
#import "IPaURLConnection.h"
@interface IPaOFFlickrGetPhotoAPIRequest ()
@property (nonatomic,copy) void (^onGetImage)(UIImage*);

@end
@implementation IPaOFFlickrGetPhotoAPIRequest
{
    FLICKR_PHOTO_SIZE photoSize;
}
-(BOOL)getPhotoWithID:(NSString*)photoID withSize:(FLICKR_PHOTO_SIZE)size callback:(void (^)(UIImage*))callback
{
    self.onGetImage = callback;
    photoSize = size;

    if (![self callAPIMethodWithGET:@"flickr.photos.getSizes" arguments:@{@"photo_id":photoID}]) {
        return NO;
    }
    return YES;
}
-(void)releaseMe
{
    self.onGetImage = nil;
    [super releaseMe];
}

#pragma mark - OFFlickrAPIRequestDelegate
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{

    //取相片
    NSArray* sizeList = [inResponseDictionary valueForKeyPath:@"sizes.size"];
    NSString *labelName = @"Thumbnail";
    NSDictionary *sizeMap = @{@"Square" : @(FLICKR_PHOTO_SIZE_Square),
        @"LargeSquare":@(FLICKR_PHOTO_SIZE_LargeSquare),
        @"Thumbnail":@(FLICKR_PHOTO_SIZE_Thumbnail),
        @"Small":@(FLICKR_PHOTO_SIZE_Small),
        @"Small 320":@(FLICKR_PHOTO_SIZE_Small_320),
        @"Medium":@(FLICKR_PHOTO_SIZE_Medium),
        @"Medium 640":@(FLICKR_PHOTO_SIZE_Medium_640),
        @"Medium 800":@(FLICKR_PHOTO_SIZE_Medium_800),
        @"Large":@(FLICKR_PHOTO_SIZE_Large),
        @"Original":@(FLICKR_PHOTO_SIZE_Original)};
    switch (photoSize) {
        case FLICKR_PHOTO_SIZE_Square:
            labelName = @"Square";
            break;
        case FLICKR_PHOTO_SIZE_LargeSquare:
            labelName = @"LargeSquare";
            break;
        case FLICKR_PHOTO_SIZE_Thumbnail:
            labelName = @"Thumbnail";
            break;
        case FLICKR_PHOTO_SIZE_Small:
            labelName = @"Small";
            break;
        case FLICKR_PHOTO_SIZE_Small_320:
            labelName = @"Small 320";
            break;
        case FLICKR_PHOTO_SIZE_Medium:
            labelName = @"Medium";
            break;
        case FLICKR_PHOTO_SIZE_Medium_640:
            labelName = @"Medium 640";
            break;
        case FLICKR_PHOTO_SIZE_Medium_800:
            labelName = @"Medium 800";
            break;
        case FLICKR_PHOTO_SIZE_Large:
            labelName = @"Large";
            break;
        case FLICKR_PHOTO_SIZE_Original:
            labelName = @"Original";
            break;
        default:
            break;
    }
    
    NSString *sourceURL = nil;
    NSInteger temp = 100;
    for (NSDictionary *dict in sizeList) {
        NSString *label = dict[@"label"];
        
        NSNumber *sizeIdx = sizeMap[label];
        NSInteger result = abs(photoSize - sizeIdx.integerValue);
        if (temp > result) {
            sourceURL = dict[@"source"];
            temp = result;
            if (temp == 0) {
                break;
            }
        }
        
    }
    if (sourceURL == nil) {
        if (self.onGetImage) {
            self.onGetImage(nil);
        }

        //沒找到 結束
    }
    else {
        void (^callback)(UIImage*) = [self.onGetImage copy];
        [IPaURLConnection IPaURLConnectionWithURL:sourceURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:DEFAULT_TIME_OUT callback:^(NSURLResponse* response,NSData* data){
            callback([UIImage imageWithData:data]);
        }failCallback:^(NSError* error){
            NSLog(@"read flickr photo fail:%@",error.description);
            callback(nil);
        }];
    }

//    if (self.onGetPhotoListCB) {
//        NSString* page = [inResponseDictionary valueForKeyPath:@"photos.page"];
//        NSString* totalpages = [inResponseDictionary valueForKeyPath:@"photos.pages"];
//        NSString* totalPhoto = [inResponseDictionary valueForKeyPath:@"photos.total"];
//        NSArray *photos = [inResponseDictionary valueForKeyPath:@"photos.photo"];
//        NSMutableArray *photoList = [@[] mutableCopy];
//        for (NSDictionary *dict in photos) {
//            
//            FlickrPhoto *photoObj = [[FlickrPhoto alloc] initWithDictionary:dict];
//            [photoList addObject:photoObj];
//        }
//        
//        self.onGetPhotoListCB([page integerValue],[totalpages integerValue],[totalPhoto integerValue],photoList);
//    }
    [super flickrAPIRequest:inRequest didCompleteWithResponse:inResponseDictionary];
}
@end
