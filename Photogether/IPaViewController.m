//
//  IPaViewController.m
//  PhotoShare
//
//  Created by IPaPa on 12/10/10.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaViewController.h"
#import "AppManager.h"
#import "IPaAlertView.h"
#import "IPaOFFlickrAPIRequest.h"

@interface IPaViewController ()
{
    UIImagePickerController* CameraPicker;
    IBOutlet UIView* ShowCameraOverLay;
    IBOutlet UIView* Preview;
    
    CLLocationManager* location;
}

- (IBAction) PushTake:(id)sender;
- (IBAction) GetPicture:(id)sender;
- (IBAction) CancelTake:(id)sender;
- (IBAction) TakeEnd:(id)sender;
- (IBAction) EnableFlashTake:(id)sender;

@end

@implementation IPaViewController

#pragma mark - private
- (void) GetLocation
{
    if (![CLLocationManager headingAvailable]) {
        UIAlertView* msg = [[UIAlertView alloc] initWithTitle:@"定位服務未開啟" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [msg show];
        return;
    }
    
    location = [[CLLocationManager alloc] init];
    location.desiredAccuracy = kCLLocationAccuracyBest;
    location.distanceFilter = 100.0f;
    location.delegate = self;
    [location startUpdatingLocation];
}

#pragma mark - CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D coordinate;
    CLLocationDistance altitude;
    
    coordinate = [newLocation coordinate];
    altitude = [newLocation altitude];
    
    //更新定位信息方法
    NSLog(@"delegate %f,%f", coordinate.latitude, coordinate.longitude);
    
    [AppManager SendLocationLat:coordinate.latitude Lon:coordinate.longitude UserID:[IPaOFFlickrAPIRequest getUserNSID] callback:^(BOOL bSuccess){
        if (bSuccess) {
            NSLog(@"location 回報成功");
        }
    }];
    
//    [manager stopUpdatingLocation];
//    
//    GetNearbyPlaceConnect* NearbyPlcae = [[GetNearbyPlaceConnect alloc] init];
//    NSArray* array = [[NSArray alloc] initWithArray:[NearbyPlcae StartGetNearbyplaceConnectPoint:CGPointMake(coordinate.latitude, coordinate.longitude)]];
//    [NearbyPlcae release];
//    
//    [PlaceArray addObjectsFromArray:array];
//    [array release];
//    
//    if ([PlaceArray count] == 0) {
//        [SearchView setHidden:YES];
//    }else{
//        [PlaceTableView reloadData];
//    }
//    [waitView setHidden:YES];
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
}

- (IBAction)GetPicture:(id)sender
{
    [CameraPicker takePicture];
}

- (IBAction)CancelTake:(id)sender
{
    [CameraPicker dismissViewControllerAnimated:YES completion:^(void){}];
}

- (IBAction)TakeEnd:(id)sender
{
    [CameraPicker dismissViewControllerAnimated:YES completion:^(void){}];
}

- (IBAction)EnableFlashTake:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    if (!btn.isSelected) {
        btn.selected = YES;
        CameraPicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;//開啟閃光燈
    }else{
        btn.selected = NO;
        CameraPicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;//關閉閃光燈
    }
}

#pragma mark - action
- (void)PushTake:(id)sender
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [IPaAlertView IPaAlertViewWithTitle:@"Warning!" message:@"這個裝置不支援Camera!" cancelButtonTitle:@"確定"];
        return;
    }

    CameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    CameraPicker.showsCameraControls = NO;
    CameraPicker.navigationBarHidden = YES;
    CameraPicker.toolbarHidden = YES;
    
    CameraPicker.cameraOverlayView = ShowCameraOverLay; 
    [CameraPicker setVideoQuality:UIImagePickerControllerQualityType640x480];
    [CameraPicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
    [self presentViewController:CameraPicker animated:YES completion:^(void){}];
}

#pragma mark - main life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    CameraPicker = [[UIImagePickerController alloc] init];
    CameraPicker.delegate = self;
    
    if ([AppManager isFlickrLogin])
    {
        NSLog(@"already has auth!");
        //已經有認證，要先登入看看是否可以登入
        [AppManager doFlickrLogin:^(BOOL ret){
            if(!ret)
            {
                //登入失敗
                [self performSegueWithIdentifier:@"ShowFirstLogin" sender:self];
            }
        }];
    }
    else {
        //還沒登入，請先登入
        [self performSegueWithIdentifier:@"ShowFirstLogin" sender:self];
    }
    
    [self GetLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onTest:(id)sender {
    
    
    [AppManager createAlbumWithName:@"我的照片" callback:^(NSString* ret){
        NSLog(@"建立相本:%@",ret);
    }];
//    [AppManager getPublicPhotoListWithPage:1 callback:^(NSUInteger currentPage,NSUInteger totalPage,NSUInteger photocount,NSArray* list){
//        
//    }];
}

- (void)viewDidUnload {
    receiveTipView = nil;
    uploadTipView = nil;
    receiveTipLabel = nil;
    uploadTipLabel = nil;
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUInteger Num = [AppManager getUploadingNum];
    if (Num == 0) {
        [uploadTipView setHidden:YES];
    }
    else {
        [uploadTipView setHidden:NO];
        [uploadTipLabel setText:[NSString stringWithFormat:@"%d",Num]];
    }
    
    Num = [AppManager getDownloadingNum];
    if (Num == 0) {
        [receiveTipView setHidden:YES];
    }
    else {
        [receiveTipView setHidden:NO]; 
        [receiveTipLabel setText:[NSString stringWithFormat:@"%d",Num]];
    }
    

    
    
}
@end
