//
//  IPaOFFlickrImageULAPIRequest.m
//  PhotoShare
//
//  Created by IPaPa on 12/10/18.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaOFFlickrImageULAPIRequest.h"
@interface IPaOFFlickrImageULAPIRequest()
@property (nonatomic,copy) void (^imageUploadSentBytesCB)(NSUInteger,NSUInteger);
@property (nonatomic,copy) void (^imageDidUploadCB)(NSString*);

@end
@implementation IPaOFFlickrImageULAPIRequest
-(void)uploadImage:(UIImage*)image withTag:(NSString*)tag sentBytesCB:(void (^)(NSUInteger,NSUInteger))sentBytesCB imageDidUploadCB:(void (^)(NSString*))imageDidUploadCB failCallback:(void (^)(NSError*))failCallback
{
    self.imageDidUploadCB = imageDidUploadCB;
    self.imageUploadSentBytesCB = sentBytesCB;
    self.didFailWithErrorCB = failCallback;
    NSData *JPEGData = UIImageJPEGRepresentation(image, 1.0);
    [self uploadImageStream:[NSInputStream inputStreamWithData:JPEGData] suggestedFilename:@"" MIMEType:@"image/jpeg" arguments:@{@"is_public":@"1",@"tags":tag}];
}
-(void)releaseMe
{
    self.imageDidUploadCB = nil;
    self.imageUploadSentBytesCB = nil;
    [super releaseMe];
}
#pragma mark OFFlickrAPIRequest delegate methods
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes
{
    if (self.imageUploadSentBytesCB) {
        self.imageUploadSentBytesCB(inSentBytes,inTotalBytes);
    }
}
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    if (self.imageDidUploadCB) {
        NSString *photoID = [[inResponseDictionary valueForKeyPath:@"photoid"] textContent];
        self.imageDidUploadCB(photoID);
    }
    [super flickrAPIRequest:inRequest didCompleteWithResponse:inResponseDictionary];
}
@end
