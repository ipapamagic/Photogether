//
//  ChooseFlickrAlbumViewController.m
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "ChooseFlickrAlbumViewController.h"
#import "AppManager.h"
#import "AlbumData.h"
#import "FlickrPhoto.h"
#import "FlickrPhotoImgView.h"
#import "ChooseFlickrContentViewController.h"
@interface ChooseFlickrAlbumViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation ChooseFlickrAlbumViewController
{
    NSArray *flickrAlbumList;
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
- (void)viewDidUnload {
    flickrAlbumTableView = nil;
    [super viewDidUnload];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //相本+flickr相本
    return flickrAlbumList.count +1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chooseFlickrAlbumCell"];
    // Configure the cell...
    // Get count
    FlickrPhotoImgView* imgView = (FlickrPhotoImgView*)[cell viewWithTag:1];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:2];
    
    if (indexPath.row == 0) {
        [textLabel setText:@"ALL"];
        [imgView setImage:nil];
        [AppManager getSinglePhotoWithCallback:^(FlickrPhoto* photo){
            UITableViewCell *targetCell = [flickrAlbumTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            FlickrPhotoImgView *targetImgView = (FlickrPhotoImgView*)[targetCell viewWithTag:1];
            targetImgView.photoID = photo.photoID;
        }];
    }
    else {
        NSUInteger index = indexPath.row-1;
        
        
        AlbumData *albumData = flickrAlbumList[index];
        [imgView setImage:nil];
        [textLabel setText:albumData.visibleName];
        if (albumData.albumName != nil) {
            [AppManager getAlbumTitlePhoto:albumData.albumName callback:^(FlickrPhoto* photo){
                UITableViewCell *targetCell = [flickrAlbumTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index+1 inSection:0]];
                FlickrPhotoImgView* targetImgView = (FlickrPhotoImgView*)[targetCell viewWithTag:1];
                targetImgView.photoID = photo.photoID;
            }];

        }
    
    }
    
    
    
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"choose.showFlickrContent" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [flickrAlbumTableView indexPathForSelectedRow];
    [flickrAlbumTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([segue.identifier isEqualToString:@"choose.showFlickrContent"]) {
        ChooseFlickrContentViewController *viewController = (ChooseFlickrContentViewController*)segue.destinationViewController;
        if (indexPath.row > 0) {
            AlbumData *albumData = flickrAlbumList[indexPath.row - 1];
            viewController.albumName = albumData.albumName;
        }
        else {
            viewController.albumName = nil;
        }

    }
}
@end
