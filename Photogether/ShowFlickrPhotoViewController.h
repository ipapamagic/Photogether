//
//  ShowFlickrPhotoViewController.h
//  Photogether
//
//  Created by IPaPa on 12/10/21.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ShowFlickrPhotoViewControllerDelegate;
@class IPaListScrollView;
@interface ShowFlickrPhotoViewController : UIViewController
{
    
    IBOutlet IPaListScrollView *photoListView;
}
@property (nonatomic,weak) id<ShowFlickrPhotoViewControllerDelegate> delegate;
@property (nonatomic,assign) NSInteger currentPhotoIndex;
@end


@protocol ShowFlickrPhotoViewControllerDelegate <NSObject>

-(void)onGetImageWithIndex:(NSInteger)index withCallback:(void (^)(UIImage*))callback;
-(NSInteger)onGetAlbumTotalNumber;
@end