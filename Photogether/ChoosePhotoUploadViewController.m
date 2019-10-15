//
//  ChoosePhotoUploadViewController.m
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "ChoosePhotoUploadViewController.h"
#import "AppManager.h"
#import "IPaListScrollView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AlbumData.h"
#import "FlickrPhoto.h"
#import "IPaAlbumCell.h"
#import "AssetPickerButton.h"
@interface ChoosePhotoUploadViewController () <IPaListScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation ChoosePhotoUploadViewController
{
    NSArray *flickrAlbumList;
    NSMutableArray *cancelArray;
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
    [LoadingView setHidden:YES];
	// Do any additional setup after loading the view.
    cancelArray = [@[] mutableCopy];
    [photoListView setControlDelegate:self];
    [AppManager getAlbumList:^(NSArray *albumList){
        flickrAlbumList = albumList;
        [flickrAlbumTableView reloadData];
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

- (IBAction)onDone:(id)sender {
    
    NSIndexPath *indexPath = [flickrAlbumTableView indexPathForSelectedRow];
    if (indexPath == nil) {
        return;
    }
    AlbumData* data = flickrAlbumList[indexPath.row];
    
    [LoadingView setHidden:NO];
    
    for (ALAsset *asset in self.photoList) {
        if ([cancelArray indexOfObject:asset] != NSNotFound) {
            continue;
        }
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        
        if (iref) {
            UIImage *largeimage = [UIImage imageWithCGImage:iref];
            [AppManager uploadImage:largeimage toAlbumName:data.albumName];
        }
        [LoadingView setHidden:YES];
    }
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];

    

}
- (void)viewDidUnload {
    flickrAlbumTableView = nil;
    photoListView = nil;
    [super viewDidUnload];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //flickr相本,加一個是顯示所有的照片
    return flickrAlbumList.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IPaAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumTableViewCell"];
    
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"IPaAlbumCell" owner:nil options:nil][0];
    }
    [cell EnableCheckBox:check_Select];
    // Configure the cell...
    // Get count
    cell.albumData = flickrAlbumList[indexPath.row];
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}
-(void)onSelectAsset:(AssetPickerButton*)sender
{
    if ([cancelArray indexOfObject:sender.asset] != NSNotFound) {
        //已被選擇，取消選擇
        
        [cancelArray removeObject:sender.asset];
        
        [sender setSelected:YES];
    }
    else {
        [cancelArray addObject:sender.asset];
        
        [sender setSelected:NO];
    }
}
#pragma mark - IPaListScrollViewDelegate

-(NSUInteger) IPaListScrollViewTotalItemsNum:(IPaListScrollView*)scrollView
{
    return self.photoList.count;
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

//get a new item for list view
-(UIView*) onIPaListScrollViewNewItem:(IPaListScrollView*)scrollView withItemIndex:(NSUInteger)Index
{
    AssetPickerButton *button = [[AssetPickerButton alloc] initWithFrame:CGRectMake(0, 0, 77, 77)];
    
    [button addTarget:self action:@selector(onSelectAsset:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void) configureIPaListScrollView:(IPaListScrollView*)scrollView withItem:(UIView*)Item withIdx:(NSUInteger)Index
{
    ALAsset *asset = [self.photoList objectAtIndex:Index];
    
    AssetPickerButton *button = (AssetPickerButton*)Item;
    
    button.asset = asset;
    
    
    [button setSelected:([cancelArray indexOfObject:asset] == NSNotFound)];}

@end
