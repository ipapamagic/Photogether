//
//  ChooseFlickrPhotoShareViewController.h
//  Photogether
//
//  Created by IPaPa on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IPaListScrollView;
@interface ChooseFlickrPhotoShareViewController : UIViewController
{
    
    IBOutlet IPaListScrollView *photoListView;
    
    IBOutlet UITableView *albumTableView;
    
}
@property (nonatomic,strong) NSArray* photoList;
- (IBAction)onBack:(id)sender;

@end
