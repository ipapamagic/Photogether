//
//  AlbumData.m
//  Photogether
//
//  Created by IPaPa on 12/10/20.
//  Copyright (c) 2012年 IPaPa. All rights reserved.
//

#import "AlbumData.h"
#import "AppManager.h"
#import "AppDefine.h"
@interface AlbumData ()
@end
@implementation AlbumData
-(id)initWithAlbumName:(NSString*)name shareList:(NSArray*)list
{
    self = [super init];
    self.albumName = [name copy];
    self.shareList = [list copy];
    return self;
}
-(NSString *)visibleName
{
    NSRange range = [self.albumName rangeOfString:ALBUMNAME_MARK];
    return [self.albumName substringToIndex:range.location];
}
@end
