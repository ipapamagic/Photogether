//
//  IPaFriendsCell.h
//  Photogether
//
//  Created by Apple on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>

enum CellStateType
{
    SelectType = 0,
    DeleteType = 1,
    AddType = 2
};

@class FlickrUserImgView;

@interface IPaFriendsCell : UITableViewCell
{
    IBOutlet FlickrUserImgView* HeadImageView;
    IBOutlet UILabel* NoteLabel;
    IBOutlet UIImageView* stateImageView;
    IBOutlet UIButton* stateBut;
    BOOL EnableSelect;
}
@property (nonatomic,copy) void (^FriendCellCallBack)(NSString*);
@property (nonatomic,copy) NSString* NSID;
- (IBAction) PushStateBtn:(id)sender;
//- (void) SetNoteText:(NSString*)note;
//- (void) SetHeadPic:(NSString*)url;
- (void) SetStateType:(NSInteger)type;
@end
