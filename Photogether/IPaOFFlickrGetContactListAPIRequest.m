//
//  IPaOFFlickrGetContactListAPIRequest.m
//  Photogether
//
//  Created by IPaPa on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrGetContactListAPIRequest.h"
@interface IPaOFFlickrGetContactListAPIRequest()
@property (nonatomic,copy) void (^onGetListData)(NSData*);
@end
@implementation IPaOFFlickrGetContactListAPIRequest
-(BOOL)getContactList:(void(^)(NSData*))callback
{
    self.onGetListData = callback;
    return [self callAPIMethodWithGET:@"flickr.contacts.getList" arguments:nil];
    
}
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:inResponseDictionary
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    self.onGetListData(jsonData);
}
-(void)releaseMe
{
    self.onGetListData = nil;
    [super releaseMe];
}
@end
