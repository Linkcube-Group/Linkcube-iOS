//
//  CTAlertView.m
//  huizon
//
//  Created by Yang on 13-11-8.
//  Copyright (c) 2013年 zhaopin. All rights reserved.
//

#import "CTAlertView.h"

@implementation CTAlertView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)dealloc
{
    self.clickButtonAtIndex=nil;
    
}
//使用块语句初始化一个AlertView
-(id)initWithTitle:(NSString *)title message:(NSString *)message DelegateBlock:(void (^)(UIAlertView *alert,int index))block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles
{
    
    self.clickButtonAtIndex=block;
    if (otherButtonTitles!=nil&&![otherButtonTitles isEqualToString:@""]) {
        return [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles,nil];
    }else {
        return [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    }
}
+(void)AlertShow:(NSString*)title message:(NSString *)message DelegateBlock:(void(^)(UIAlertView *alert,int index))block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles
{
    //    [[UIApplication sharedApplication] keyWindow].windowLevel=UIWindowLevelStatusBar;
    CTAlertView *alert=[[CTAlertView alloc] initWithTitle:title message:message DelegateBlock:block cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles];
    [alert show];
}

+(void)AlertShow:(NSString*)message
{
    [CTAlertView AlertShow:nil message:message DelegateBlock:^(UIAlertView *alert,int index){
        
    }cancelButtonTitle:kMessageOkButtonTitle otherButtonTitles:nil];
}

+(void)AlertShow:(NSString*)title message:(NSString*)message
{
    [CTAlertView AlertShow:title
                     message:message
               DelegateBlock:^(UIAlertView *alert,int index){
                   
               }
           cancelButtonTitle:kMessageOkButtonTitle
           otherButtonTitles:nil];
}

+(void)AlertShow:(NSString *)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle
{
    [CTAlertView AlertShow:title message:message DelegateBlock:^(UIAlertView *alert,int index){
        
    }cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
}
+(void)AlertShow:(NSString *)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitle:(NSString*)otherButtonTitle
{
    [CTAlertView AlertShow:title
                     message:message
               DelegateBlock:^(UIAlertView *alert,int index){
                   
               }
           cancelButtonTitle:cancelButtonTitle
           otherButtonTitles:otherButtonTitle];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    index=buttonIndex;
    if (self.clickButtonAtIndex) {
        self.clickButtonAtIndex(self,index);
        self.clickButtonAtIndex=nil;
    }
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
@end
