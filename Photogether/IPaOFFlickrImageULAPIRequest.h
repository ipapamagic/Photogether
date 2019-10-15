//
//  IPaOFFlickrImageULAPIRequest.h
//  PhotoShare
//
//  Created by IPaPa on 12/10/18.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrAPIRequest.h"
//上傳圖片用的Request
@interface IPaOFFlickrImageULAPIRequest : IPaOFFlickrAPIRequest

-(void)uploadImage:(UIImage*)image withTag:(NSString*)tag sentBytesCB:(void (^)(NSUInteger,NSUInteger))sentBytesCB imageDidUploadCB:(void (^)(NSString*))imageDidUploadCB failCallback:(void (^)(NSError*))failCallback;

@end
