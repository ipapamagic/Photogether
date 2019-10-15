//
//  IPaFriendsCell.m
//  Photogether
//
//  Created by Apple on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaFriendsCell.h"
#import "FlickrUserImgView.h"
#import "AppManager.h"

@implementation IPaFriendsCell

#pragma mark - public
//- (void)SetNoteText:(NSString *)note
//{
//    [NoteLabel setText:note];
//}
//
//- (void)SetHeadPic:(NSString *)url
//{
//    [HeadImageView setNSID:url];
//}

- (void)setNSID:(NSString *)NSID
{
    _NSID = NSID;
    [HeadImageView setNSID:_NSID];
    [NoteLabel setText:@""];
//    [NoteLabel setText:_NSID];
    [AppManager getUserNameWithNSID:_NSID callback:^(NSString* name){
        [NoteLabel setText:name];
    }];
}

- (void)SetStateType:(NSInteger)type
{
    switch (type) {
        case SelectType:
            EnableSelect = YES;
            [stateImageView setHidden:NO];
            [stateImageView setImage:[UIImage imageNamed:@"list_select2@2x.png"]];
            [stateBut setHidden:YES];
            break;
        case DeleteType:
            EnableSelect = NO;
            [stateImageView setHidden:YES];
            [stateBut setHidden:NO];
            [stateBut setImage:[UIImage imageNamed:@"delete@2x.png"] forState:UIControlStateNormal];
            [stateBut setImage:[UIImage imageNamed:@"delete_on@2x.png"] forState:UIControlStateHighlighted];
            break;
        case AddType:
            EnableSelect = NO;
            [stateImageView setHidden:YES];
            [stateBut setHidden:NO];
            [stateBut setImage:[UIImage imageNamed:@"add@2x.png"] forState:UIControlStateNormal];
            [stateBut setImage:[UIImage imageNamed:@"add_on@2x.png"] forState:UIControlStateHighlighted];
            break;
        default:
            [stateImageView setHidden:YES];
            [stateBut setHidden:YES];
            break;
    }
}

#pragma mark - action
- (void) PushStateBtn:(id)sender
{
    if(self.FriendCellCallBack)
    {
        self.FriendCellCallBack(self.NSID);
    }
}

#pragma mark - main life cycle
- (void) awakeFromNib
{
    [super awakeFromNib];
    EnableSelect = false;
    _NSID = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    if (EnableSelect) {
        if (selected) {
            [stateImageView setImage:[UIImage imageNamed:@"list_select2_on@2x.png"]];
        }else{
            [stateImageView setImage:[UIImage imageNamed:@"list_select2@2x.png"]];
        }
    }
}

@end
