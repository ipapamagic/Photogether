//
//  FlickrUserImgView.m
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "FlickrUserImgView.h"

#import "IPaOFFlickrAPIRequest.h"
@implementation FlickrUserImgView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
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

-(void)setNSID:(NSString *)NSID
{
    if ([NSID isEqualToString:_NSID]) {
        return;
    }
    _NSID = NSID;
    NSString *loadingID = [NSID copy];
    [self setImage:[UIImage imageNamed:@"buddyicon.gif"]];
    __weak FlickrUserImgView *weakSelf = self;
    [IPaOFFlickrAPIRequest getFlickrUserBuddyIcon:NSID callback:^(UIImage* iconImg){
        if ([loadingID isEqualToString:weakSelf.NSID] && iconImg != nil) {
            [weakSelf setImage:iconImg];
        }
    }];
}


@end
