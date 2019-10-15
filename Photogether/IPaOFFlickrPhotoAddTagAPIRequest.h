//
//  IPaOFFlickrPhotoAddTagAPIRequest.h
//  Photogether
//
//  Created by IPaPa on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrAPIRequest.h"

@interface IPaOFFlickrPhotoAddTagAPIRequest : IPaOFFlickrAPIRequest
-(BOOL)addPhotoID:(NSString*)photoID withTag:(NSString*)tagName callback:(void (^)(BOOL))callback;
@end
