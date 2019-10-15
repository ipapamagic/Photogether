//
//  IPaAlertView.m
//  TofuMemo
//
//  Created by 陳 尤中 on 11/9/8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//


/*
 NSMethodSignature is the type signature of a method on a class or an object. You typically retrieve them by using NSObject's -methodSignatureForSelector: and +methodSignatureForSelector: for instances and classes, respectively.
 
 Commonly, method signatures are used to create instances of NSInvocation, and if you're writing an NSProxy subclass you'll probably want them too. They're very froody.
 
 There is an undocumented private method, +signatureWithObjCTypes:, on NSMethodSignature which (apparently) allows you to create an arbitrary NSMethodSignature on the fly; this would be a great boon for many runtime hacks (see HigherOrderMessaging for greater detail into the subject).
 
 Note that this method is exposed as of Leopard, so it probably doesn't belong in "Undocumented Goodness" anymore.
 
 Documentation for it can be found by looking up the GNUStep or OpenStep specifications. An example argument to signatureWithObjCTypes: is "@^v^ci", a method which takes an integer and returns an object. The first bit, @, is the return type of id; ^v^c is arguments of a void* and a char*, the hidden arguments of every ObjC method, and the final i is the 'real' argument.*/

#import "IPaToolManager.h"
#import "IPaAlertView.h"

@implementation IPaAlertView
//@synthesize Title;
//@synthesize Message;
//@synthesize userData;
+(id) IPaAlertViewWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle
{
    IPaAlertView* newView = [[IPaAlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle];
    
    [newView show];
    return newView;
}


+(id)IPaAlertViewWithTitle:(NSString*)title message:(NSString*)message 
                  callback:(void (^)(NSInteger))callback
         cancelButtonTitles:(NSString*)cancelButtonTitle ,...

{
    IPaAlertView* newView = [[IPaAlertView alloc] initWithTitle:title message:message callback:callback
                                              cancelButtonTitles:cancelButtonTitle,nil];
    
    
    //NSMutableArray *array = [[NSMutableArray alloc] init];
    //[array addObject:cancelButtonTitle];
    id current = cancelButtonTitle;
    va_list argumentList;
    va_start(argumentList, cancelButtonTitle);
    current = va_arg(argumentList, id);
    while (current != nil) {
        [newView addButtonWithTitle:current];
        current = va_arg(argumentList, id);
        //[array addObject:current];
    }
    va_end(argumentList);
    
    //    IPaAlertView* newView = [[IPaAlertView alloc] initWithTitle:title message:message target:target callback:callback AlertView:alert];
    //    IPaAlertView* newView = [[IPaAlertView alloc] initWithTitle:title message:message callback:callback AlertView:alert];
    [newView show];
    return newView;
    
}
-(id) initWithTitle:(NSString*)title message:(NSString*)message
  cancelButtonTitle:(NSString*)cancelButtonTitle
{
    self = [super initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    self.Callback = nil;
    return self;
    
}
-(id) initWithTitle:(NSString*)title message:(NSString*)message
        cancelButtonTitles:(NSString*)cancelButtonTitle ,...

{
    self = [self initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
    //                                    message:message delegate:self
    //                                cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    //NSMutableArray *array = [[NSMutableArray alloc] init];
    //[array addObject:cancelButtonTitle];
    id current = cancelButtonTitle;
    va_list argumentList;
    va_start(argumentList, cancelButtonTitle);
    current = va_arg(argumentList, id);
    while (current != nil) {
        [self addButtonWithTitle:current];
        current = va_arg(argumentList, id);
        //[array addObject:current];
    }
    va_end(argumentList);
    //    return [self initWithTitle:title message:message target:target callback:callback AlertView:alert];
    return self;
}

-(id) initWithTitle:(NSString*)title message:(NSString*)message 
           callback:(void (^)(NSInteger))callback
  cancelButtonTitles:(NSString*)cancelButtonTitle ,...

{
    self = [self initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
    //                                    message:message delegate:self
    //                                cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    
    //NSMutableArray *array = [[NSMutableArray alloc] init];
    //[array addObject:cancelButtonTitle];
    id current = cancelButtonTitle;
    va_list argumentList;
    va_start(argumentList, cancelButtonTitle);
    current = va_arg(argumentList, id);
    while (current != nil) {
        [self addButtonWithTitle:current];
        current = va_arg(argumentList, id);
        //[array addObject:current];
    }
    va_end(argumentList);
    self.Callback = callback;
    //    return [self initWithTitle:title message:message target:target callback:callback AlertView:alert];
    return self;
}

-(void)show
{
    self.delegate = self;
    [super show];
    
    [IPaToolManager RetainTool:self];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.Callback != nil) {
        /*IPaAlertView __unsafe_unretained *selfView = self;
         [Callback setArgument:&selfView atIndex:2];
         [Callback setArgument:&buttonIndex atIndex:3];
         [Callback invoke];
         */
        self.Callback(buttonIndex);
        
    }
    self.delegate = nil;
    [IPaToolManager ReleaseTool:self];
    
}

@end
