//
//  IPaToolManager.h
//  IPaToolManager
//
//  Created by 陳 尤中 on 11/10/26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPaToolManager : NSObject {
    
    NSMutableArray *ToolList;
}
+(void)RetainTool:(id)Tool;
+(void)ReleaseTool:(id)Tool;

-(void)RetainTool:(id)Tool;
-(void)ReleaseTool:(id)Tool;
@end

