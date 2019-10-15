//
//  IPaOFFlickrGetContactListAPIRequest.h
//  Photogether
//
//  Created by IPaPa on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrAPIRequest.h"

@interface IPaOFFlickrGetContactListAPIRequest : IPaOFFlickrAPIRequest
-(BOOL)getContactList:(void(^)(NSData*))callback;
@end
