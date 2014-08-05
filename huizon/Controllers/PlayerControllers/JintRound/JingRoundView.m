//
//  JingRoundView.m
//  JingFM-RoundEffect
//
//  Created by isaced on 13-6-6.
//  Copyright (c) 2013年 isaced. All rights reserved.
//  By isaced:http://www.isaced.com/

#import "JingRoundView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#define kRotationDuration 8.0

@interface JingRoundView ()


//@property (strong, nonatomic) CABasicAnimation* rotationAnimation;
@end

@implementation JingRoundView

-(void) initJingRound
{
    CGPoint center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
       
    
    //set roundImageView
    UIImage *roundImage = self.roundImage;
    self.roundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.roundImageView setCenter:center];
    [self.roundImageView setImage:roundImage];
    [self insertSubview:self.roundImageView atIndex:0];
    
    
    
}

- (void)initRound
{
    return;
        [self.layer removeAllAnimations];
    //Rotation
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.fromValue = 0;
    //default RotationDuration value
    if (self.rotationDuration == 0) {
        self.rotationDuration = kRotationDuration;
    }
    
    rotationAnimation.duration = self.rotationDuration;
    rotationAnimation.RepeatCount = FLT_MAX;
    rotationAnimation.cumulative = NO;

    [self.roundImageView.layer addAnimation:rotationAnimation forKey:nil];
    
    //pause
//    if (!self.isPlay) {
        self.layer.speed = 0.0;
//    }
}

- (void)drawRect:(CGRect)rect
{
    [self initJingRound];
    [self initRound];
}


-(void)setRoundImage:(UIImage *)aRoundImage
{
    _roundImage = aRoundImage;
    self.roundImageView.image = self.roundImage;
}

//touchesBegan
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isPlay = !self.isPlay;
    [self.delegate playStatuUpdate:self.isPlay];
}

-(void) startRotation:(BOOL)force
{
    if (self.layer.speed>0) {
        return;
    }
    //start Animation
    CFTimeInterval pausedTime = [self.layer timeOffset];
  
    self.layer.speed = 1.0;
    self.layer.timeOffset = 0.0;
    self.layer.beginTime = 0.0;
   
   
    
    CFTimeInterval timeSincePause = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
   
    self.layer.beginTime = timeSincePause;
  
    
    //set ImgView
}

-(void) pauseRotation
{

    if (self.layer.speed<1) {
        return;
    }
    
    CFTimeInterval pausedTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.layer.speed = 0.0;
    
    self.layer.timeOffset = pausedTime+0.1;
    
}

-(void)play
{
    self.isPlay = YES;
}
-(void)pause
{
    self.isPlay = NO;
}

@end
