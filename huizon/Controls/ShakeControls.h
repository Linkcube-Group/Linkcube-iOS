//
//  ShakeControls.h
//  huizon
//
//  Created by yang Eric on 3/2/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h> 

@interface ShakeControls : NSObject

@property (nonatomic,copy) EventHandler shakeHandler;

+ (ShakeControls *)shakeSingleton;

- (void)stopShakeAction;
- (BOOL)startShakeAction;
@end
