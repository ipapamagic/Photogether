//
//  SettingViewController.m
//  PhotoShare
//
//  Created by IPaPa on 12/10/11.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "SettingViewController.h"
#import "AppManager.h"

@interface SettingViewController ()
{
    IBOutlet UILabel* UserNameLabel;
    IBOutlet UIImageView* UserHeadPic;
    
}
- (IBAction) BackPage:(id)sender;

@end

@implementation SettingViewController

#pragma mark - action
- (void)BackPage:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - main life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
