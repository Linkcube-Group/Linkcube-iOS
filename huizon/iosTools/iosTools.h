//
//  iosTools.h
//  huizon
//
//  Created by Yang on 13-11-7.
//  Copyright (c) 2013年 zhaopin. All rights reserved.
//

#import "Extension.h"
#import "ModelBase.h"
#import "BaseEngine.h"

static int const ddLogLevel = 1111;
/**
 事件处理签名
 @param sender:事件的产生者
 */
typedef void(^EventHandler)(id sender);

typedef id(^responseHandler)(id sender);

/**
 调用一个block,会判断block不为空
 */
#define BlockCallWithOneArg(block,arg)  if(block){block(arg);}
/**
 调用一个block,会判断block不为空
 */
#define BlockCallWithTwoArg(block,arg1,arg2) if(block){block(arg1,arg2);}
/**
 调用一个block,会判断block不为空
 */
#define BlockCallWithThreeArg(block,arg1,arg2,arg3) if(block){block(arg1,arg2,arg3);}