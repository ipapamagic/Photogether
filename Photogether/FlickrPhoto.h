//
//  FlickrPhoto.h
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDefine.h"
@interface FlickrPhoto : NSObject
@property (nonatomic,readonly) NSString *photoID;
@property (nonatomic,readonly) NSString *owner;

-(id)initWithDictionary:(NSDictionary*)dict;
-(void)getImageWithSize:(FLICKR_PHOTO_SIZE)photoSize callback:(void (^)(UIImage*))callback;
-(NSString*)getMaxImageURL;
-(NSString*)getImageURLWithSize:(FLICKR_PHOTO_SIZE)photoSize;
@end
