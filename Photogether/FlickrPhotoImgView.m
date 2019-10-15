//
//  FlickrPhotoImgView.m
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "FlickrPhotoImgView.h"
#import "IPaOFFlickrAPIRequest.h"
@implementation FlickrPhotoImgView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.photoSize = FLICKR_PHOTO_SIZE_Thumbnail;
    }
    return self;
}
    //url_sq, url_t, url_s, url_q, url_m, url_n, url_z, url_c, url_l, url_o
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)setPhotoID:(NSString *)photoID
{
    _photoID = photoID;
    NSString *loadingID = [photoID copy];
    __weak FlickrPhotoImgView *weakSelf = self;
    if (photoID != nil) {
        
        [IPaOFFlickrAPIRequest getPhotoWithID:photoID withSize:FLICKR_PHOTO_SIZE_Small callback:^(UIImage* image){
            if ([loadingID isEqualToString:weakSelf.photoID]) {
                [weakSelf setImage:image];
            }
        }];
    }
}
@end
