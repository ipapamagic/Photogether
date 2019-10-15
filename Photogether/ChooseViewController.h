//
//  ChooseViewController.h
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    
    IBOutlet UITableView *albumTableView;
}
- (IBAction)onBack:(id)sender;


@end
