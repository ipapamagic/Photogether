//
//  FlickrPhoto.m
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "FlickrPhoto.h"
#import "IPaURLConnection.h"
@interface FlickrPhoto ()
@property (nonatomic,readwrite) NSString *photoID;
@property (nonatomic,readwrite) NSString *owner;
@end
@implementation FlickrPhoto
{
    NSMutableDictionary *photoURLList;
}
-(id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    self.photoID = [dict[@"id"] copy];
    self.owner = [dict[@"owner"] copy];
//    self.url_sq = dict[@"url_sq"];
//    self.sq_ImgSize = CGSizeMake([dict[@"width_sq"] floatValue], [dict[@"height_sq"] floatValue]);
    photoURLList = [@{} mutableCopy];
    NSString *urlString = dict[@"url_sq"];
    if (urlString != nil) {
        photoURLList[@(FLICKR_PHOTO_SIZE_Square)] = @{@"width" : dict[@"width_sq"],
                                                        @"height":dict[@"height_sq"],
                                                        @"url":urlString};
    }
    urlString = dict[@"url_t"];
    if (urlString != nil) {
        photoURLList[@(FLICKR_PHOTO_SIZE_Thumbnail)] = @{@"width" : dict[@"width_t"],
                                                    @"height":dict[@"height_t"],
                                                    @"url":urlString};
    }
    urlString = dict[@"url_t"];
    if (urlString != nil) {
        photoURLList[@(FLICKR_PHOTO_SIZE_Thumbnail)] = @{@"width" : dict[@"width_t"],
        @"height":dict[@"height_t"],
        @"url":urlString};
    }
    urlString = dict[@"url_s"];
    if (urlString != nil) {
        photoURLList[@(FLICKR_PHOTO_SIZE_Small)] = @{@"width" : dict[@"width_s"],
        @"height":dict[@"height_s"],
        @"url":urlString};
    }
    urlString = dict[@"url_q"];
    if (urlString != nil) {
        photoURLList[@(FLICKR_PHOTO_SIZE_LargeSquare)] = @{@"width" : dict[@"width_q"],
        @"height":dict[@"height_q"],
        @"url":urlString};
    }
    urlString = dict[@"url_m"];
    if (urlString != nil) {
        photoURLList[@(FLICKR_PHOTO_SIZE_Medium)] = @{@"width" : dict[@"width_m"],
        @"height":dict[@"height_m"],
        @"url":urlString};
    }
    urlString = dict[@"url_n"];
    if (urlString != nil) {
        photoURLList[@(FLICKR_PHOTO_SIZE_Small_320)] = @{@"width" : dict[@"width_n"],
        @"height":dict[@"height_n"],
        @"url":urlString};
    }
    urlString = dict[@"url_z"];
    if (urlString != nil) {
        photoURLList[@(FLICKR_PHOTO_SIZE_Medium_640)] = @{@"width" : dict[@"width_z"],
        @"height":dict[@"height_z"],
        @"url":urlString};
    }
    urlString = dict[@"url_c"];
    if (urlString != nil) {
        photoURLList[@(FLICKR_PHOTO_SIZE_Medium_800)] = @{@"width" : dict[@"width_c"],
        @"height":dict[@"height_c"],
        @"url":urlString};
    }
    urlString = dict[@"url_l"];
    if (urlString != nil) {
        photoURLList[@(FLICKR_PHOTO_SIZE_Large)] = @{@"width" : dict[@"width_l"],
        @"height":dict[@"height_l"],
        @"url":urlString};
    }
    urlString = dict[@"url_o"];
    if (urlString != nil) {
        photoURLList[@(FLICKR_PHOTO_SIZE_Original)] = @{@"width" : dict[@"width_o"],
        @"height":dict[@"height_o"],
        @"url":urlString};
    }


    return self;
}
//取得大小最接近的資料
-(NSDictionary*)getNearestSizeKey:(FLICKR_PHOTO_SIZE)photoSize
{
    NSDictionary *data = photoURLList[@(photoSize)];
    if (data == nil) {
        NSInteger temp = 100;
        
        for (NSNumber *sizeKey in photoURLList.allKeys) {
            NSInteger result = abs([sizeKey integerValue] - photoSize);
            if (temp > result) {
                data = photoURLList[sizeKey];
            }
        }
    }
    return data;
}
//取得最大照片的url
-(NSString*)getMaxImageURL
{
    NSDictionary *data = [self getNearestSizeKey:FLICKR_PHOTO_SIZE_Original];
    return data[@"url"];
}
-(void)getImageWithSize:(FLICKR_PHOTO_SIZE)photoSize callback:(void (^)(UIImage*))callback
{
    NSDictionary *data = [self getNearestSizeKey:photoSize];
    NSString *url = data[@"url"];
    
    
    [IPaURLConnection IPaURLConnectionWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:DEFAULT_TIME_OUT callback:^(NSURLResponse* response,NSData* data){
        callback([UIImage imageWithData:data]);
        
    }failCallback:^(NSError* error){
        NSLog(@"FlickrPhoto get photo connection fail:%@",error);
    }];
}
-(NSString*)getImageURLWithSize:(FLICKR_PHOTO_SIZE)photoSize
{
    NSDictionary *data = [self getNearestSizeKey:photoSize];
    return data[@"url"];
}
@end
