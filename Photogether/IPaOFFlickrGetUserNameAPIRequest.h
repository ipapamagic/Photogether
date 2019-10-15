//
//  IPaOFFlickrGetUserNameAPIRequest.h
//  Photogether
//
//  Created by IPaPa on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrAPIRequest.h"

@interface IPaOFFlickrGetUserNameAPIRequest : IPaOFFlickrAPIRequest
-(BOOL)getUserNameWithNSID:(NSString*)NSID callback:(void (^)(NSString*))callback;
@end
