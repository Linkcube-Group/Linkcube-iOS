//
//  ShakeControls.m
//  huizon
//
//  Created by yang Eric on 3/2/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "ShakeControls.h"

@interface ShakeControls()
{
    CMMotionManager *motionManager;
    NSOperationQueue *operationQueue;
}

@end

@implementation ShakeControls
@synthesize shakeHandler;

+ (ShakeControls *)shakeSingleton
{
    static ShakeControls *shakeObject;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shakeObject = [[ShakeControls alloc] initShakeControls];
    });
    
    return shakeObject;
}

- (id)initShakeControls
{
    if (self=[super init]) {
        operationQueue = [[NSOperationQueue alloc] init];
        motionManager = [[CMMotionManager alloc] init];
        motionManager.accelerometerUpdateInterval = 0.01;
    }
    return self;
}

- (BOOL)startShakeAction
{
    if (!motionManager.accelerometerAvailable) {
        return NO;
    }
    
    [motionManager startAccelerometerUpdatesToQueue:operationQueue withHandler:^(CMAccelerometerData *latestAcc, NSError *error) {
        
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            
            // 所有操作进行同步
            @synchronized(motionManager) {
                 
                
                float acc = ABS(motionManager.accelerometerData.acceleration.y);
                 acc += ABS(motionManager.accelerometerData.acceleration.x);
                
                BlockCallWithOneArg(self.shakeHandler, @(acc))
                //_isShake = [self isShake:_motionManager.accelerometerData];
                
            }
            
        });
        
    }];
    
    return YES;
}

- (void)stopShakeAction
{
    [motionManager stopAccelerometerUpdates];
    // 取消队列中排队的其它请求
    [operationQueue cancelAllOperations];
}

- (void)dealloc
{
    [self stopShakeAction];
}


- (BOOL)isShake:(CMAccelerometerData *)newestAccel {
    
    BOOL isShake = NO;
    
    // 三个方向任何一个方向的加速度大于1.5就认为是处于摇晃状态，当都小于1.5时认为摇奖结束。
    
    if (ABS(newestAccel.acceleration.x) > 1.5 || ABS(newestAccel.acceleration.y) > 1.5 || ABS(newestAccel.acceleration.z) > 1.5) {
        
        isShake = YES;
        
    }
    
    return isShake;
    
}

@end
