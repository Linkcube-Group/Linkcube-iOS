//
//  ModelList.h
//  iOSShare
//
//  Created by  on 13-6-4.
//  Copyright (c) 2013年 . All rights reserved.
//

#import "ModelBase.h"

/**
 表示一个模型的列表
 如果模型中的某元素为数组
 继承此类，然后重写elementClass方法，并返回正确的每个元素的类型，即可实现强类型化的数组
 */
@interface ModelList : ModelBase<NSFastEnumeration>

/**
 使用一个数组初始化，数组 中元素为json字典
 @param array:要用来初始化的字典
 @return 返回初始化成功的元素
 */
-(id)initWithArray:(NSArray*)array;
/**
 元素的类型
 重写此方法返回自己需要的类型
 */
+(Class)elementClass;

/**
 所有元素的数组
 */
@property (nonatomic,retain) NSMutableArray *array;

/**
 将所有元素序列化后返回数组
 */
-(NSArray*)arrayString;

/**
 重写此方法以用于重新设置元素
 */
-(void)setElementsWithArray:(NSArray*)array;


#pragma mark -
#pragma mark -mutable array method
- (void)addObject:(id)anObject;
- (void)addObjectFromModelList:(ModelList *)modelList;
- (void)addobjectFromArray:(NSArray*)array;

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;
@end
