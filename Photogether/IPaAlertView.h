//
//  IPaAlertView.h
//  TofuMemo
//
//  Created by 陳 尤中 on 11/9/8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
// callback format is    - (void) xxxxxx : (IPaAlertView)sender:sender buttonIdx:(NSUInteger)buttonIdx;

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface IPaAlertView : UIAlertView <UIAlertViewDelegate>{
                                
}

/*-(id) initWithTitle:(NSString*)title message:(NSString*)message 
             target:(id)target
           callback:(SEL)callback
  cancelButtonTitle:(NSString*)cancelButtonTitle ,...NS_REQUIRES_NIL_TERMINATION;*/
-(id) initWithTitle:(NSString*)title message:(NSString*)message 
           callback:(void (^)(NSInteger))callback
  cancelButtonTitles:(NSString*)cancelButtonTitle ,...NS_REQUIRES_NIL_TERMINATION;
-(id) initWithTitle:(NSString*)title message:(NSString*)message
  cancelButtonTitles:(NSString*)cancelButtonTitles ,...NS_REQUIRES_NIL_TERMINATION;
-(id) initWithTitle:(NSString*)title message:(NSString*)message
  cancelButtonTitle:(NSString*)cancelButtonTitle;
-(void)show;
+(id)IPaAlertViewWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle;
/*+(void)IPaAlertViewWithTitle:(NSString*)title message:(NSString*)message 
                               target:(id)target
                             callback:(SEL)callback
                    cancelButtonTitle:(NSString*)cancelButtonTitle ,...NS_REQUIRES_NIL_TERMINATION;*/
+(id)IPaAlertViewWithTitle:(NSString*)title message:(NSString*)message 
                    callback:(void (^)(NSInteger))callback
           cancelButtonTitles:(NSString*)cancelButtonTitle ,...NS_REQUIRES_NIL_TERMINATION;

//@property (nonatomic,strong) id userData;
//@property (nonatomic,copy) NSString *Title;
//@property (nonatomic,copy) NSString *Message;
@property (nonatomic,copy) void (^Callback)(NSInteger);
@end
