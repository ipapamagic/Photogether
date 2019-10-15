//
//  LoginViewController.h
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
{
    
    IBOutlet UIView *loadingView;
}
//登入Flickr
- (IBAction)onFlickrLogin:(id)sender;

@end
