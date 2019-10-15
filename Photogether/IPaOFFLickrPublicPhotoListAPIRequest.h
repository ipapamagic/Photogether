//
//  IPaOFFLickrPublicPhotoListAPIRequest.h
//  Photogether
//
//  Created by IPaPa on 12/10/19.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrAPIRequest.h"

@interface IPaOFFLickrPublicPhotoListAPIRequest : IPaOFFlickrAPIRequest
-(BOOL)getPublicPhotoListWithPage:(NSUInteger)page callback:(void (^)(NSUInteger,NSUInteger,NSUInteger,NSArray*))callback;

-(BOOL)getSinglePhotoWithCallback:(void (^)(FlickrPhoto*))callback;
@end
