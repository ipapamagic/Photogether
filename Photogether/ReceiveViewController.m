//
//  ReceiveViewController.m
//  PhotoShare
//
//  Created by IPaPa on 12/10/11.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "ReceiveViewController.h"
#import "IPaRateView.h"

@interface ReceiveViewController ()
{
    IBOutlet UITableView* receivTableView;
    
    NSMutableArray* tableArray;
}
- (IBAction) BackPage:(id)sender;
@end

@implementation ReceiveViewController

#pragma mark - action
- (void)BackPage:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    NSDictionary* item = [tableArray objectAtIndex:row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"receiveTablecell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"receiveTablecell"];
        [cell setAccessoryView:[[IPaRateView alloc] init]];
    }
    
    [cell.imageView setImage:[UIImage imageNamed:@"buddyicon.gif"]];
    [cell.textLabel setText:[item objectForKey:@"Note"]];
    
    IPaRateView* rateView = (IPaRateView*)cell.accessoryView;
    rateView.albumName = [item objectForKey:@"Note"];//setting Album Name to Key
    return cell;
    
	//-----------------------
	
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - main life cycle
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
    tableArray = [[NSMutableArray alloc] initWithCapacity:0];
    [tableArray addObjectsFromArray:
     [NSArray arrayWithObjects:
      [NSDictionary dictionaryWithObjectsAndKeys:@"員工旅遊", @"Note", [NSArray arrayWithObjects:@"", @"", @"", nil], @"Url", nil],
      [NSDictionary dictionaryWithObjectsAndKeys:@"宜蘭快活行", @"Note", [NSArray arrayWithObjects:@"", @"", nil], @"Url", nil],nil]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
