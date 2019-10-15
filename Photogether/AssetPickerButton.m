//
//  AssetPickerButton.m
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "AssetPickerButton.h"

@implementation AssetPickerButton
{
    UIImageView *overlayView;
}
@synthesize asset = _asset;
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    overlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photoselect.png"]];
    [self addSubview:overlayView];
    [overlayView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    return self;
}
-(void)setAsset:(ALAsset *)asset
{
    _asset = asset;
    //    ALAssetRepresentation *represent = _asset.defaultRepresentation;
    UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];//_asset.thumbnail];
    //NSData *data = [NSData dataWithContentsOfURL:url];
    
    //image = [UIImage imageWithData:data];
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateSelected];
    
}
-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    [overlayView setHidden:!selected];
}
@end
