//
//  NSObject+Extention.m
//  iTrends
//
//  Created by wujin on 12-8-29.
//
//

#import "NSObject+Extention.h"
#import <objc/runtime.h>

@implementation NSObject (Extention)

//
//#ifdef DEBUG_OBJSEL
///*
// 此方法用于定义当出现内存泄漏时
// 用于保留堆栈信息
// 此方法仅当DEBUG模式时会编译
// */
//-(BOOL)respondsToSelector:(SEL)aSelector
//{
//    NSLog("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
//    return [super respondsToSelector:aSelector];
//}
//#endif

-(void)performBlock:(BlockPerform)block Param:(id)param
{
    [self performBlock:block Param:param AfterDelay:0];
}

-(void)performBlock:(BlockPerform)block Param:(id)param AfterDelay:(NSTimeInterval)delay
{
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:block,@"block",param,@"param", nil];
    if (delay<=0) {//如果时间为0或者负，直接执行此方法
        [self executeBlock:dic];
    }else{
        [self performSelector:@selector(executeBlock:) withObject:dic afterDelay:delay];
    }
}

-(void)executeBlock:(NSDictionary*)blockInfo// Param:(id)param
{
    BlockPerform block=[blockInfo objectForKey:@"block"];
    id param=[blockInfo objectForKey:@"param"];
    
    block(param);
    
    //释放此block
  //  Block_release(block);
}

-(void)cancelBlockRequested
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(executeBlock:) object:nil];
}


//NSString * const kAssociatedObjectKey=@"associatedobjectkey-234242";
//NSString * const kAssociatedObjectRetainKey=@"associatedobjectretainkey-235424";
static char kAssociatedObjectRetainKey;
static char kAssociatedObjectKey;
/**
 获取关联的一个参数对象
 此对象会被 retain一次，
 因为此对象不能重写dealloc
 所以，使用此对象时，请在对象release的时候手动 设置此属性为nil以release此属性
 */
-(void)setAssociatedObjectRetain:(id)object
{
    objc_setAssociatedObject(self, &kAssociatedObjectRetainKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(id)associatedObjectRetain
{
    return objc_getAssociatedObject(self, &kAssociatedObjectRetainKey);
}

/**
 获取关联的一个参数对象
 此对象不会被 retain，只是一个弱引用
 */
-(void)setAssociatedObject:(id)object
{
    objc_setAssociatedObject(self, &kAssociatedObjectKey, object, OBJC_ASSOCIATION_ASSIGN);
}
-(id)associatedObject
{
    return objc_getAssociatedObject(self, &kAssociatedObjectKey);
}
@end
