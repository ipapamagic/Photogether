//
//  ChooseFlickrPhotoShareViewController.m
//  Photogether
//
//  Created by IPaPa on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "ChooseFlickrPhotoShareViewController.h"
#import "IPaListScrollView.h"
#import "FlickrPhotoButton.h"
#import "AppManager.h"
#import "IPaAlbumCell.h"
#import "FlickrPhoto.h"
#import "AlbumData.h"
@interface ChooseFlickrPhotoShareViewController () <IPaListScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation ChooseFlickrPhotoShareViewController
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
    cancelArray = [@[] mutableCopy];
	// Do any additional setup after loading the view.
    [photoListView setControlDelegate:self];
    [AppManager getAlbumList:^(NSArray *albumList){
        flickrAlbumList = albumList;
        [albumTableView reloadData];
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
- (void)viewDidUnload {
    photoListView = nil;
    albumTableView = nil;
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

    // Configure the cell...
    // Get count
    cell.albumData = flickrAlbumList[indexPath.row];
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    AlbumData* data = flickrAlbumList[indexPath.row];
    
    
    
    for (FlickrPhoto *photo in self.photoList) {
        if ([cancelArray indexOfObject:photo] != NSNotFound) {
            continue;
        }
        [AppManager addPhotoID:photo.photoID toAlbumName:data.albumName callback:^(BOOL ret){
            NSLog(@"add tag result:%d",ret);
        }];
        
    }
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
    FlickrPhotoButton *button = [[FlickrPhotoButton alloc] initWithFrame:CGRectMake(0, 0, 77, 77)];
    
    [button addTarget:self action:@selector(onSelectAsset:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void) configureIPaListScrollView:(IPaListScrollView*)scrollView withItem:(UIView*)Item withIdx:(NSUInteger)Index
{
    FlickrPhoto *photo = [self.photoList objectAtIndex:Index];
    
    
    FlickrPhotoButton *button = (FlickrPhotoButton*)Item;
    
    button.photo = photo;
    
    
    [button setSelected:([cancelArray indexOfObject:photo] == NSNotFound)];}

@end
