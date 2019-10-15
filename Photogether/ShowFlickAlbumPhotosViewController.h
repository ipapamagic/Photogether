//
//  ShowFlickAlbumPhotosViewController.h
//  Photogether
//
//  Created by IPaPa on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AlbumData;
@class IPaListScrollView;
@interface ShowFlickAlbumPhotosViewController : UIViewController
{
    
    IBOutlet IPaListScrollView *photoListView;
}

@property (nonatomic,strong) AlbumData* albumData;
- (IBAction)onBack:(id)sender;

@end
