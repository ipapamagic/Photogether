//
//  ChooseAlbumContentViewController.h
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IPaListScrollView;
@interface ChooseAlbumContentViewController : UIViewController
{
    
    IBOutlet IPaListScrollView *photoListView;
}
@property (nonatomic,strong) NSArray *assetList;

- (IBAction)onBack:(id)sender;
- (IBAction)onDoSelectPhoto:(id)sender;

@end
