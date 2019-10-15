//
//  IPaXMLSection.h
//  IPaXMLSection
//
//  Created by 陳 尤中 on 11/12/29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

/*使用時，請記得加入libxml2.dylib的library
 
 並且在header search path的地方加入
 
 $(SDKROOT)/usr/include/libxml2/ **
 
 上面的**前面有空白，請拿掉
 */

#import <Foundation/Foundation.h>
#include <libxml/tree.h>
@interface IPaXMLSection : NSObject {
    
    NSString *Name;
    NSString *Value;
    //array of IPaXMLAttribute
    NSMutableDictionary *attributes;
    NSMutableArray *children;
}
-(id)initWithXMLData:(NSData*)data;
-(id)initWithXMLFile:(NSString*)fileName;
-(id)initWithXMLNode:(xmlNodePtr)node;
//取得名稱為key的子node
-(NSArray*)SectionsWithKey:(NSString*)key;
//取得第一個名稱為key的子node
-(IPaXMLSection*)FirstSectionWithKey:(NSString*)key;
//取得名稱為key的子node的value
-(NSString *)ReadFirstChildValue:(NSString*)key;
//取得所有名稱為key的子node的value
-(NSArray*)ReadChildrenValue:(NSString*)key;
//把children的Name和value轉成一個dictionary，若有重複的key值，較後面的會取代前面的
//只有處理一層而已，children的children不會作處理
-(NSDictionary*)childrenAsDictionary;
@property (nonatomic,copy) NSString *Name;
@property (nonatomic,copy) NSString *Value;
@property (nonatomic,strong) NSMutableDictionary *attributes;
@property (nonatomic,strong) NSMutableArray *children;
@end
