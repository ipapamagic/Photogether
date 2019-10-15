//
//  AppManager.m
//  PhotoShare
//
//  Created by IPaPa on 12/10/14.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "AppManager.h"
#import "ObjectiveFlickr.h"
#import "IPaKeyChain.h"
#import "IPaAlertView.h"
#import "IPaOFFlickrAPIRequest.h"
#import "IPaURLConnection.h"
#import "IPaXMLSection.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AlbumData.h"
#import "AppDefine.h"
#import "FlickrPhoto.h"

#define PHOTOGETHER_LOGIN_API @"http://css.inmusic.com.tw/Photogether/service/member_login.aspx?user_id=%@&name=%@"
#define PHOTOGETHER_CREATE_ALBUM_API @"http://css.inmusic.com.tw/Photogether/service/flickr_album.aspx?album_name=%@&user_id=%@"
#define PHOTOGETHER_CREATE_FRIEND_LIST_API @"http://css.inmusic.com.tw/Photogether/service/flickr_friend.aspx?auth_token=%@&user_id=%@"
#define PHOTOGETHER_GET_FRIEND_LIST_API @"http://css.inmusic.com.tw/Photogether/xml/%@.xml"
#define PHOTOGETHER_SHARE_ALBUM_TO_FRIEND_API @"http://css.inmusic.com.tw/Photogether/service/flickr_share.aspx?album_name=%@&user_id_str=%@"
#define PHOTOGETHER_GET_ALBUM_LIST_API @"http://css.inmusic.com.tw/Photogether/service/select_share.aspx?user_id=%@"
#define LOCATION_POINT_API @"http://css.inmusic.com.tw/Photogether/service/Coordinate.aspx?latitude=%f&longitude=%f&user_id=%@"

@interface AppManager ()<OFFlickrAPIRequestDelegate>
@property (nonatomic,strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic,strong) NSMutableDictionary *flickrUploadList;
@property (nonatomic,strong) NSMutableDictionary *flickrDownloadList;
//使用者的相本列表

@end
@implementation AppManager


///by ben
+ (void) SendLocationLat:(float)lat Lon:(float)lon UserID:(NSString*)uid callback:(void (^)(BOOL))callback
{
    NSString *urlString = [NSString stringWithFormat:LOCATION_POINT_API,lat,lon, uid];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [IPaURLConnection IPaURLConnectionWithURL:urlString cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:DEFAULT_TIME_OUT callback:^(NSURLResponse* response,NSData* data){
        IPaXMLSection *section = [[IPaXMLSection alloc] initWithXMLData:data];
        if ([[section ReadFirstChildValue:@"memo"] isEqualToString:@"error"]) {
            callback(NO);
            return;
        }
        callback(YES);
    }failCallback:^(NSError* error){
        NSLog(@"Create album fail:%@",error.description);
        callback(NO);
    }];
}

/////

+(void)refreshIdleTimer
{
    AppManager *defaultManager = [self defaultManager];
    [UIApplication sharedApplication].idleTimerDisabled = ((defaultManager.flickrDownloadList.count + defaultManager.flickrUploadList.count) == 0);
}
+(AppManager*)defaultManager
{
    static AppManager *defaultManager = nil;
    if (defaultManager == nil) {
        defaultManager = [[AppManager alloc] init];
        defaultManager.flickrUploadList = [@{} mutableCopy];
        defaultManager.flickrDownloadList = [@{} mutableCopy];
    }
    return defaultManager;
}

//+(void)createAlbumWithName:(NSString*)name callback:(void (^)(BOOL))callback
+(void)createAlbumWithName:(NSString*)name callback:(void (^)(NSString*))callback
{
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    CFRelease(uuidObject);
    NSString *albumName = [NSString stringWithFormat:@"%@%@%@",name,ALBUMNAME_MARK,uuidStr];
    
    NSString *urlString = [NSString stringWithFormat:PHOTOGETHER_CREATE_ALBUM_API,albumName,[IPaOFFlickrAPIRequest getUserNSID]];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [IPaURLConnection IPaURLConnectionWithURL:urlString cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:DEFAULT_TIME_OUT callback:^(NSURLResponse* response,NSData* data){
        IPaXMLSection *section = [[IPaXMLSection alloc] initWithXMLData:data];
        if ([[section ReadFirstChildValue:@"memo"] isEqualToString:@"error"]) {
            callback(@"");
            return;
        }
      
        
        callback(albumName);
    }failCallback:^(NSError* error){
        NSLog(@"Create album fail:%@",error.description);
        callback(@"");
    }];
    

}
#pragma mark - Flickr

