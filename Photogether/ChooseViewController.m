//
//  ChooseViewController.m
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "ChooseViewController.h"
#import "ChooseAlbumContentViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "IPaAlertView.h"
#import "AppManager.h"
#import "AppDefine.h"
#import "FlickrPhoto.h"
@interface ChooseViewController ()

@end

@implementation ChooseViewController
{
    NSMutableArray *assetGroups;
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
    assetGroups = [NSMutableArray array];
    
    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       
                       // Group enumerator Block
                       void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
                       {
                           if (group == nil)
                           {
                               return;
                           }
                           
                           [assetGroups addObject:group];
                           
                           // Reload albums
                           [albumTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                           
                       };
                       
                       // Group Enumerator Failure Block
                       void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                           if (error.code == -3311) {
                               [IPaAlertView IPaAlertViewWithTitle:@"錯誤" message:@"需使用定位服務，請至設定-定位服務中開啟" cancelButtonTitle:@"OK"];
                           }
                           else {
                               [IPaAlertView IPaAlertViewWithTitle:@"錯誤" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] cancelButtonTitle:@"OK"];
                           }
                           NSLog(@"A problem occured %@", [error description]);
                       };
                       
                       // Enumerate Albums
                       [[AppManager assetLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll
                                                                      usingBlock:assetGroupEnumerator
                                                                    failureBlock:assetGroupEnumberatorFailure];
               
                       
                   });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    albumTableView = nil;
    [super viewDidUnload];
    
}


- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //相本+flickr相本
    return assetGroups.count + 1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chooseTableViewCell"];
    // Configure the cell...
    // Get count
    
    if (indexPath.row < assetGroups.count) {
        //內建相本
        ALAssetsGroup *g = (ALAssetsGroup*)[assetGroups objectAtIndex:indexPath.row];
        [g setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:1];
        UILabel *textLabel = (UILabel*)[cell viewWithTag:2];
        [textLabel setText:[g valueForProperty:ALAssetsGroupPropertyName]];
        CGRect frame = textLabel.frame;
        frame.size = [textLabel.text sizeWithFont:textLabel.font];
        textLabel.frame = frame;
        
        
        
        //    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",[g valueForProperty:ALAssetsGroupPropertyName], gCount];
        [imgView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup*)[assetGroups objectAtIndex:indexPath.row] posterImage]]];
        //	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else {
        
        //Flickr
        
        
        UILabel *textLabel = (UILabel*)[cell viewWithTag:2];

        [textLabel setText:@"Flickr"];
        


        [AppManager getSinglePhotoWithCallback:^(FlickrPhoto* photo){
            [photo getImageWithSize:FLICKR_PHOTO_SIZE_Small callback:^(UIImage* image){

                UITableViewCell *targetcell = [albumTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:assetGroups.count inSection:0]];
                UIImageView *imgView = (UIImageView*)[targetcell viewWithTag:1];
                [imgView setImage:image];
            }];
            
        }];
        
    }
    
    
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < assetGroups.count) {
        //內建相本
        [self performSegueWithIdentifier:@"choose.showAlbumContent" sender:self];
    }
    else {
        //Flickr
        [self performSegueWithIdentifier:@"choose.showFlickrAlbum" sender:self];
    }
}
#pragma mark - Storyboard notification
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [albumTableView indexPathForSelectedRow];
    
    
    [albumTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([segue.identifier isEqualToString:@"choose.showAlbumContent"]) {
        //內建相本
        
        ALAssetsGroup *group = [assetGroups objectAtIndex:indexPath.row];
        NSMutableArray *assetList = [NSMutableArray array];
        
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
         {
             if(result == nil)
             {
                 return;
             }
             [assetList addObject:result];
         }];
        ChooseAlbumContentViewController *albumContentViewController = (ChooseAlbumContentViewController*)segue.destinationViewController;
        albumContentViewController.assetList = assetList;
        
    }
    else if([segue.identifier isEqualToString:@"choose.showFlickrAlbum"]) {
        
    }
}
@end
