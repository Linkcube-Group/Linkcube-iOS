//
//  ModelBase.m
//  Cloud
//
//  Created by wujin on 12-10-8.
//  Copyright (c) 2012年 wujin. All rights reserved.
//

#import "ModelBase.h"
#import "iosTools.h"
#include <objc/runtime.h>
#import "Extension.h"
#import "Statement.h"
#import "UIColor+Extension.h"
#import "ModelList.h"

@implementation ModelBase

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    self=[self init];
    if (self) {
        [self setAttributesWithDictionary:dictionary];
    }
    return self;
}

-(id)initWithJson:(NSString *)jsonString
{
    if (![jsonString isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    self=[self init];
    if (self) {
        if (StringIsNullOrEmpty(jsonString)) {
            return nil;
        }
        NSError *error=nil;
        NSDictionary *dic=[jsonString objectFromJSONStringWithParseOptions:0 error:&error];
        if (error) {
            DDLogError(@"error:%@",error);
        }
        [self setAttributesWithDictionary:dic];
    }
    return self;
}

-(id)initWithStatement:(Statement *)state
{
    self=[self init];
    if (self) {
        [self setAttributesWithStatement:state];
    }
    return self;
}

-(id)initWithObject:(id)object
{
    self=[self init];
    if (self) {
        NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        unsigned int procount=0;
        objc_property_t *property=class_copyPropertyList([object class], &procount);
        for (int i=0; i<procount; i++) {
            objc_property_t pro=property[i];
            NSString *name=[NSString stringWithCString:property_getName(pro) encoding:NSUTF8StringEncoding];
            NSString *value=[object valueForKey:name];
            if (value!=nil) {
                [dic setObject:value forKey:name];
            }
        }
        [self setAttributesWithDictionary:dic];
        if (property) {
            free(property);
        }
    }
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

/*
 将一个值强类型化为某一属性所需要的值
 */
-(void)setValueForProperty:(objc_property_t)property Value:(id)value
{
    if (property==nil||value==nil) {
        return;//空值，返回
    }
    
    const char *property_attribute=property_getAttributes(property);
    
    const char *property_name_c=property_getName(property);
    
    NSString *property_name=[NSString stringWithCString:property_name_c encoding:NSUTF8StringEncoding];
    
    NSString *property_str=[NSString stringWithCString:property_attribute encoding:NSUTF8StringEncoding];
    
    //获取编码类型
    NSArray *splitarray=[property_str componentsSeparatedByString:@","];
    if (splitarray.count>0) {
        NSString *first=[splitarray objectAtIndex:0];
        if (![first hasPrefix:@"T"]) {//不是以T打头，字符串分离错误
            NSLog(@"set attribute error:split string error");
            return;
        }
        //判断是否为只读属性
        if ([[splitarray objectAtIndex:1] isEqualToString:@"R"]) {
            return;
        }
        
        //去掉T
        first=[first stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        //T..
        //根据T之后的字符串判断类型，如果不是@，就是基本类型
        if ([first hasPrefix:@"@"]) {//是一个其他类型
            //获取类型
            NSString *class_name=[first stringByReplacingOccurrencesOfString:@"@" withString:@""];
            class_name=[class_name stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            Class target_class=NSClassFromString(class_name);
            
            if (target_class==nil) {
                DDLogError(@"unKown Class:%@ to set target Value:%@",class_name,[value description]);
                return;
            }
            
            if ([value isKindOfClass:target_class]) {//值的类型和目标类型相同，直接设置值
                [self setValue:value forKey:property_name];
            }else if([target_class isSubclassOfClass:[ModelBase class]]){//如果传进来是一个字符串，并且目标类型支持序列化，责进行序列化
                ModelBase *modelValue=nil;
                
                //目标可以支持使用Diction或者String进行初始化
                if ([value isKindOfClass:[NSString class]]) {
                    modelValue = class_createInstance(target_class, 0);
                    modelValue = [modelValue initWithJson:value];
                }else if([value isKindOfClass:[NSDictionary class]]){
                    modelValue = class_createInstance(target_class, 0);
                    modelValue = [modelValue initWithDictionary:value];
                }else if ([target_class isSubclassOfClass:[ModelList class]]){
                    modelValue = class_createInstance(target_class, 0);
                    if([value isKindOfClass:[NSArray class]]){
                        modelValue=[modelValue initWithJson:[value JSONString]];
                    }else if ([value isKindOfClass:[NSString class]]){
                        modelValue = [modelValue initWithJson:value];
                    }
                }else{
                    DDLogError(@"can't set the value for type:%@  withValue %@ ",[target_class description],value);
                    return;
                }
                [self setValue:modelValue forKey:property_name];
                [modelValue release];
            }else if (target_class == [NSString class]){//目标是字符串
                if ([value isKindOfClass:[NSDictionary class]]||[value isKindOfClass:[NSArray class]]) {
                    [self setValue:[value JSONString] forKey:property_name];
                }
            }else if (target_class==[UIColor class]){//uicolor
                if ([value isKindOfClass:[NSString class]]) {
                    UIColor *color=[UIColor colorWithHexString:value];
                    if (color) {
                        [self setValue:color forKey:property_name];
                    }
                }
            }
            
        }else{//几个基本类型中的一个
            //获取对应私有变量的名称
            NSString *var_name=[splitarray lastObject];
            if (var_name!=nil&&[var_name hasPrefix:@"V"]) {//如果是私有变量名称，会以V开头
                var_name=[var_name stringByReplacingOccurrencesOfString:@"V" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 1)];
            }else{
                DDLogError(@"can't find ivar_layout");
                return;
            }
            
            //获取对应的私有变量
            const char *ivar_name_c=[var_name cStringUsingEncoding:NSUTF8StringEncoding];
            
            Ivar ivar_var=class_getInstanceVariable([self class], ivar_name_c);
            void *ivar_pointer=(uint8_t*)self+ivar_getOffset(ivar_var);
            if (ivar_pointer==nil) {
                return;
            }
            
            if ([first isEqualToString:@"c"]) {//char 接受string类的，string可以强制转换
                if ([value isKindOfClass:[NSString class]]) {
                    char charValue=*[value cStringUsingEncoding:NSUTF8StringEncoding];
                    
                    char *_set=ivar_pointer;
                    *_set=charValue;
                }else if([value isKindOfClass:[NSNumber class]]){//cahr 接受nsnumber类型
                    NSNumber *number=value;
                    char charValue=[number charValue];
                    char *_set=ivar_pointer;
                    *_set=charValue;
                }
            }else if([first isEqualToString:@"d"]){//double 接受nsnumber的类型 nsstring
                if ([value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSString class]]) {
                    double doubleValue=[value doubleValue];
                    
                    double *_set=ivar_pointer;
                    *_set=doubleValue;
                }
            }else if([first isEqualToString:@"i"]){//enum int类型 接受NSNumber类型 nsstring
                if ([value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSString class]]) {
                    int intValue=[value intValue];
                    
                    int *_set=ivar_pointer;
                    *_set=intValue;
                }
            }else if([first isEqualToString:@"f"]){//float 类型 接受NSNumber类型 nsstring
                if ([value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSString class]]) {
                    float floatValue=[value floatValue];
                    
                    float *_set=ivar_pointer;
                    *_set=floatValue;
                }
            }else if ([first isEqualToString:@"l"]){//long类型  接受NSNumber类型 nsstring
                if ([value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSString class]]) {
                    long longValue;
                    if([value isKindOfClass:[NSNumber class]]){
                        longValue=[value longValue];
                    }else{
                        longValue=[value doubleValue];
                    }
                    
                    long *_set=ivar_pointer;
                    *_set=longValue;
                }
            }else if ([first isEqualToString:@"s"]){//short类型  接受NSNumber类型 nsstring
                if ([value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSString class]]) {
                    short shortValue=[value shortValue];
                    
                    short *_set=ivar_pointer;
                    *_set=shortValue;
                }
            }else if ([first hasPrefix:@"{CGSize"]){//cgrect
                if ([value isKindOfClass:[NSString class]]) {
                    CGSize *_set=ivar_pointer;
                    *_set = CGSizeFromString(value);
                }
            }else if ([first hasPrefix:@"{CGRect"]){//cgrect
                if ([value isKindOfClass:[NSString class]]) {
                    CGRect *_set=ivar_pointer;
                    *_set = CGRectFromString(value);
                }
            }else if ([first hasPrefix:@"{CGPoint"]){//cgrect
                if ([value isKindOfClass:[NSString class]]) {
                    CGPoint *_set=ivar_pointer;
                    *_set = CGPointFromString(value);
                }
            }else if ([first hasPrefix:@"{CGAffineTransform"]){//cgrect
                if ([value isKindOfClass:[NSString class]]) {
                    CGAffineTransform *_set=ivar_pointer;
                    *_set = CGAffineTransformFromString(value);
                }
            }
            
            else{
                DDLogError(@"can't support type:%@ type:%@",var_name,first);
            }
            
        }
    }
    
}

