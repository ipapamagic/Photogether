//
//  IPaOFFlickrSearchTagAPIRequest.h
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrAPIRequest.h"
@class FlickrPhoto;
@interface IPaOFFlickrSearchTagAPIRequest : IPaOFFlickrAPIRequest
-(BOOL)getPhotoListWithTag:(NSString*)tagName WithPage:(NSUInteger)page NSID:(NSString*)nsid callback:(void (^)(NSUInteger,NSUInteger,NSUInteger,NSArray*))callback;
-(BOOL)getSinglePhotoWithTag:(NSString*)tagName callback:(void (^)(FlickrPhoto*))callback;
@end
