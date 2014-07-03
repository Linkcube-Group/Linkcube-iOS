//
//  ModelList.m
//  iOSShare
//
//  Created by wujin on 13-6-4.
//  Copyright (c) 2013年 wujin. All rights reserved.
//

#import "ModelList.h"

#define CheckElementClass(obj) \
    if([obj isKindOfClass:[[self class] elementClass]]==NO){\
        obj=nil;\
        NSLog(@"%@-error Element",[obj description]);\
		return ;\
    }

@implementation ModelList
- (id)init
{
    self = [super init];
    if (self) {
        self.array=[NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.array=nil;
}

+(Class)elementClass
{
    return [ModelList class];
}

-(id)initWithJson:(NSString *)jsonString
{
    NSArray *array=[jsonString objectFromJSONString];
    if ([array isKindOfClass:[NSArray class]]==NO) {
        return nil;
    }
    self = [self init];
    if (self) {
        [self setElementsWithArray:array];
    }
    return self;
}

-(id)initWithArray:(NSArray *)array
{
    self=[self init];
    if(self){
        [self setElementsWithArray:array];
    }
    return self;
}

-(void)setElementsWithArray:(NSArray*)array
{
    if (array==nil||array.count<1) {
        return;
    }
    Class elementClass=[array[0] class];
    Class targetClass=[[self class] elementClass];
    //两者类型相同，直接设置
    if (elementClass==targetClass||[elementClass isSubclassOfClass:targetClass]) {
        self.array=[NSMutableArray arrayWithArray:array];
    }else{
        if ([targetClass isSubclassOfClass:[ModelBase class]]) {
            if (elementClass==[NSString class]||[elementClass isSubclassOfClass:[NSString class]]) {
                for (NSString *str in array) {
                    id obj=[[elementClass alloc]  initWithJson:str];
                    if (obj==nil) {
                        break;
                    }else{
                        [self.array addObject:obj];
                    }
                }
            }else if (elementClass==[NSDictionary class]||[elementClass isSubclassOfClass:[NSDictionary class]]){
                for (NSDictionary *dic in array) {
                    id obj=[[targetClass alloc] initWithDictionary:dic];
                    if (obj==nil) {
                        break;
                    }else{
                        [self.array addObject:obj];
                    }
                }
            }
        }
    }
}

-(NSDictionary*)dictionary
{
    return nil;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"%@:%@",[[self class] description], self.array.description];
}

-(NSArray*)arrayString
{
    NSMutableArray *array=[NSMutableArray array];
    for (id obj in self.array) {
        if ([obj respondsToSelector:@selector(dictionary)]) {
            NSDictionary *dic=[obj dictionary];
            [array addObject:dic];
        }
    }
    return array;
}


- (void)addObject:(id)anObject
{
    CheckElementClass(anObject)
    
    [self.array addObject:anObject];
}
- (void)addobjectFromArray:(NSArray*)array
{
	for (id obj in array) {
		[self addObject:obj];
	}
}

- (void)addObjectFromModelList:(ModelList *)modelList
{
    CheckElementClass(modelList);
    
    [self.array addObjectsFromArray:modelList.array];
}
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    CheckElementClass(anObject)
    
    [self.array insertObject:anObject atIndex:index];
}
- (void)removeLastObject
{
    [self.array removeLastObject];
}
- (void)removeObjectAtIndex:(NSUInteger)index
{
    [self.array removeObjectAtIndex:index];
}
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    CheckElementClass(anObject)
    
    [self.array replaceObjectAtIndex:index withObject:anObject];
}
- (NSUInteger)count
{
    return self.array.count;
}
- (id)objectAtIndex:(NSUInteger)index
{
    return [self.array objectAtIndex:index];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [self.array countByEnumeratingWithState:state objects:buffer count:len];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
	return [self objectAtIndex:index];
}

@end
