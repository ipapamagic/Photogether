//
//  IPaRateView.h
//  Photogether
//
//  Created by Apple on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPaRateView : UIView
{
    UILabel* rateLabel;
    UIProgressView* rateProgress;
    
}
@property (nonatomic, copy) NSString* albumName;
@end
