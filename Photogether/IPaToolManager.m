//
//  IPaToolManager.m
//  IPaToolManager
//
//  Created by 陳 尤中 on 11/10/26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "IPaToolManager.h"
IPaToolManager *ToolMgr = nil;
@implementation IPaToolManager

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        ToolList = [[NSMutableArray alloc] init];
    }
    
    return self;
}
-(void)RetainTool:(id)Tool
{
    [ToolList addObject:Tool];
}
-(void)ReleaseTool:(id)Tool
{
    [ToolList removeObject:Tool];
}

+(void)RetainTool:(id)Tool
{
    if (ToolMgr == nil) {
        ToolMgr = [[IPaToolManager alloc] init];
    }
    [ToolMgr RetainTool:Tool];
    
}
+(void)ReleaseTool:(id)Tool
{
    if (ToolMgr == nil) {
        return;
    }
    [ToolMgr ReleaseTool:Tool];
}

@end