+(BOOL)handleFlickrOpenURL:(NSURL*)url
{
    return [IPaOFFlickrAPIRequest handleFlickrOpenURL:url];
}

+(void)doFlickrLogin:(void (^)(BOOL))callback
{
    [IPaOFFlickrAPIRequest doLogin:^(BOOL ret){
        NSLog(@"flickr login result :%d",ret);
        
        if (ret) {
            NSString *userName = [IPaOFFlickrAPIRequest getUserName];
            NSString *userNSID = [IPaOFFlickrAPIRequest getUserNSID];
            
            NSString *urlString = [NSString stringWithFormat:PHOTOGETHER_LOGIN_API,userNSID,userName];
            NSLog(@"登入Photogether userName:%@ ,nsid:%@",userName,userNSID);
            [IPaURLConnection IPaURLConnectionWithURL:urlString cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:DEFAULT_TIME_OUT callback:^(NSURLResponse* response,NSData* data){
                
                IPaXMLSection *section = [[IPaXMLSection alloc] initWithXMLData:data];
                if ([[section ReadFirstChildValue:@"memo"] isEqualToString:@"error"]) {
                    NSLog(@"登入失敗.....");
                    callback(NO);
                    return;
                }
                [IPaOFFlickrAPIRequest getContactList:^(NSData* data){
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:PHOTOGETHER_CREATE_FRIEND_LIST_API]];
                    
                    
                    //    [request setTimeoutInterval:30];
                    [request setHTTPMethod:@"POST"];
                    NSMutableString *bodyString = [NSMutableString string];
                    [bodyString appendFormat:@"user_id=%@",[IPaOFFlickrAPIRequest getUserNSID]];
                    [bodyString appendString:@"auth_token="];
                    NSMutableData *body = [[bodyString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                    [body appendData:data];
                    [request setHTTPBody:body];
                    IPaURLConnection *connection = [[IPaURLConnection alloc] initWithURLRequest:request callback:nil failCallback:nil receiveCallback:nil];
                    [connection start];
                    
                }];
                callback(YES);                

            }failCallback:^(NSError* error){
                callback(NO);

            }];
            
            
        }
        else {
            callback(ret);
        }
    }];
}
+(BOOL)isFlickrLogin
{
    return [IPaOFFlickrAPIRequest isLogin];
}
+(NSString*)getPhotoDownloadPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,    YES);
    return [paths objectAtIndex:0];
}
+(NSUInteger)downloadImage:(FlickrPhoto*)photoData
{
    NSString *url = [photoData getMaxImageURL];
    
    static NSUInteger idCounter = 0;
    idCounter++;
    
    
    NSUInteger requestID = idCounter;
    IPaURLConnection* urlConnection = [[IPaURLConnection alloc] initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:120 callback:^(NSURLResponse* response,NSData* data){
        
        NSString *downloadPath = [self getPhotoDownloadPath];
        downloadPath = [downloadPath stringByAppendingPathComponent:photoData.photoID];
        downloadPath = [downloadPath stringByAppendingPathExtension:@"jpeg"];
        [data writeToFile:downloadPath atomically:YES];
        [[self defaultManager].flickrDownloadList removeObjectForKey:@(requestID)];
        [self refreshIdleTimer];
        [[NSNotificationCenter defaultCenter] postNotificationName:PHOTOGETHER_NOTIFICATION_IMAGEGET_DONE object:[self defaultManager] userInfo:@{@"RequestID":@(requestID)}];        
    }failCallback:^(NSError* error){
        [[self defaultManager].flickrDownloadList removeObjectForKey:@(requestID)];
        [self refreshIdleTimer];
    }receiveCallback:^(NSURLResponse* response,NSData* recData,NSData* currentData){
        CGFloat percent = (CGFloat)recData.length / (CGFloat)response.expectedContentLength;
//        [NSNotificationCenter defaultCenter] pos
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PHOTOGETHER_NOTIFICATION_IMAGEGET object:[self defaultManager] userInfo:@{@"RequestID":@(idCounter),@"getPercent" : @(percent)}];
         
    }];
    [self defaultManager].flickrDownloadList[@(idCounter)] = urlConnection;
    
    [urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                             forMode:NSRunLoopCommonModes];
    [urlConnection start];
    
    [self refreshIdleTimer];
    return idCounter;
}
+(NSUInteger)uploadImage:(UIImage*)image toAlbumName:(NSString*)albumName
{
    static NSUInteger idCounter = 0;
    idCounter++;
    NSMutableArray *photoList = [self defaultManager].flickrUploadList[albumName];
    if (photoList == nil) {
        photoList = [@[] mutableCopy];
        [self defaultManager].flickrUploadList[albumName] = photoList;
    }
    
    
    [self defaultManager].flickrUploadList[@(idCounter)] =
            [IPaOFFlickrAPIRequest uploadImage:image withTag:albumName
                  sentBytesCB:^(NSUInteger sentBytes,NSUInteger totalBytes){
                      
                      [[NSNotificationCenter defaultCenter] postNotificationName:PHOTOGETHER_NOTIFICATION_IMAGESENT object:self userInfo:@{@"RequestID":@(idCounter),@"inSentBytes" : @(sentBytes),@"inTotalBytes":@(totalBytes)}];
                  }imageDidUploadCB:^(NSString* photoID){
                      NSNumber *requestID = @(idCounter);
                      [[self defaultManager].flickrUploadList removeObjectForKey:requestID];
                      [self refreshIdleTimer];
                      
                  }failCallback:^(NSError* error){
                      NSNumber *requestID = @(idCounter);
                      [[self defaultManager].flickrUploadList removeObjectForKey:requestID];
                      [self refreshIdleTimer];
                  }];
    [self refreshIdleTimer];
    return idCounter;
}
+(void)getPublicPhotoListWithPage:(NSUInteger)page callback:(void (^)(NSUInteger,NSUInteger,NSUInteger,NSArray*))callback
{
    [IPaOFFlickrAPIRequest getPublicPhotoListWithPage:page callback:callback];
}
+(void)getSinglePhotoWithCallback:(void (^)(FlickrPhoto*))callback
{
    [IPaOFFlickrAPIRequest getSinglePhotoWithCallback:callback];
}

