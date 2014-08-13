//
//  UserInfo.h
//  huizon
//
//  Created by yang Eric on 3/18/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject
/*
 2.0版本的时候把用户的数据保存到这里
 */
@property (nonatomic,strong) NSString * jisStr;       //ID
@property (nonatomic,strong) NSString * nickName;     //昵称
@property (nonatomic,strong) NSString * userName;     //名字
@property (nonatomic,strong) NSString * email;        //邮箱
@property (nonatomic,strong) NSString * gender;       //性别
@property (nonatomic,strong) NSString * birthday;     //生日
@property (nonatomic,strong) NSString * personState;  //个性签名
@property (nonatomic,strong) UIImage  * photo;        //头像

@end
