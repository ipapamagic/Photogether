//
//  IPaOFFlickrAuthAPIRequest.h
//  PhotoShare
//
//  Created by IPaPa on 12/10/18.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrAPIRequest.h"

@interface IPaOFFlickrAuthAPIRequest : IPaOFFlickrAPIRequest
//inAccessToken inSecret inFullName inUserName inNSID
-(void)doLogin:(void (^)(NSString *,NSString *,NSString *,NSString *)) callback failCallback:(void (^)(NSError*)) failCallback;
@end
