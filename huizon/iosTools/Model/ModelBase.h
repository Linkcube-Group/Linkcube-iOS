//
//  ModelBase.h
//  Cloud
//
//  Created by  on 12-10-8.
//  Copyright (c) 2012年 . All rights reserved.
//  模型层基类，所有模型层的类都继承自此类

#import "JSONKit.h"
#import <objc/runtime.h>

@class Statement;
//快速申明一个属性
#define Property(name) @property (nonatomic,retain) NSString *name;

@interface ModelBase : NSObject<NSCoding,NSCopying>{

}

//使用一个json字符串初始化
-(id)initWithJson:(NSString*)jsonString;

//使用一个json字典初始化
-(id)initWithDictionary:(NSDictionary*)dictionary;

//使用一个字典初始自身的所有属性
-(void)setAttributesWithDictionary:(NSDictionary*)dictionary;

//返回此元素的字典元素集合
-(NSDictionary*)dictionary;

//使用一个statement来给元素赋值
-(void)setAttributesWithStatement:(Statement*)statement;

//使用一个sqlite连接初始化，将将连接里面的所有数据全部给对应元素赋值
-(id)initWithStatement:(Statement*)state;

//使用一个对象初始化
-(id)initWithObject:(id)object;

/**
 依次返回每个字段的别名，用于从Dictionary中赋值的时候对某个属性做多个映射
 如  模型层中有  id字段 ，需要将  id1和id2都解析 为id，则，返回如下字典
 {"id":["id1","id2"]}
 */
- (NSDictionary*)dictionaryAlias;

/**
 重写此方法以用于给特定key特定的值
 */
-(void)setValueForProperty:(objc_property_t)property Value:(id)value;

/**
 重写此方法以用于给特定的属性进行序列化
 返回的属性需要可以设置给NSDictionary的key
 如:  NSString,NSArray,NSDictionary,NSNumber等
 */
-(id)serializableValueForProperty:(objc_property_t)property;

#pragma mark dboperation

/**
 向模型的存储层中插入一项
 item:要插入的项
 */
+(void)insertItem:(ModelBase *)item;

/**
 向模型的存储层中删除一项
 item:要删除的项
 */
+(void)deleteItem:(ModelBase *)item;

/**
 向模型的存储层中更新一项
 item:要更新的项
 */
+(void)updateItem:(ModelBase *)item;

/**
 更新模型层对应的一列
 value:值
 column:列名
 */
-(void)updateValue:(NSString*)value ForColumn:(NSString*)column Key:(NSString*)keyName TableName:(NSString*)tableName;
/**
 更新模型层对应的一列，并指定主键的值
 */
-(void)updateValue:(NSString *)value ForColumn:(NSString *)column Key:(NSString *)keyName KeyValue:(NSString*)keyValue TableName:(NSString *)tableName;
/**
 从模型的存储层中选择符合条件的第一项
 where:要用来筛选的where 子句
 */
+(ModelBase *)selectSingleItem:(NSString *)where Args:(NSArray*)args;

/**
 从模型的存储层中选择符合条件的所有项
 where:要用来筛选的where 子句
 */
+(NSArray*)selectMutiItem:(NSString *)where Args:(NSArray*)args;


/**
 生成一个全局唯一的UUID
 */
+(NSString*)generateUUID;
@end
