//
//  FlickrPhotoButton.m
//  Photogether
//
//  Created by IPaPa on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "FlickrPhotoButton.h"

#import "IPaURLConnection.h"
#import "FlickrPhoto.h"
@implementation FlickrPhotoButton
{
    UIImageView *overlayView;
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    overlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photoselect.png"]];
    [self addSubview:overlayView];
    [overlayView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)setPhoto:(FlickrPhoto *)photo
{
    _photo = photo;
    NSString *imgURL = [photo getImageURLWithSize:FLICKR_PHOTO_SIZE_Small];
    __weak FlickrPhotoButton *weakSelf = self;
    IPaURLConnection *urlConnection = [[IPaURLConnection alloc] initWithURL:imgURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:DEFAULT_TIME_OUT callback:^(NSURLResponse* response,NSData* data){
        if (photo != weakSelf.photo) {
            return;
        }

        UIImage *image = [UIImage imageWithData:data];
        [self setImage:image forState:UIControlStateNormal];
        [self setImage:image forState:UIControlStateSelected];


    }];
    [urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                             forMode:NSRunLoopCommonModes];
    [urlConnection start];
    
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    [overlayView setHidden:!selected];
}
@end
