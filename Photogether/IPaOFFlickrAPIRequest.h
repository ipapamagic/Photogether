//
//  IPaOFFlickrAPIRequest.h
//  PhotoShare
//
//  Created by IPaPa on 12/10/17.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "ObjectiveFlickr.h"
#import "AppDefine.h"
//Flickr Request state
//#define kFetchRequestTokenStep @"kFetchRequestTokenStep"
//#define kGetAccessTokenStep @"kGetAccessTokenStep"
//#define kCheckTokenStep @"kCheckTokenStep"
//#define kUploadImageStep @"kUploadImageStep"
////NSString *kGetUserInfoStep = @"kGetUserInfoStep";
//#define kSetImagePropertiesStep @"kSetImagePropertiesStep"
//#define kCreateGalleryStep @"kCreateGalleryStep"
#define PHOTOSHARE_URL_SCHEMA @"photoshare://auth"
@class IPaOFFlickrImageULAPIRequest;
@class FlickrPhoto;
@interface IPaOFFlickrAPIRequest : OFFlickrAPIRequest<OFFlickrAPIRequestDelegate>


//@property (nonatomic,copy) void (^didCompleteWithResponseCB)(NSDictionary*);
@property (nonatomic,copy) void (^didFailWithErrorCB)(NSError*);


//登入
+(void)doLogin:(void (^)(BOOL)) callback;
//判斷是否已登入
+(BOOL)isLogin;
//取得目前使用者Flickr的NSID
+(NSString*)getUserNSID;

//取得使用者名稱
+(NSString*)getUserName;
//取得token
+(NSString*)getFlickrAuth;

+(BOOL)getPhotoWithID:(NSString*)photoID withSize:(FLICKR_PHOTO_SIZE)photoSize callback:(void (^)(UIImage*))callback;

//取得照片列表，callback回傳參數是,(目前頁數，全部的頁數，全部的照片，照片列表)
+(BOOL)getPublicPhotoListWithPage:(NSUInteger)page callback:(void (^)(NSUInteger,NSUInteger,NSUInteger,NSArray*))callback;
//取得單張photo照片，使用者的任何一張photo
+(BOOL)getSinglePhotoWithCallback:(void (^)(FlickrPhoto*))callback;


//取得指定tag的照片列表
+(BOOL)getFlickrPhotoListWithTag:(NSString*)tagName NSID:(NSString*)nsid WithPage:(NSUInteger)page callback:(void (^)(NSUInteger,NSUInteger,NSUInteger,NSArray*))callback;
//取得單張圖片
+(BOOL)getSinglePhotoWithTag:(NSString*)tagName withSize:(FLICKR_PHOTO_SIZE)photoSize callback:(void (^)(FlickrPhoto*))callback;
+(BOOL)handleFlickrOpenURL:(NSURL*)url;
//上傳照片的callback
+(IPaOFFlickrImageULAPIRequest*)uploadImage:(UIImage*)image withTag:(NSString*)tag sentBytesCB:(void (^)(NSUInteger,NSUInteger))sentBytesCB imageDidUploadCB:(void (^)(NSString*))imageDidUploadCB failCallback:(void (^)(NSError*))failCallback;
//下面是給繼承用的class來取用的，請不要使用
+ (OFFlickrAPIContext *)flickrContext;
//取得Flickr 使用者頭像
+(void)getFlickrUserBuddyIcon:(NSString*)NSID callback:(void (^)(UIImage*))callback;
-(void)releaseMe;

+(BOOL)getContactList:(void (^)(NSData*))callback;
//將相片加入相本
+(BOOL)addPhotoID:(NSString*)photoID withTag:(NSString*)tagName callback:(void (^)(BOOL))callback;
//取得使用者名稱
+(BOOL)getUserNameWithNSID:(NSString*)NSID callback:(void (^)(NSString*))callback;
@end
