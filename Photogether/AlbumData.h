//
//  AlbumData.h
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumData : NSObject
@property (nonatomic,copy) NSString *albumName;
//分享NSID 列表
@property (nonatomic,strong) NSArray *shareList;
@property (nonatomic,readonly) NSString *visibleName;
-(id)initWithAlbumName:(NSString*)name shareList:(NSArray*)list;
@end
