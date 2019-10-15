//
//  IPaOFFlickrGetPhotoAPIRequest.h
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrAPIRequest.h"
#import "AppDefine.h"

@interface IPaOFFlickrGetPhotoAPIRequest : IPaOFFlickrAPIRequest
-(BOOL)getPhotoWithID:(NSString*)photoID withSize:(FLICKR_PHOTO_SIZE)size callback:(void (^)(UIImage*))callback;
@end
