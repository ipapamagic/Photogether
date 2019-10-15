//
//  FriendViewController.m
//  PhotoShare
//
//  Created by IPaPa on 12/10/11.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "FriendViewController.h"
#import "IPaAlbumCell.h"
#import "IPaFriendsCell.h"
#import "AlbumData.h"
#import "EditAlbumViewController.h"
#import "AppDefine.h"
#import "AppManager.h"
#import "ShowFlickAlbumPhotosViewController.h"

enum ShowCell
{
    ShowAlbumMode = 0,
    ShowFriendsMode = 1,
    ShowNearbyMode = 2
};

@interface FriendViewController ()
{
    IBOutlet UIButton* AddBtn;
    IBOutlet UIButton* AlbumBtn;
    IBOutlet UIButton* FriendsBtn;
    IBOutlet UIButton* NearbyBtn;
    
    IBOutlet UILabel* TitleLabel;
    IBOutlet UITableView* FriendTableView;
    
    IBOutlet UIView* LoadingView;
    
    UIButton* selectBtn;
    
    NSMutableArray* tableArray;
    
    
    NSInteger showTableCellType;
    
    BOOL IsNewAlbum;
    
    AlbumData* selectAlbumData;
}
- (IBAction) BackPage:(id)sender;
- (IBAction) SelectAlbum:(id)sender;
- (IBAction) SelectFriend:(id)sender;
- (IBAction) SelectNearby:(id)sender;
- (IBAction) CreateAlbum:(id)sender;
@end

@implementation FriendViewController

#pragma mark - Private
- (void) ButtonRun:(UIButton*)btn
{
    if (btn.isSelected) {
        return;
    }
    btn.selected = YES;
    if (selectBtn) {
        selectBtn.selected = NO;
    }
    selectBtn = btn;
    
    [TitleLabel setText:btn.titleLabel.text];
    
    [FriendTableView reloadData];
}

#pragma mark - action
- (void)BackPage:(id)sender
{
//    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)SelectAlbum:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    
    [self ButtonRun:btn];
    [AddBtn setHidden:NO];
    
    [LoadingView setHidden:NO];
    [AppManager getAlbumList:^(NSArray* array){
        [tableArray removeAllObjects];
        showTableCellType = ShowAlbumMode;
        [tableArray addObjectsFromArray:array];
        [FriendTableView reloadData];
        [LoadingView setHidden:YES];
    }];
}

- (void)SelectFriend:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    
    [self ButtonRun:btn];
    [AddBtn setHidden:YES];
    
    [LoadingView setHidden:NO];
    [AppManager getFriendList:^(NSArray* array){
        [tableArray removeAllObjects];
        showTableCellType = ShowFriendsMode;
        [tableArray addObjectsFromArray:array];
        [FriendTableView reloadData];
        [LoadingView setHidden:YES];
    }];
}

- (void)SelectNearby:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    
    [self ButtonRun:btn];
    [AddBtn setHidden:YES];
    [LoadingView setHidden:NO];
    [AppManager getFriendList:^(NSArray* array){
        [tableArray removeAllObjects];
        showTableCellType = ShowNearbyMode;
        [tableArray addObjectsFromArray:array];
        [FriendTableView reloadData];
        [LoadingView setHidden:YES];
    }];
}

- (void)CreateAlbum:(id)sender
{
    IsNewAlbum = YES;
    selectAlbumData = nil;
    [self performSegueWithIdentifier:@"Album.To.EditAlbum" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Album.To.ShowAlbum"]) {
        ShowFlickAlbumPhotosViewController *viewControllet = (ShowFlickAlbumPhotosViewController*)segue.destinationViewController;
        NSIndexPath *indexPath = [FriendTableView indexPathForSelectedRow];
        AlbumData* album = [tableArray objectAtIndex:indexPath.row];
        viewControllet.albumData = album;
        [FriendTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        EditAlbumViewController* editView = (EditAlbumViewController*)segue.destinationViewController;
        [editView IsNewAlbum:IsNewAlbum AlbumData:selectAlbumData];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1; //只有一個類別(for 歌詞)
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    
    if (showTableCellType == ShowAlbumMode) {
        IPaAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumTableViewCell"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"IPaAlbumCell" owner:self options:nil] objectAtIndex:0];
            [cell EnableCheckBox:check_Edit];
        }
//        NSDictionary* item = [tableArray objectAtIndex:row];
//        AlbumData* album = [[AlbumData alloc] initWithAlbumName:[item objectForKey:@"Note"] shareList:[item objectForKey:@"Url"]];
        AlbumData* album = [tableArray objectAtIndex:row];
        [cell setAlbumData:album];
        
        cell.AlbumCellCallBack = ^(AlbumData* album){
            IsNewAlbum = NO;
            selectAlbumData = album;
            [self performSegueWithIdentifier:@"Album.To.EditAlbum" sender:self];
        };
        
        return cell;
    }else{
        IPaFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendsTableViewCell"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"IPaFriendsCell" owner:self options:nil] objectAtIndex:0];
        }
        NSString* item = [tableArray objectAtIndex:row];
//        cell.NSID = [item objectForKey:@"Note"];
        if (showTableCellType == ShowFriendsMode) {
            cell.NSID = item;
            [cell SetStateType:DeleteType];
        }else{
            cell.NSID = item;//[item objectForKey:@"Nearby"];
            [cell SetStateType:AddType];
        }
        cell.FriendCellCallBack = ^(NSString* NSID){
            NSLog(@"Select %@", NSID);
        };
        return cell;
    }
    return nil;	
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (showTableCellType == ShowAlbumMode) {
        //ipa 開啟相本
        
        
        [self performSegueWithIdentifier:@"Album.To.ShowAlbum" sender:self];
    }
}

#pragma mark - main lifecycle
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
    selectAlbumData = nil;
    IsNewAlbum = NO;
    selectBtn = AlbumBtn;
    selectBtn.selected = YES;
    showTableCellType = ShowAlbumMode;
    
    tableArray = [[NSMutableArray alloc] initWithCapacity:0];
//    [tableArray addObjectsFromArray:
//     [NSArray arrayWithObjects:
//      [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"員工旅遊%@12342", ALBUMNAME_MARK], @"Note", [NSArray arrayWithObjects:@"", @"", @"", nil], @"Url", @"Ben Huang" , @"Friends", @"Mars", @"Nearby", nil],
//      [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"宜蘭快活行%@4646", ALBUMNAME_MARK], @"Note", [NSArray arrayWithObjects:@"", @"", nil], @"Url", @"IPaPa" , @"Friends", @"Alice", @"Nearby", nil],nil]];
    
    [AppManager getAlbumList:^(NSArray* array){
        [tableArray addObjectsFromArray:array];
        [FriendTableView reloadData];
        [LoadingView setHidden:YES];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
