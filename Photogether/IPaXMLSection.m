//
//  IPaXMLSection.m
//  IPaXMLSection
//
//  Created by 陳 尤中 on 11/12/29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "IPaXMLSection.h"
#include <libxml/xmlreader.h>
@interface IPaXMLSection (XMLNodeAPI)
-(BOOL)readXMLNode:(xmlNodePtr)node;
@end
@implementation IPaXMLSection (XMLNodeAPI)
-(BOOL)readXMLNode:(xmlNodePtr)node
{
    if (node->type == XML_DOCUMENT_NODE) {
        //document 直拉找子node，找到第一個ELEMENT 為止
        node = node->children;
        
        while (node) {
            if (node->type == XML_ELEMENT_NODE) {
                break;
            }
            node = node->next;
        }
        if (node == NULL) {
            return NO;
        }
        
    }
    else if (node->type != XML_ELEMENT_NODE) {
        
        //啟始點必須為Element node
        return NO;
    }
    if (node->name == NULL) {
        NSLog(@"Node Must have a Name!");
        return NO;
    }
    Name = [NSString stringWithCString:(const char*)node->name encoding:NSUTF8StringEncoding];
    
    //讀取attribute
    xmlAttr *attribute = node->properties;
	if (attribute)
	{
        attributes = [NSMutableDictionary dictionary];
		while (attribute)
		{
            NSString *attributeName =
            [NSString stringWithCString:(const char *)attribute->name encoding:NSUTF8StringEncoding];
            
			if (attribute->children)
			{
                xmlNodePtr attrChildNode = attribute->children;
                if (attrChildNode->type != XML_TEXT_NODE) {
                    //應該是不會到這裡才對
                    NSLog(@"Attribute Error!");
                    attribute = attribute->next;
                    continue;
                }
                
                NSString *attrValue = (attrChildNode->content != NULL)?[NSString stringWithCString:(const char*)attrChildNode->content encoding:NSUTF8StringEncoding]:@"";
                
                
				[attributes setObject:attrValue forKey:attributeName];
			}
            else
            {
                //應該是不會到這裡才對
                NSLog(@"Attribute Error!");
                attribute = attribute->next;
                continue;
            }
            attribute = attribute->next;
            
		}
	}
    //讀取子節點
    xmlNodePtr childNode = node->children;
    if (childNode != NULL) {
        //第一個child應該要是Value
        
        if (childNode->type == XML_TEXT_NODE) {            
            Value = [[NSString stringWithCString:(const char*)childNode->content encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];            
        }
        childNode = childNode->next;
        
        if (childNode != NULL) {
            children = [[NSMutableArray alloc] init];
            while (childNode) {
                if (childNode->type == XML_ELEMENT_NODE) {
                    IPaXMLSection *section = [[IPaXMLSection alloc] initWithXMLNode:childNode];
                    [children addObject:section];
                }
                childNode = childNode->next;
            }
        }
    }
    
    
    
    return YES;
}
@end
@interface IPaXMLSection (XMLTextReaderAPI)

-(BOOL)readXMLTextReader:(xmlTextReaderPtr)reader;
-(id)initWithXMLTextReaderPtr:(xmlTextReaderPtr)reader;

-(BOOL)readXMLStartElementNode:(xmlTextReaderPtr)reader;
/*-(void)readXMLDoc:(xmlDocPtr)doc;
 -(void)readXMLTextReader:(xmlNodePtr)node;
 -(void)readXMLChildrenNode:(xmlNodePtr)node;
 -(id)initWithXMLNode:(xmlNodePtr)node;*/
@end
@implementation IPaXMLSection (XMLTextReaderAPI)
-(id)initWithXMLTextReaderPtr:(xmlTextReaderPtr)reader
{
    self = [super init];
    if (![self readXMLTextReader:reader]) {
        //釋放資料
        Name = nil;
        Value = nil;
        attributes = nil;
        children = nil;
        return nil;
    }
    
    return self;
}
-(BOOL)readXMLStartElementNode:(xmlTextReaderPtr)reader
{

    if (xmlTextReaderRead(reader) != 1) {
        return NO;
    }
    
    //    NodeType: The node type
    //    1 for start element
    //    15 for end of element
    //    2 for attributes
    //    3 for text nodes
    //    4 for CData sections
    //    5 for entity references
    //    6 for entity declarations
    //    7 for PIs
    //    8 for comments
    //    9 for the document nodes
    //    10 for DTD/Doctype nodes
    //    11 for document fragment 
    //    12 for notation nodes.
    //   我自己測試14看起來是換行
    int nodeType = xmlTextReaderNodeType(reader);

    while (nodeType != 1) {
        //找到下一個start element
        if(xmlTextReaderRead(reader) != 1)
        {
            return NO;
        }
        nodeType = xmlTextReaderNodeType(reader);
    }
    return YES;
}

-(BOOL)readXMLTextReader:(xmlTextReaderPtr)reader
{
    
    //進來前已確認此node為 start element
    xmlChar *name, *value;
    
    name = xmlTextReaderName(reader);
    if (name == NULL)
    {
        //   name = xmlStrdup(BAD_CAST "--");
        return NO;
    }
    Name = [NSString stringWithCString:(const char*)name encoding:NSUTF8StringEncoding];
    xmlFree(name);
    //讀取Attribute
    if (xmlTextReaderMoveToFirstAttribute(reader)) {
        int attributeNum = xmlTextReaderAttributeCount(reader);
        if (attributeNum > 0) {
            attributes = [NSMutableDictionary dictionaryWithCapacity:attributeNum];
            
            //讀取attribute
            do {
                int nodeType = xmlTextReaderNodeType(reader);
                //錯誤判斷
                if (nodeType != 2) {
                    continue;
                }
                name = xmlTextReaderName(reader);
                value = xmlTextReaderValue(reader);
                NSString *attrName;
                NSString *attrValue;
                if (name != NULL && value != NULL) {
                    attrName = [NSString stringWithCString:(const char*)name encoding:NSUTF8StringEncoding];
                    attrValue = [NSString stringWithCString:(const char*)value encoding:NSUTF8StringEncoding];
                    
                    [attributes setObject:attrValue forKey:attrName];
                    
                }
            } while (xmlTextReaderMoveToNextAttribute(reader));
        }
    }
    
    if (!xmlTextReaderIsEmptyElement(reader)) {
        //讀取是否有value
        int nodeType;
        
        if (xmlTextReaderRead(reader)) {
            nodeType = xmlTextReaderNodeType(reader);
            if (nodeType == 3) {
                if (xmlTextReaderHasValue(reader)) {
                    //讀取value
                    
                    value = xmlTextReaderValue(reader);
                    if (value != NULL) {
                        Value = [NSString stringWithCString:(const char*)value encoding:NSUTF8StringEncoding];
                        Value = [Value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        xmlFree(value);
                    }
                    if (!xmlTextReaderRead(reader)){
                        return NO;
                    }
                }
            }
        }
        else {
            return NO;
        }
        
        children = [NSMutableArray array];
        
        do{
            
            //判斷是否是結束的Node
            nodeType = xmlTextReaderNodeType(reader);
            
            switch (nodeType) {
                case 15:
                    //只有從這邊出去才是正確的
                    return YES;
                case 1:                    
                {
                    //新的子節點
                    IPaXMLSection *newSection = [[IPaXMLSection alloc] initWithXMLTextReaderPtr:reader];
                    
                    if (newSection != nil) {
                        [children addObject:newSection];
                    }
                }
                    break;
                default:
                    break;
            }
        }while (xmlTextReaderRead(reader));
        
        return NO;   
    }
    return YES;
}

@end

@implementation IPaXMLSection
@synthesize Name;
@synthesize Value;
@synthesize attributes;
@synthesize children;
-(id)initWithXMLFile:(NSString*)fileName
{
    self = [super init];
    
    
    xmlTextReaderPtr reader = xmlNewTextReaderFilename([fileName cStringUsingEncoding:NSUTF8StringEncoding]);
    if (!reader) {
        NSLog(@"Failed to create xmlTextReader");
        return nil;
    }
    if  (xmlTextReaderSetParserProp(reader, XML_PARSER_VALIDATE, 1) != 0)
    {
        NSLog(@"Validate error!!");
        return nil;
    }
    if (![self readXMLStartElementNode:reader]) {
        NSLog(@"Read Error!!");
        xmlFreeTextReader(reader);
        return nil;
        
    }
    if (![self readXMLTextReader:reader]) {
        NSLog(@"Read Node Error!!");
        xmlFreeTextReader(reader);
        //釋放資料
        Name = nil;
        Value = nil;
        attributes = nil;
        children = nil;
        return nil;
    }
    
    xmlFreeTextReader(reader);
    return self;
}
-(id)initWithXMLData:(NSData*)data
{
    self = [super init];
    
    
    xmlTextReaderPtr reader = xmlReaderForMemory([data bytes], [data length], NULL, NULL, (XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA));// | XML_PARSE_NOERROR | XML_PARSE_NOWARNING));
    if (!reader) {
        NSLog(@"Failed to create xmlTextReader");
        return nil;
    }
    if  (xmlTextReaderSetParserProp(reader, XML_PARSER_VALIDATE, 1) != 0)
    {
        NSLog(@"Validate error!!");
        xmlFreeTextReader(reader);
        return nil;
    }
    
    if (![self readXMLStartElementNode:reader]) {
        NSLog(@"Read Error!!");
        xmlFreeTextReader(reader);
        return nil;
        
    }
    if (![self readXMLTextReader:reader]) {
        NSLog(@"Read Node Error!!");
        xmlFreeTextReader(reader);
        
        return nil;
    }
    
    
    
    xmlFreeTextReader(reader);
    
    return self;
}
-(id)initWithXMLNode:(xmlNodePtr)node
{
    self = [super init];
    
    
    
    
    if (![self readXMLNode:node]) {
        NSLog(@"Read XML Node Error!");
        return nil;
    }
    
    return self;
}
//取得第一個名稱為key的子node
-(IPaXMLSection*)FirstSectionWithKey:(NSString*)key
{
    for (IPaXMLSection* section in children) {
        if ([section.Name isEqualToString:key]) {
            return section;
        }
    }
    return nil;
}

-(NSString *)ReadFirstChildValue:(NSString*)key
{
    IPaXMLSection *subSec = [self FirstSectionWithKey:key];
    
    return (subSec == nil)?@"":subSec.Value;
}

-(NSArray*)ReadChildrenValue:(NSString*)key
{
    NSMutableArray *listArray = [NSMutableArray arrayWithCapacity:children.count];
    for (IPaXMLSection* section in children) {
        if ([section.Name isEqualToString:key]) {
            if (section.Value != nil) {
                [listArray addObject:section.Value];
            }
        }
    }
    return listArray;
    
}
//取得名稱為key的子node
-(NSArray*)SectionsWithKey:(NSString*)key
{
    NSMutableArray *array = [NSMutableArray array];
    for (IPaXMLSection* section in children) {
        if ([section.Name isEqualToString:key]) {
            [array addObject:section];
        }
    }
    return array;
}
//把children的Name和value轉成一個dictionary，若有重複的key值，較後面的會取代前面的
//只有處理一層而已，children的children不會作處理
-(NSDictionary*)childrenAsDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:children.count];
    for (IPaXMLSection* section in children) {
        [dict setObject:section.Value forKey:section.Name];
    }
    return dict;
}
@end
