//
//  IPaAlbumCell.h
//  Photogether
//
//  Created by Apple on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>

enum ShowCheckMode {
    check_Select = 0,
    check_Edit = 1
};

@class AlbumData;
@interface IPaAlbumCell : UITableViewCell
{
    IBOutlet UILabel* NoteLabel;
    IBOutlet UIView* CustomView;
    IBOutlet UIImageView* CheckView;
    IBOutlet UIButton* EditBtn;
    NSInteger showCheckType;
}
@property (nonatomic,copy) void (^AlbumCellCallBack)(AlbumData*);
@property (nonatomic,strong) AlbumData *albumData;
- (void) EnableCheckBox:(NSInteger)type;
- (IBAction) EditAlbum:(id)sender;
@end
