//
//  test.h
//  huizon
//
//  Created by yang Eric on 11/9/13.
//  Copyright (c) 2013 zhaopin. All rights reserved.
//

#import "ModelBase.h"
#import "ModelList.h"


@interface test : ModelBase

@property (strong,nonatomic) NSString *cname;
@property (nonatomic) int  cid;
@end


@interface testlist : ModelList

@end

@interface CategoryItem : ModelBase
@property (strong,nonatomic) testlist *category;
@property (nonatomic)  int version;
@property (strong,nonatomic) NSString *url;
@property (strong,nonatomic) NSString *content;
@property (nonatomic) int status;
@end