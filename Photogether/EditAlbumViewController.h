//
//  EditAlbumViewController.h
//  Photogether
//
//  Created by Apple on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumData;

@interface EditAlbumViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
- (void) IsNewAlbum:(BOOL)bCreate AlbumData:(AlbumData*)album;
@end
