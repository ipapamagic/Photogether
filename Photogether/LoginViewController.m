//
//  LoginViewController.m
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "LoginViewController.h"
#import "AppManager.h"
#import "IPaAlertView.h"
@interface LoginViewController ()

@end

@implementation LoginViewController
{
    //是否正在作Login
    BOOL isLogining;
}
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
    [loadingView setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onFlickrLogin:(id)sender {

    if (isLogining) {
        [IPaAlertView IPaAlertViewWithTitle:@"登入還沒完成!" message:@"" cancelButtonTitle:@"確定"];
        return;
    }
    [loadingView setHidden:NO];
    isLogining = YES;
    [AppManager doFlickrLogin:^(BOOL ret){
        isLogining = NO;
        [loadingView setHidden:YES];
        if (ret) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [IPaAlertView IPaAlertViewWithTitle:@"登入失敗!" message:@"Server 登入失敗，請在試一次。" cancelButtonTitle:@"確定"];
        }
    }];
    
}
- (void)viewDidUnload {
    loadingView = nil;
    [super viewDidUnload];
}
@end
