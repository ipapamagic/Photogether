//
//  FlickrPhotoImgView.h
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPaOFFlickrAPIRequest.h"
#import "AppDefine.h"

@interface FlickrPhotoImgView : UIImageView
@property (nonatomic,copy) NSString *photoID;
@property (nonatomic,assign) FLICKR_PHOTO_SIZE photoSize;
@end
