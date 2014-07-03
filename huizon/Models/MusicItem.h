//
//  MusicItem.h
//  huizon
//
//  Created by mosn on 5/23/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "ModelBase.h"
#import "ModelList.h"

@interface MusicItem : ModelBase

@property (strong,nonatomic) NSString *musicName;
@property (strong,nonatomic) NSString *musicPath;

@property (strong,nonatomic) NSString *author;
@property (strong,nonatomic) NSData *metal;
@end

@interface MusicList : ModelList   

@end
