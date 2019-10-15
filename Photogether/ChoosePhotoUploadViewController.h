//
//  ChoosePhotoUploadViewController.h
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IPaListScrollView;
@interface ChoosePhotoUploadViewController : UIViewController
{
    IBOutlet UIView* LoadingView;
    IBOutlet IPaListScrollView *photoListView;
    IBOutlet UITableView *flickrAlbumTableView;
}
@property (nonatomic,strong) NSArray *photoList;
- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;

@end
