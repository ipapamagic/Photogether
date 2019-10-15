//
//  ChooseFlickrContentViewController.m
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "ChooseFlickrContentViewController.h"
#import "IPaListScrollView.h"
#import "IPaURLConnection.h"
#import "AppManager.h"
#import "FlickrPhoto.h"
#import "FlickrPhotoButton.h"
#import "ChooseFlickrPhotoShareViewController.h"
#import "IPaOFFlickrAPIRequest.h"

@interface ChooseFlickrContentViewController () <IPaListScrollViewDelegate>

@end

@implementation ChooseFlickrContentViewController
{
    NSArray *photoList;
    NSUInteger totalPhotoNum;
    NSMutableDictionary *photoURLDict;
    NSMutableArray *currentLoadingPage;
    NSMutableArray *selectedArray;
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
    
    currentLoadingPage = [@[] mutableCopy];
    selectedArray = [@[] mutableCopy];
    photoURLDict = [@{} mutableCopy];
    [photoListView setControlDelegate:self];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.albumName != nil) {
        NSRange range = [self.albumName rangeOfString:ALBUMNAME_MARK];
        NSString *visibleName = [self.albumName substringToIndex:range.location];
        [albumNameLabel setText:visibleName];
    }
    else {
        [albumNameLabel setText:@"ALL"];
    }
    [self LoadPhotosForIndex:0];
    
}
-(void)LoadPhotosForIndex:(NSUInteger)index
{
    NSUInteger pageIdx = index / FLICKR_PHOTO_PER_PAGE + 1;
    if ([currentLoadingPage indexOfObject:@(pageIdx)] != NSNotFound) {
        return;
    }
    [currentLoadingPage addObject:@(pageIdx)];
    void (^onCallback)(NSUInteger,NSUInteger,NSUInteger,NSArray*) = ^(NSUInteger currentPage,NSUInteger totalPage,NSUInteger totalPhoto,NSArray* pList){
        
        totalPhotoNum = totalPhoto;
        NSInteger index = 0;
        for (FlickrPhoto* photo in pList) {
            photoURLDict[@(pageIdx+index)] = photo;
            index++;
        }
        [currentLoadingPage removeObject:@(pageIdx)];
        [photoListView ReloadContent];
    };
    if (self.albumName == nil) {
        //顯示所有Flickr相片
        [AppManager getPublicPhotoListWithPage:pageIdx callback:onCallback];
    }
    else {
        //顯示AlbumName相片
        //by ben        
        [AppManager getFlickrPhotoListInAlbum:self.albumName NSID:[IPaOFFlickrAPIRequest getUserNSID] WithPage:pageIdx callback:onCallback];
        
    }

}
- (void)viewDidUnload {
    photoListView = nil;
    albumNameLabel = nil;
    [super viewDidUnload];
}

#pragma mark - IPaListScrollViewDelegate
-(BOOL) isIPaListScrollViewColumnMajor:(IPaListScrollView *)scrollView
{
    return NO;
}
-(NSUInteger) IPaListScrollViewTotalItemsNum:(IPaListScrollView*)scrollView
{
    return totalPhotoNum;
}
//get item size
-(CGFloat) IPaListScrollViewItemHeight:(IPaListScrollView*)scrollView
{
    return 77;
}

-(CGFloat) IPaListScrollViewItemWidth:(IPaListScrollView*)scrollView
{
    return 77;
}
-(CGFloat)IPaListScrollViewItemOffsetX:(IPaListScrollView *)scrollView
{
    return 1.5;
}
-(CGFloat)IPaListScrollViewItemOffsetY:(IPaListScrollView *)scrollView
{
    return 3;
}
-(CGFloat)IPaListScrollViewItemDistanceX:(IPaListScrollView *)scrollView
{
    return 3;
}
-(CGFloat)IPaListScrollViewItemDistanceY:(IPaListScrollView *)scrollView
{
    return 3;
}
-(CGFloat)IPaListScrollViewSizeOffsetX:(IPaListScrollView *)scrollView
{
    return 1.5;
}
-(CGFloat)IPaListScrollViewSizeOffsetY:(IPaListScrollView *)scrollView
{
    return 3;
}
//get a new item for list view
-(UIView*) onIPaListScrollViewNewItem:(IPaListScrollView*)scrollView withItemIndex:(NSUInteger)Index
{
    FlickrPhotoButton *button = [[FlickrPhotoButton alloc] initWithFrame:CGRectMake(0, 0, 77, 77)];
    
    [button addTarget:self action:@selector(onSelect:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}
-(void) configureIPaListScrollView:(IPaListScrollView*)scrollView withItem:(UIView*)Item withIdx:(NSUInteger)Index
{
    FlickrPhoto *photo = photoURLDict[@(Index+1)];

    FlickrPhotoButton *button = (FlickrPhotoButton*)Item;    
    if (photo == nil) {
        //沒資料,去抓照片
       
        [self LoadPhotosForIndex:Index];
        [button setSelected:NO];
    }
    else
    {

        button.photo = photo;
        
        [button setSelected:([selectedArray indexOfObject:photo] != NSNotFound)];
    }
    
    

}
-(void)onSelect:(FlickrPhotoButton*)sender
{
    if (sender.photo == nil) {
        return;
    }
    if ([selectedArray indexOfObject:sender.photo] != NSNotFound) {
        //已被選擇，取消選擇
        
        [selectedArray removeObject:sender.photo];
        
        [sender setSelected:NO];
    }
    else {
        [selectedArray addObject:sender.photo];
        
        [sender setSelected:YES];
    }
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"choose.shareFlickrPhoto"]) {
        ChooseFlickrPhotoShareViewController* viewController = (ChooseFlickrPhotoShareViewController*)segue.destinationViewController;
        viewController.photoList = selectedArray;
        
    }
}
@end