-(void)setAttributesWithDictionary:(NSDictionary *)dictionary
{
	NSDictionary * dictionaryAlias=[self dictionaryAlias];
	
	Class class=self.class;
    
	while (class!=[ModelBase class]) {
		for (NSString *key in dictionary.allKeys) {
			
			NSString *mapkey=[NSString stringWithString:key];
			
			
			objc_property_t property=class_getProperty(class, [mapkey cStringUsingEncoding:NSUTF8StringEncoding]);
			if (property==nil) {
				//根据映射的属性再找一次
				if (dictionaryAlias.allValues.count>0) {
					for (NSArray *arrayKeys in dictionaryAlias.allValues) {
						if ([arrayKeys containsString:mapkey]) {
							mapkey=[dictionaryAlias allKeysForObject:arrayKeys].lastObject;
							property=class_getProperty(class, [mapkey cStringUsingEncoding:NSUTF8StringEncoding]);
							break;
						}
					}
				}else{
					continue;//没有此属性，返回
				}
			}
			id value=[dictionary objectForKey:key];
			
			[self setValueForProperty:property Value:value];
		}
		class=class_getSuperclass(class);
	}
    
}

-(NSDictionary*)dictionary
{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
	Class c=[self class];
	while (c!=[ModelBase class]) {
		unsigned int procount=0;
        
		objc_property_t *property=class_copyPropertyList([c class], &procount);
		//    NSDictionary* dictionaryMap = [self dictionaryMap];
		for (int i=0; i<procount; i++) {
			objc_property_t pro=property[i];
			NSString *name=[NSString stringWithCString:property_getName(pro) encoding:NSUTF8StringEncoding];
			
			//        if ([dictionaryMap.allValues containsString:name]) {
			//            name=[dictionaryMap allKeysForObject:name].lastObject;
			//        }
			NSString *value=[self serializableValueForProperty:pro];
			if (value!=nil) {
				[dic setObject:value forKey:name];
			}
		}
		
		if (property) {
			free(property);
		}
		
		c=class_getSuperclass(c);
	}
    
    return dic;
}

