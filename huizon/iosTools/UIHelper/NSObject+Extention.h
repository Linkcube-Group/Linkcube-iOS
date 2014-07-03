//
//  NSObject+Extention.h
//  iTrends
//
//  Created by wujin on 12-8-29.
//
//

#import <Foundation/Foundation.h>

/*
 定义一个需要指定时间后执行的block块
 */
typedef void(^BlockPerform)(id param);

/**
 申明一个 block_self 的指针，指向自身，以用于在block中使用
 */
//#define IMP_BLOCK_SELF(type) __block type *block_self=self;

@interface NSObject (Extention)

-(void)performBlock:(BlockPerform)block Param:(id)param;

-(void)performBlock:(BlockPerform)block Param:(id)param AfterDelay:(NSTimeInterval)delay;

/**
 申明一个 block_self 的指针，指向自身，以用于在block中使用
 */
#if __has_feature(objc_arc)
#define IMP_BLOCK_SELF(type) __weak type *block_self=self;
#else
#define IMP_BLOCK_SELF(type) __block type *block_self=self;
#endif

/*
 取消之前请求的block块
 暂时不被支持
 */
-(void)cancelBlockRequested;

/**
 获取关联的一个参数对象
 此对象会被 retain一次，
 因为此对象不能重写dealloc
 所以，使用此对象时，请在对象release的时候手动 设置此属性为nil以release此属性
 */
-(void)setAssociatedObjectRetain:(id)object;
-(id)associatedObjectRetain;

/**
 获取关联的一个参数对象
 此对象不会被 retain，只是一个弱引用
 */
-(void)setAssociatedObject:(id)object;
-(id)associatedObject;
@end
