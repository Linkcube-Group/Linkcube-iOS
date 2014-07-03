//
//  BaseEngine.h
//  TSOL
//
//  Created by Yang on 13-7-8.
//  Copyright (c) 2013年 tsol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKNetworkKit.h"

@interface BaseEngine : MKNetworkEngine

@property (strong,nonatomic) NSString *httpMethod;

typedef void (^ResponseBlock)(NSDictionary *responseDict);
typedef void (^FinishBlock)(NSString *resString);


- (MKNetworkOperation*)RunRequest:(NSMutableDictionary *)  dict
                             path:(NSString *)      path
                completionHandler:(ResponseBlock)   completionBlock
                     errorHandler:(MKNKErrorBlock)  errorBlock
                    finishHandler:(FinishBlock)     finishBlock;


+ (BaseEngine *)sharedEngine;

@end