+(void)getFlickrPhotoListInAlbum:(NSString*)albumName NSID:(NSString*)nsid WithPage:(NSUInteger)page callback:(void (^)(NSUInteger,NSUInteger,NSUInteger,NSArray*))callback
{
    [IPaOFFlickrAPIRequest getFlickrPhotoListWithTag:albumName NSID:nsid WithPage:page callback:callback];
}

+(void)getFriendList:(void (^)(NSArray*))callback
{
    NSString *urlString = [NSString stringWithFormat:PHOTOGETHER_GET_FRIEND_LIST_API,[IPaOFFlickrAPIRequest getUserNSID]];
    [IPaURLConnection IPaURLConnectionWithURL:urlString cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:DEFAULT_TIME_OUT callback:^(NSURLResponse* response,NSData* data){
        IPaXMLSection *section = [[IPaXMLSection alloc] initWithXMLData:data];
        callback([section ReadChildrenValue:@"user_id"]);
        
    }failCallback:^(NSError* error){
        NSLog(@"get friend list fail!");
        callback(@[]);
    }];
}
+(void)addPhotoID:(NSString*)photoID toAlbumName:(NSString*)albumName callback:(void (^)(BOOL))callback
{
    [IPaOFFlickrAPIRequest addPhotoID:photoID withTag:albumName callback:callback];
}
+(void)shareAlbum:(NSString*)albumName withFriends:(NSArray*)friendList callback:(void (^)(BOOL))callback
{
    NSString *friendListStr = nil;
    
    for (NSString* friendNSID in friendList) {
        if (friendListStr == nil) {
            friendListStr = @"";
        }
        else {
            friendListStr = [friendListStr stringByAppendingString:@","];
        }
        friendListStr = [friendListStr stringByAppendingString:friendNSID];
        
    }
    NSString *urlString = [[NSString stringWithFormat:PHOTOGETHER_SHARE_ALBUM_TO_FRIEND_API,albumName,friendListStr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [IPaURLConnection IPaURLConnectionWithURL:urlString cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:DEFAULT_TIME_OUT callback:^(NSURLResponse *response,NSData* data){
        IPaXMLSection *section = [[IPaXMLSection alloc] initWithXMLData:data];
        
        if ([[section ReadFirstChildValue:@"memo"] isEqualToString:@"true"])
        {
            callback(YES);
        }
        else {
            NSLog(@"share to friend fail!");
        }
        
        
    }failCallback:^(NSError* error){
        NSLog(@"share to friend fail! connection error:%@",error.description);
        callback(NO);
    }];
    
    
}


+(void)getAlbumList:(void (^)(NSArray*))callback
{
    NSString *urlString = [NSString stringWithFormat:PHOTOGETHER_GET_ALBUM_LIST_API,[IPaOFFlickrAPIRequest getUserNSID]];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [IPaURLConnection IPaURLConnectionWithURL:urlString cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:DEFAULT_TIME_OUT callback:^(NSURLResponse* response,NSData* data){
        IPaXMLSection *section = [[IPaXMLSection alloc] initWithXMLData:data];
        NSMutableArray *albumList = [@[] mutableCopy];
        IPaXMLSection *section1 = [section FirstSectionWithKey:@"memo1"];
        IPaXMLSection *section2 = [section FirstSectionWithKey:@"memo2"];
        if ([section1.Value isEqualToString:@"0"] && [section2.Value isEqualToString:@"0"] ) {
            callback(@[]);
        }
        else {
            for (IPaXMLSection *albumSec in section1.children) {
                NSString *albumName = albumSec.Value;
                
                NSArray *list = [albumSec ReadChildrenValue:@"share_user"];
                
                AlbumData *albumData = [[AlbumData alloc] initWithAlbumName:albumName shareList:list];
                [albumList addObject:albumData];
            }
            for (IPaXMLSection *albumSec in section2.children) {
                NSString *albumName = albumSec.Value;//attributes[@"name"];
                
                NSArray *list = [albumSec ReadChildrenValue:@"share_user"];
                
                AlbumData *albumData = [[AlbumData alloc] initWithAlbumName:albumName shareList:list];
                [albumList addObject:albumData];
            }
            callback(albumList);
        }
      
        
    }failCallback:^(NSError* error){
        NSLog(@"get album list connection error:%@",error.description);
        callback(@[]);
    }];
    
    callback(@[]);
}
+(void)getAlbumTitlePhoto:(NSString*)albumName callback:(void (^)(FlickrPhoto*))callback
{    
    [IPaOFFlickrAPIRequest getSinglePhotoWithTag:albumName withSize:FLICKR_PHOTO_SIZE_Small callback:callback];
}
+(void)getFlickrWithPhotoID:(NSString*)photoID withSize:(FLICKR_PHOTO_SIZE)photoSize callback:(void (^)(UIImage*))callback
{
    [IPaOFFlickrAPIRequest getPhotoWithID:photoID withSize:photoSize callback:callback];
}

+(NSUInteger)getDownloadingNum
{
    return [self defaultManager].flickrDownloadList.count;
}
+(NSArray*)getDownloadingIDList
{
    return [self defaultManager].flickrDownloadList.allKeys;    
}
+(NSUInteger)getUploadingNum
{
    return [self defaultManager].flickrUploadList.count;
}
+(NSArray*)getUploadingIDList
{
    return [self defaultManager].flickrUploadList.allKeys;
}
+(void)getUserNameWithNSID:(NSString*)NSID callback:(void (^)(NSString*))callback
{
    [IPaOFFlickrAPIRequest getUserNameWithNSID:NSID callback:callback];
}
#pragma mark - 內建相本資料取得用的asset library
-(ALAssetsLibrary*)assetLibrary
{
    if (_assetLibrary == nil) {
        _assetLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetLibrary;
}
+(ALAssetsLibrary*)assetLibrary
{
    return [self defaultManager].assetLibrary;
}

@end
