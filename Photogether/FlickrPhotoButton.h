//
//  FlickrPhotoButton.h
//  Photogether
//
//  Created by IPaPa on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDefine.h"
@class FlickrPhoto;
@interface FlickrPhotoButton : UIButton
@property (nonatomic,copy) FlickrPhoto *photo;
@end
