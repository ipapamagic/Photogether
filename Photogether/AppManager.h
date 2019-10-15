//
//  AppManager.h
//  PhotoShare
//
//  Created by IPaPa on 12/10/14.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppDefine.h"
@class ALAssetsLibrary;
@class FlickrPhoto;
@interface AppManager : NSObject

//ben add
+ (void) SendLocationLat:(float)lat Lon:(float)lon UserID:(NSString*)uid callback:(void (^)(BOOL))callback;

/////

//登入Flickr
+(void)doFlickrLogin:(void (^)(BOOL))callback;
+(BOOL)handleFlickrOpenURL:(NSURL*)url;
//建立相本
//+(void)createAlbumWithName:(NSString*)name callback:(void (^)(BOOL))callback;
+(void)createAlbumWithName:(NSString*)name callback:(void (^)(NSString*))callback;
//上傳相片到相本內
+(NSUInteger)uploadImage:(UIImage*)image toAlbumName:(NSString*)albumName;
//取得Flickr public的照片 callback 參數是 current pages,total pages,total photocount,照片資料列表
+(void)getPublicPhotoListWithPage:(NSUInteger)page callback:(void (^)(NSUInteger,NSUInteger,NSUInteger,NSArray*))callback;
//取得使用者任意單張照片
+(void)getSinglePhotoWithCallback:(void (^)(FlickrPhoto*))callback;

//取得assetLibrary
+(ALAssetsLibrary *)assetLibrary;
//取得album list
+(void)getAlbumList:(void (^)(NSArray*))callback;

//判斷Flickr是否已登入
+(BOOL)isFlickrLogin;
//取得相本內相簿列表
//取得指定相簿的照片 callback 參數是 current pages,total pages,total photocount,照片資料列表
+(void)getFlickrPhotoListInAlbum:(NSString*)albumName NSID:(NSString*)nsid WithPage:(NSUInteger)page callback:(void (^)(NSUInteger,NSUInteger,NSUInteger,NSArray*))callback;
//取得朋友名單
+(void)getFriendList:(void (^)(NSArray*))callback;
//分享相本給朋友
+(void)shareAlbum:(NSString*)albumName withFriends:(NSArray*)friendList callback:(void (^)(BOOL))callback;
//取得照片
+(void)getFlickrWithPhotoID:(NSString*)photoID withSize:(FLICKR_PHOTO_SIZE)photoSize callback:(void (^)(UIImage*))callback;
//取得相片的封面
+(void)getAlbumTitlePhoto:(NSString*)albumName callback:(void (^)(FlickrPhoto*))callback;

//取得上傳中的檔案數量
+(NSUInteger)getUploadingNum;
+(NSArray*)getUploadingIDList;
//取得下載中的檔案數量
+(NSUInteger)getDownloadingNum;
+(NSArray*)getDownloadingIDList;

//下載最大照片
+(NSUInteger)downloadImage:(FlickrPhoto*)photoData;
//將Flickr照片加入相本
+(void)addPhotoID:(NSString*)photoID toAlbumName:(NSString*)albumName callback:(void (^)(BOOL))callback;
//取得使用者名稱
+(void)getUserNameWithNSID:(NSString*)NSID callback:(void (^)(NSString*))callback;

//取得下載目錄
+(NSString*)getPhotoDownloadPath;
@end
