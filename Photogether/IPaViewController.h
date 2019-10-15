//
//  IPaViewController.h
//  PhotoShare
//
//  Created by IPaPa on 12/10/10.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface IPaViewController : UIViewController <CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    IBOutlet UIView *receiveTipView;
    
    IBOutlet UILabel *receiveTipLabel;
    IBOutlet UIView *uploadTipView;
    IBOutlet UILabel *uploadTipLabel;
}
- (IBAction)onTest:(id)sender;

@end
