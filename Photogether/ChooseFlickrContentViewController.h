//
//  ChooseFlickrContentViewController.h
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IPaListScrollView;
@interface ChooseFlickrContentViewController : UIViewController
{
    
    IBOutlet UILabel *albumNameLabel;
    IBOutlet IPaListScrollView *photoListView;
}
@property (nonatomic,copy) NSString* albumName;

- (IBAction)onBack:(id)sender;

@end
