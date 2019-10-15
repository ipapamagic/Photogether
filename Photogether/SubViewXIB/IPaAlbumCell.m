//
//  IPaAlbumCell.m
//  Photogether
//
//  Created by Apple on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "IPaAlbumCell.h"
#import "IPaURLConnection.h"
#import "FlickrUserImgView.h"
#import "AlbumData.h"
@implementation IPaAlbumCell

#pragma mark - action
- (void) EditAlbum:(id)sender
{
    if(self.AlbumCellCallBack)
    {
        self.AlbumCellCallBack(self.albumData);
    }
}

#pragma mark - public
- (void)EnableCheckBox:(NSInteger)type
{
    CGRect rect = NoteLabel.frame;
    rect.size.width -= CheckView.frame.size.width;
    [NoteLabel setFrame:rect];
    rect = CustomView.frame;
    rect.size.width -= CheckView.frame.size.width;
    [CustomView setFrame:rect];
    [CheckView setHidden:NO];
    
    showCheckType = type;
    if (showCheckType == check_Select) {
        [CheckView setImage:[UIImage imageNamed:@"list_select@2x.png"]];
        [CheckView setHidden:NO];
        [EditBtn setHidden:YES];
    }else{
        [CheckView setHidden:YES];
        [EditBtn setHidden:NO];
    }
}
-(void)setAlbumData:(AlbumData *)albumData
{
    _albumData = albumData;
    
    [self SetNoteLabelText:albumData.visibleName];
    [self SetPicShow:albumData.shareList];
}
- (void)SetNoteLabelText:(NSString *)text
{
    [NoteLabel setText:text];
}

- (void)SetPicShow:(NSArray *)nsIDList
{
    if ([nsIDList count] == 0) {
        NSLog(@"this imageURLArray is nil!");
    }


    NSInteger count = [nsIDList count] > 10 ? 10 : [nsIDList count];
    
    NSInteger loop = 0;
    for (UIView* view in CustomView.subviews) {
        if (view.tag >= 2012) {
            NSString* link = [nsIDList objectAtIndex:loop];
            
            FlickrUserImgView* imageView = (FlickrUserImgView*)view;
            [imageView setNSID:link];
            loop++;
            if (loop >= count) {
                break;
            }
        }
    }
    
    
//    float picBorder = 26.0f;
//    float xPos = 0.0f;
//    float yPos = 0.0f;
//    for(int loop = 0; loop < count; loop++)
//    {
//        NSString* link = [imageURLArray objectAtIndex:loop];
//        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, yPos, picBorder, picBorder)];
//        
//        IPaURLConnection* urlConnection = [[IPaURLConnection alloc] initWithURL:link cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0f callback:^(NSURLResponse *response,NSData* data){
//            
//            [imageView setImage:[UIImage imageWithData:data]];
//            [CustomView addSubview:imageView];
//        }failCallback:^(NSError* error){
//            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, yPos, picBorder, picBorder)];
//            [imageView setImage:[UIImage imageNamed:@"buddyicon.png"]];
//            [CustomView addSubview:imageView];
//        }];
//        xPos += picBorder;
//        
//        [urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop]
//                                 forMode:NSRunLoopCommonModes];
//        [urlConnection start];
//    }

}

- (void) awakeFromNib
{
    [super awakeFromNib];
//    showCheckType = check_Select;
    float picBorder = 26.0f;
    float xPos = 0.0f;
    float yPos = 0.0f;
    for(int loop = 0; loop < 10; loop++)
    {
        FlickrUserImgView* imageView = [[FlickrUserImgView alloc] initWithFrame:CGRectMake(xPos, yPos, picBorder, picBorder)];
        imageView.tag = loop + 2012;
        [CustomView addSubview:imageView];
        xPos += picBorder;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    if (showCheckType == check_Select) {
        if (selected) {
            [CheckView setImage:[UIImage imageNamed:@"list_select@2x.png"]];
        }else{
            [CheckView setImage:[UIImage imageNamed:@"list_unselect@2x.png"]];
        }
    }
}

@end
