//
//  ChooseAlbumContentViewController.m
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "ChooseAlbumContentViewController.h"
#import "IPaListScrollView.h"
#import "AssetPickerButton.h"
#import "ChoosePhotoUploadViewController.h"

@interface ChooseAlbumContentViewController () <IPaListScrollViewDelegate>

@end

@implementation ChooseAlbumContentViewController
{
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
	// Do any additional setup after loading the view.
    selectedArray = [@[] mutableCopy];
    [photoListView setControlDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDoSelectPhoto:(id)sender {
}
- (void)viewDidUnload {
    photoListView = nil;
    [super viewDidUnload];
}

-(void)onSelectAsset:(AssetPickerButton*)sender
{
    if ([selectedArray indexOfObject:sender.asset] != NSNotFound) {
        //已被選擇，取消選擇
        
        [selectedArray removeObject:sender.asset];
        
        [sender setSelected:NO];
    }
    else {
        [selectedArray addObject:sender.asset];
        
        [sender setSelected:YES];
    }
}
#pragma mark - IPaListScrollViewDelegate
-(BOOL) isIPaListScrollViewColumnMajor:(IPaListScrollView *)scrollView
{
    return NO;
}
-(NSUInteger) IPaListScrollViewTotalItemsNum:(IPaListScrollView*)scrollView
{
    return [self.assetList count];
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
    AssetPickerButton *button = [[AssetPickerButton alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    
    [button addTarget:self action:@selector(onSelectAsset:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}
-(void) configureIPaListScrollView:(IPaListScrollView*)scrollView withItem:(UIView*)Item withIdx:(NSUInteger)Index
{
    ALAsset *asset = [self.assetList objectAtIndex:Index];
    
    AssetPickerButton *button = (AssetPickerButton*)Item;
    
    button.asset = asset;
    
    
    [button setSelected:([selectedArray indexOfObject:asset] != NSNotFound)];
}
#pragma mark - Storyboard notification
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"choose.showAlbumContent.upload"]) {
        ChoosePhotoUploadViewController *viewController = (ChoosePhotoUploadViewController*)segue.destinationViewController;
        viewController.photoList = selectedArray;
        
    }
}

@end
