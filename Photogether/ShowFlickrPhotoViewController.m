//
//  ShowFlickrPhotoViewController.m
//  Photogether
//
//  Created by IPaPa on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "ShowFlickrPhotoViewController.h"
#import "IPaURLConnection.h"
#import "IPaListScrollView.h"

@interface ShowFlickrPhotoViewController () <IPaListScrollViewDelegate>
{
}

- (IBAction)SavePhoto:(id)sender;
- (IBAction)ClosePhoto:(id)sender;
@end

@implementation ShowFlickrPhotoViewController

#pragma mark - action
- (void)SavePhoto:(id)sender
{
//    UIImageWriteToSavedPhotosAlbum(ShowPhotoView.image, nil, nil, nil);
}

- (void)ClosePhoto:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - main

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
    
//    [IPaURLConnection IPaURLConnectionWithURL:ImageURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0f callback:^(NSURLResponse* response,NSData* data){
//        [ShowPhotoView setImage:[UIImage imageWithData:data]];
//    }failCallback:^(NSError* error){
//        NSLog(@"Create album fail:%@",error.description);
//    }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [photoListView setControlDelegate:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IPaListScrollViewDelegate
-(NSUInteger) IPaListScrollViewTotalItemsNum:(IPaListScrollView*)scrollView
{
    return [self.delegate onGetAlbumTotalNumber];
}
//get item size
-(CGFloat) IPaListScrollViewItemHeight:(IPaListScrollView*)scrollView
{
    return photoListView.frame.size.height;
}
-(CGFloat) IPaListScrollViewItemWidth:(IPaListScrollView*)scrollView
{
    return photoListView.frame.size.width;
}
//get a new item for list view
-(UIView*) onIPaListScrollViewNewItem:(IPaListScrollView*)scrollView withItemIndex:(NSUInteger)Index
{
    return [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, photoListView.frame.size.width, photoListView.frame.size.height)];
}
-(void) configureIPaListScrollView:(IPaListScrollView*)scrollView withItem:(UIView*)Item withIdx:(NSUInteger)Index
{
    [self.delegate onGetImageWithIndex:Index withCallback:^(UIImage* image){
        UIImageView *targetImgView = (UIImageView*)[scrollView getItemWithIndex:Index];
        [targetImgView setImage:image];
    }];
    
}

@end
