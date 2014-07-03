//
//  CTActionSheet.h
//  huizon
//
//  Created by Yang on 13-11-8.
//  Copyright (c) 2013年 zhaopin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ActionHandleBlock)(int btnIndex);

#define ActionSheet(title,cancelButton,destructiveBtn,otherButton,view) [[DQJKActionSheet actionSheetWithTitle:title cancelButtonTitle:cancelButton destructiveButtonTitle:destructiveBtn otherButtonTitles:otherButton HandleBlock:handle] showInView:view];

@interface CTActionSheet : UIActionSheet<UIActionSheetDelegate>

-(id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles HandleBlock:(ActionHandleBlock)handle;

+(id)actionSheetWithTitle:(NSString*)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles HandleBlock:(ActionHandleBlock)handle;

@property (nonatomic,copy) ActionHandleBlock handleBlock;

@end