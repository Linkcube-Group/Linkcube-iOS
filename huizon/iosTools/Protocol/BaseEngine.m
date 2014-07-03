//
//  BaseEngine.m
//  TSOL
//
//  Created by Yang on 13-7-8.
//  Copyright (c) 2013年 tsol. All rights reserved.
//

#import "BaseEngine.h"
#import "JSONKit.h"
#import "URL.h"

@implementation BaseEngine

+ (BaseEngine *)sharedEngine
{
    static dispatch_once_t pred;
    
    static BaseEngine *sharedSingleton;
    
    dispatch_once(&pred,^{sharedSingleton=[[self alloc] initSingleton];} );
    
    return sharedSingleton;
}


- (id)initSingleton
{
    if(self=[super init]){

        self = [[BaseEngine alloc] initWithHostName:SERVER_DOMAIN customHeaderFields:nil];
        self.httpMethod = @"GET";
        [self useCache];
    }
    return self;
}


- (MKNetworkOperation*)RunRequest:(NSMutableDictionary *)  dict
                             path:(NSString *)      path
                completionHandler:(ResponseBlock)   completionBlock
                     errorHandler:(MKNKErrorBlock)  errorBlock
                    finishHandler:(FinishBlock)     finishBlock
{
    MKNetworkOperation *op = [self operationWithPath:path
                                              params:dict
                                          httpMethod:self.httpMethod];
    
    
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        
        NSString *response = [completedOperation responseString];
        NSDictionary *reDict = [response objectFromJSONString];
        completionBlock(reDict);
//        if (reDict) {
//            NSString *statusCode = [reDict valueForKey:@"rsp_code"];
//            NSString *statusDesc = [reDict valueForKey:@"rsp_msg"];
//            
//            if ((statusCode && [statusCode isEqualToString:HK_CODE_SUCCESS])||(statusCode && [statusCode isEqualToString:HK_CODE_NOALIPAY])){
//                completionBlock(reDict);
//                
//            }
//            else{
//                if (statusCode && [statusCode isEqualToString:HK_CODE_NOPAY]) {
//                    completionBlock(reDict);//go failed view
//                }
//                if (statusDesc==nil) {
//                    statusDesc = @"服务器请求错误";
//                }
//                showCustomAlertMessage(statusDesc);
//            }
//
//            
//        }
        finishBlock(response);
        
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
    
    
    [self enqueueOperation:op];
    
    return op;
}





@end
