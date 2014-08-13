//
//  UserInfo.m
//  huizon
//
//  Created by yang Eric on 3/18/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.jisStr            = [aDecoder decodeObjectForKey:@"jidStr"];
        self.nickName          = [aDecoder decodeObjectForKey:@"nickName"];
        self.userName          = [aDecoder decodeObjectForKey:@"userName"];
        self.email             = [aDecoder decodeObjectForKey:@"email"];
        self.gender            = [aDecoder decodeObjectForKey:@"gender"];
        self.birthday          = [aDecoder decodeObjectForKey:@"birthday"];
        self.personState       = [aDecoder decodeObjectForKey:@"personState"];
        self.photo             = [aDecoder decodeObjectForKey:@"photo"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_jisStr             forKey:@"jidStr"];
    [aCoder encodeObject:_nickName           forKey:@"nickName"];
    [aCoder encodeObject:_userName           forKey:@"userName"];
    [aCoder encodeObject:_email              forKey:@"email"];
    [aCoder encodeObject:_gender             forKey:@"gender"];
    [aCoder encodeObject:_birthday           forKey:@"birthday"];
    [aCoder encodeObject:_personState        forKey:@"personState"];
    [aCoder encodeObject:_photo              forKey:@"photo"];
}

@end
