//
//  IPaRateView.m
//  Photogether
//
//  Created by Apple on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaRateView.h"

@implementation IPaRateView

#pragma mark - Nontification
- (void)setAlbumName:(NSString *)albumName
{
    _albumName = albumName;
}

#pragma mark - life cycle
-(id) init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Temp:) name:@"waitIPa" object:nil];
        
        [self setFrame:CGRectMake(0, 0, 100, 60)];
        [self setBackgroundColor:[UIColor clearColor]];
        
        rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 35)];
        [rateLabel setText:@"waiting"];
        [rateLabel setTextAlignment:UITextAlignmentCenter];
        [rateLabel setBackgroundColor:[UIColor clearColor]];
        [rateLabel setTextColor:[UIColor grayColor]];
        [self addSubview:rateLabel];
        
        rateProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 40, 80, 9)];
        [rateProgress setTrackImage:[UIImage imageNamed:@"p_bar_bg@2x.png"]];
        [rateProgress setProgressImage:[UIImage imageNamed:@"p_bar_on@2x.png"]];
        [rateProgress setProgress:0.0f];
        [self addSubview:rateProgress];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