-(id)serializableValueForProperty:(objc_property_t)property
{
    if (property==nil) {
        return @"";//空值，返回
    }
    
    const char *property_attribute=property_getAttributes(property);
    
    const char *property_name_c=property_getName(property);
    
    NSString *property_name=[NSString stringWithCString:property_name_c encoding:NSUTF8StringEncoding];
    
    NSString *property_str=[NSString stringWithCString:property_attribute encoding:NSUTF8StringEncoding];
    
    //获取编码类型
    NSArray *splitarray=[property_str componentsSeparatedByString:@","];
    if (splitarray.count>0) {
        NSString *first=[splitarray objectAtIndex:0];
        if (![first hasPrefix:@"T"]) {//不是以T打头，字符串分离错误
            NSLog(@"set attribute error:split string error");
            return @"";
        }
        
        //去掉T
        first=[first stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        //T..
        //根据T之后的字符串判断类型，如果不是@，就是基本类型
        if ([first hasPrefix:@"@"]) {//是一个其他类型
            //获取类型
            NSString *class_name=[first stringByReplacingOccurrencesOfString:@"@" withString:@""];
            class_name=[class_name stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            Class target_class=NSClassFromString(class_name);
            
            if (target_class==nil) {
                DDLogError(@"unKown Class to set target Value");
                return @"";
            }
            
            if ([target_class isKindOfClass:[NSString class]]||target_class==[NSString class]) {//值的类型和目标类型相同，直接设置值
                return [self valueForKey:property_name];
            }else if([target_class isSubclassOfClass:[ModelBase class]]){//如果传进来是一个字符串，并且目标类型支持序列化，责进行序列化
                if ([target_class isSubclassOfClass:[ModelList class]]) {
                    ModelList *list=[self valueForKey:property_name];
                    
                    return [list arrayString];
                }
                return [[self valueForKey:property_name] dictionary];
            }else if (target_class==[UIColor class]){
                return [UIColor stringWithColor:[self valueForKey:property_name]];
            }else{//目标是字符串
                DDLogError(@"can't get string value for property:%@",property_name);
            }
            
        }else{//几个基本类型中的一个
            //获取对应私有变量的名称
            NSString *var_name=[splitarray lastObject];
            if (var_name!=nil&&[var_name hasPrefix:@"V"]) {//如果是私有变量名称，会以V开头
                var_name=[var_name stringByReplacingOccurrencesOfString:@"V" withString:@"" options:1 range:NSMakeRange(0, 2)];
            }else{
                DDLogError(@"can't find ivar_layout for property:%@",property_name);
                return @"";
            }
            
            //获取对应的私有变量
            const char *ivar_name_c=[var_name cStringUsingEncoding:NSUTF8StringEncoding];
            
            Ivar ivar_var=class_getInstanceVariable([self class], ivar_name_c);
            void *ivar_pointer=(uint8_t*)self+ivar_getOffset(ivar_var);
            
            if (ivar_pointer==nil) {
                return @"";
            }
            
            if ([first isEqualToString:@"c"]) {//char 接受bool类的
                //                return [NSString stringWithCString:(const char *)ivar_pointer encoding:NSUTF8StringEncoding];
                return @(*((BOOL*)ivar_pointer));
            }else if([first isEqualToString:@"d"]){//double 接受nsnumber的类型 nsstring
                return _S(@"%f",*((double*)ivar_pointer));
                
            }else if([first isEqualToString:@"i"]){//enum int类型 接受NSNumber类型 nsstring
                //                return _S(@"%d",*((int*)ivar_pointer));
                return @(*((int*)ivar_pointer));
                
            }else if([first isEqualToString:@"f"]){//float 类型 接受NSNumber类型 nsstring
                //                return _S(@"%f",*((float*)ivar_pointer));
                return @(*((float*)ivar_pointer));
                
            }else if ([first isEqualToString:@"l"]){//long类型  接受NSNumber类型 nsstring
                //                return _S(@"%ld",*((long*)ivar_pointer));
                return @(*((long*)ivar_pointer));
                
            }else if ([first isEqualToString:@"s"]){//short类型  接受NSNumber类型 nsstring
                //                return _S(@"%hd",*((short*)ivar_pointer));
                return @(*((short*)ivar_pointer));
                
            }else if ([first hasPrefix:@"{CGSize"]){//cgsize
                return NSStringFromCGSize(*((CGSize*)ivar_pointer));
            }else if ([first hasPrefix:@"{CGRect"]){//cgrect
                return NSStringFromCGRect(*((CGRect*)ivar_pointer));
            }else if ([first hasPrefix:@"{CGPoint"]){//cgpoint
                return NSStringFromCGPoint(*((CGPoint*)ivar_pointer));
                
            }else if ([first hasPrefix:@"{CGAffineTransform"]){//cgaffinetransform
                return NSStringFromCGAffineTransform(*((CGAffineTransform*)ivar_pointer));
                
            }else{
                DDLogInfo(@"can't support type:%@ type:%@",var_name,first);
            }
            
        }
    }
    
    return @"";
}

-(void)setAttributesWithStatement:(Statement *)statement
{
    NSMutableDictionary *dictionary=[NSMutableDictionary dictionary];
    //先获取列数
    int count=sqlite3_column_count(statement.stmt);
    for (int i=0; i<count; i++) {
        const char *colname=sqlite3_column_name(statement.stmt, i);
        [dictionary setObject:[statement getString:i+1] forKey:[NSString stringWithCString:colname encoding:NSUTF8StringEncoding]];
    }
    [self setAttributesWithDictionary:dictionary];
}

-(NSDictionary*)dictionaryAlias
{
	return nil;
}


#pragma mark dboperation
+(void)insertItem:(ModelBase *)item
{
    DDLogError(@"not impletion-[ModleBase insertItem:]");
}

+(void)deleteItem:(ModelBase *)item
{
    DDLogError(@"not impletion-[ModleBase deleteItem:]");
}

+(void)updateItem:(ModelBase *)item
{
    [[self class] deleteItem:item];
    [[self class] insertItem:item];
}

-(void)updateValue:(NSString *)value ForColumn:(NSString *)column Key:(NSString *)keyName TableName:(NSString *)tableName
{
    NSString *sql=[NSString stringWithFormat:@"UPDATE %@ SET %@=? WHERE %@=?",tableName,column,keyName];
    
    id keyValue=[self valueForKey:keyName];
    
    
    if ([keyValue isKindOfClass:[NSString class]]) {
        Statement *state=[Statement statementWithsql:[sql cStringUsingEncoding:NSUTF8StringEncoding]];
        [state bindString:value forIndex:1];
        [state bindString:keyValue forIndex:2];
        
        [state step];
        
        [state reset];
    }else{
        DDLogError(@"update for nonstring value key is not suport!");
    }
    
}

-(void)updateValue:(NSString *)value ForColumn:(NSString *)column Key:(NSString *)keyName KeyValue:(NSString*)keyValue TableName:(NSString *)tableName
{
    NSString *sql=[NSString stringWithFormat:@"UPDATE %@ SET %@=? WHERE %@=?",tableName,column,keyName];
    
    Statement *state=[Statement statementWithsql:[sql cStringUsingEncoding:NSUTF8StringEncoding]];
    [state bindString:value forIndex:1];
    [state bindString:keyValue forIndex:2];
    
    [state step];
    
    [state reset];
    
}
-(id)copy
{
    id instance=class_createInstance([self class], 0);
    return [instance initWithDictionary:self.dictionary];
}

+(ModelBase*)selectSingleItem:(NSString *)where Args:(NSArray *)args
{
    NSArray *items= [ModelBase selectMutiItem:where Args:args];
    if (items.count>0) {
        return [items objectAtIndex:0];
    }
    return nil;
}

+(NSArray*)selectMutiItem:(NSString *)where Args:(NSArray *)args
{
    return nil;
}

-(NSString*)description
{
    return _S(@"%p:<%@> %@",self,[[self class] description],self.dictionary.description);
}

#pragma mark -
#pragma mark encoding
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super init];
    if (self) {
        NSDictionary *dic=[aDecoder valueForKey:@"dictionary"];
        [self setAttributesWithDictionary:dic];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder setValue:[self dictionary] forKey:@"dictionary"];
}

-(id)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithDictionary:[self dictionary]];
}
/*
 生成一个全局唯一的UUID
 */
+(NSString*)generateUUID
{
    NSString *result = nil;
	
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	if (uuid)
	{
		result = ( NSString *)CFUUIDCreateString(NULL, uuid);
		CFRelease(uuid);
	}
	[result autorelease];
    //把字符串中的"-"换成空，服务器规定
	return [result stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

@end
