//
//  ShowFlickAlbumPhotosViewController.m
//  Photogether
//
//  Created by IPaPa on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "ShowFlickAlbumPhotosViewController.h"
#import "IPaListScrollView.h"
#import "FlickrPhotoButton.h"
#import "AppManager.h"
#import "AlbumData.h"
#import "ShowFlickrPhotoViewController.h"
#import "FlickrPhoto.h"
#import "IPaURLConnection.h"
@interface ShowFlickAlbumPhotosViewController () <IPaListScrollViewDelegate,ShowFlickrPhotoViewControllerDelegate>
@property (nonatomic,readonly) NSInteger totalPhotoNum;
@end

@implementation ShowFlickAlbumPhotosViewController
{
    NSArray *photoList;
//    NSUInteger totalPhotoNum;
    NSMutableDictionary *photoURLDict;
    NSMutableArray *currentLoadingPage;
    //各個NSID的photo num
    NSMutableArray *photoNumList;
    
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
    currentLoadingPage = [@[] mutableCopy];
    photoURLDict = [@{} mutableCopy];
    photoNumList = [@{} mutableCopy];
    [photoListView setControlDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [photoNumList removeAllObjects];

    for (NSInteger index = 0; index < self.albumData.shareList.count; index++) {
        [photoNumList addObject:@(0)];
    }
    
    
    [self LoadPhotosForIndex:0 callback:^(){
        [photoListView ReloadContent];
    }];
    
}
-(NSInteger)totalPhotoNum
{
    NSInteger total = 0;
    for (NSNumber *number in photoNumList) {
        total += [number integerValue];
    }
    return total;
}
-(void)LoadPhotosForIndex:(NSUInteger)index callback:(void (^)())callback
{
    NSInteger userIdx = -1;
    
    NSInteger startIndex = 0;
    NSInteger endIndex = 0;
    NSInteger counter = 0;
    for (NSNumber *number in photoNumList) {
        endIndex = startIndex + [number integerValue];
        if (index < endIndex) {
            userIdx = counter;
            break;;
        }
        startIndex = endIndex;
        counter++;
    }
    if (userIdx == -1) {
        NSLog(@"out of range!");
        callback();
        return;
    }
    NSString *nsID = self.albumData.shareList[userIdx];
    
    NSInteger realIndex = index - startIndex;
    
    
    NSUInteger pageIdx = realIndex / FLICKR_PHOTO_PER_PAGE + 1;
    NSString *loadingKey = [NSString stringWithFormat:@"%d+%d",userIdx,pageIdx];
    if ([currentLoadingPage indexOfObject:loadingKey] != NSNotFound) {
        return;
    }
    

    [currentLoadingPage addObject:loadingKey];
    
    

    
    [AppManager getFlickrPhotoListInAlbum:self.albumData.albumName NSID:nsID WithPage:pageIdx callback:^(NSUInteger currentPage,NSUInteger totalPage,NSUInteger totalPhoto,NSArray* pList){
        
        //        totalPhotoNum = totalPhoto;
        NSInteger photoIdx = 0;
        for (FlickrPhoto* photo in pList) {
            photoURLDict[@(startIndex + (pageIdx - 1) * FLICKR_PHOTO_PER_PAGE+photoIdx)] = photo;
            photoIdx++;
        }
        photoNumList[userIdx] = @(totalPage);
        [currentLoadingPage removeObject:loadingKey];
        if (callback) {
            callback();
        }
    }];
        
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IPaListScrollViewDelegate
-(BOOL) isIPaListScrollViewColumnMajor:(IPaListScrollView *)scrollView
{
    return NO;
}
-(NSUInteger) IPaListScrollViewTotalItemsNum:(IPaListScrollView*)scrollView
{
    return self.totalPhotoNum;
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
    FlickrPhoto *photo = photoURLDict[@(Index)];
    
    FlickrPhotoButton *button = (FlickrPhotoButton*)Item;
    
    button.tag = Index;
    if (photo == nil) {
        //沒資料,去抓照片
        
        [self LoadPhotosForIndex:Index callback:^(){
            [photoListView ReloadContent];
        }];
        [button setSelected:NO];
    }
    else
    {
        
        button.photo = photo;
        
        [button setSelected:NO];
    }
    
    
    
}
-(void)onSelect:(FlickrPhotoButton*)sender
{
    if (sender.photo == nil) {
        return;
    }
//    [sender.photo getMaxImageURL];
    

  //  selectImageURL = [photo getMaxImageURL];
    [self performSegueWithIdentifier:@"Photo.Go.Save" sender:sender];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ShowFlickrPhotoViewController* PhotoView = (ShowFlickrPhotoViewController*)segue.destinationViewController;
    
    FlickrPhotoButton* button = (FlickrPhotoButton*)sender;
    
    PhotoView.currentPhotoIndex = button.tag;
    PhotoView.delegate = self;
    
//    [PhotoView PhotoURL:selectImageURL];
}

- (void)viewDidUnload {
    photoListView = nil;
    [super viewDidUnload];
}

#pragma mark - ShowFlickrPhotoViewControllerDelegate
-(void)onGetImageWithIndex:(NSInteger)index withCallback:(void (^)(UIImage*))callback;
{
    FlickrPhoto *photo = photoURLDict[@(index)];
    if (photo == nil) {
        [self LoadPhotosForIndex:index callback:^(){
            FlickrPhoto *photo = photoURLDict[@(index)];
            [IPaURLConnection IPaURLConnectionWithURL:[photo getMaxImageURL] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20 callback:^(NSURLResponse* response,NSData* responseData){
                
                callback([UIImage imageWithData:responseData]);
            }failCallback:^(NSError* error){
                callback(nil);
            }];
        }];

    }
    else {
        [IPaURLConnection IPaURLConnectionWithURL:[photo getMaxImageURL] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20 callback:^(NSURLResponse* response,NSData* responseData){
            
            callback([UIImage imageWithData:responseData]);
        }failCallback:^(NSError* error){
            callback(nil);
        }];
    }
}
-(NSInteger)onGetAlbumTotalNumber
{
    return self.totalPhotoNum;
}
@end
