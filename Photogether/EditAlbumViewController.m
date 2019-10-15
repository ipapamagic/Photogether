//
//  EditAlbumViewController.m
//  Photogether
//
//  Created by Apple on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "EditAlbumViewController.h"
#import "AppManager.h"
#import "IPaAlertView.h"
#import "IPaFriendsCell.h"
#import "AlbumData.h"

@interface EditAlbumViewController ()
{
    IBOutlet UILabel* AlbumNameLabel;
    IBOutlet UITextField* NewAlbumName;
    IBOutlet UITableView* editTableView;
    IBOutlet UIView* LoadingView;
    IBOutlet UIButton* CreateAlbumBtn;
    
    BOOL isCreate;
    
    NSMutableArray* editTableArray;
    NSMutableArray* friendsArray;
    NSMutableArray* addAlbumArray;
    
    AlbumData* albumData;
}
- (IBAction) BackPage:(id)sender;
- (IBAction) OKPage:(id)sender;
@end

@implementation EditAlbumViewController


#pragma mark - textFieldDelegate
-(BOOL) textFieldShouldReturn:(UITextField *) theTextField
{
	[theTextField resignFirstResponder]; // CLOSE Keyboard
    
    if (![theTextField.text isEqualToString:@""]) {// && [addAlbumArray count] != 0
        [CreateAlbumBtn setEnabled:YES];
    }else{
        [CreateAlbumBtn setEnabled:NO];
    }
    
	return	YES;
}

#pragma mark - action
- (void) IsNewAlbum:(BOOL)bCreate AlbumData:(AlbumData*)album
{
    isCreate = bCreate;
    albumData = album;
}

- (void)BackPage:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)OKPage:(id)sender
{
    [LoadingView setHidden:NO];
    if (isCreate) {
        [AppManager createAlbumWithName:NewAlbumName.text callback:^(NSString* albumName){
            if (![albumName isEqualToString:@""]) {
                [AppManager shareAlbum:albumName withFriends:addAlbumArray callback:^(BOOL success){
                    if (success) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }else{
                        [LoadingView setHidden:NO];
                    }
                }];
            }else{
                [LoadingView setHidden:NO];
            }
        }];
    }else{

        [AppManager shareAlbum:albumData.albumName withFriends:addAlbumArray callback:^(BOOL success){
            if (success) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [LoadingView setHidden:NO];
            }
        }];

    }

}

#pragma mark - UITableViewDataSource
- (NSString*)tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section
{
	if(section == 0)
		return @"Share";
	else
		return @"Waiting Share";
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [editTableArray count]; //只有一個類別(for 歌詞)
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[editTableArray objectAtIndex:section] count];
}

- (IPaFriendsCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    NSString* item = [[editTableArray objectAtIndex:section] objectAtIndex:row];
    
    IPaFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendsTableViewCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"IPaFriendsCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.NSID = item;
    
    if (section == 0) {
        [cell SetStateType:DeleteType];
    }else
        [cell SetStateType:AddType];
    
    cell.FriendCellCallBack = ^(NSString* NSID){
        NSLog(@"Select %@", NSID);
        
        if (section ==1) {
            [addAlbumArray addObject:NSID];
            
            NSInteger loop = 0;
            for (NSString* item in friendsArray) {
                if ([item isEqualToString:NSID]) {
                    break;
                }
                loop++;
            }
            [friendsArray removeObjectAtIndex:loop];
            [editTableView reloadData];
        }else{
            [friendsArray addObject:NSID];
            
            NSInteger loop = 0;
            for (NSString* item in addAlbumArray) {
                if ([item isEqualToString:NSID]) {
                    break;
                }
                loop++;
            }
            [addAlbumArray removeObjectAtIndex:loop];
            [editTableView reloadData];
        }
        
//        if (![NewAlbumName.text isEqualToString:@""] && [addAlbumArray count] != 0) {
//            [CreateAlbumBtn setEnabled:YES];
//        }else{
//            [CreateAlbumBtn setEnabled:NO];
//        }
        
    };
    
    return cell;
    
	//-----------------------
	
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - life cycle
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
    addAlbumArray = [[NSMutableArray alloc] initWithCapacity:0];
    friendsArray = [[NSMutableArray alloc] initWithCapacity:0];
    editTableArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [LoadingView setHidden:NO];
    if (isCreate) {
        [AlbumNameLabel setHidden:YES];
        [NewAlbumName setHidden:NO];
    }else{
        [AlbumNameLabel setText:albumData.visibleName];
        [AlbumNameLabel setHidden:NO];
        [NewAlbumName setHidden:YES];
        [CreateAlbumBtn setEnabled:YES];
    }
    
    [AppManager getFriendList:^(NSArray* array){
        for (NSString* nsid in array) {
            NSPredicate* filter = [NSPredicate predicateWithFormat:@"SELF IN %@", nsid];
            NSArray* arrayHave = [albumData.shareList filteredArrayUsingPredicate:filter];
            if ([arrayHave count] != 0) {
                [addAlbumArray addObject:[NSString stringWithString:nsid]];
            }else{
                [friendsArray addObject:[NSString stringWithString:nsid]];
            }
        }
        [editTableArray addObject:addAlbumArray];
        [editTableArray addObject:friendsArray];
        [LoadingView setHidden:YES];
        [editTableView reloadData];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
