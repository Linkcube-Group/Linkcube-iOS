//
//  HNHHEQVisualizer.m
//  HNHH
//
//  Created by Dobango on 9/17/13.
//  Copyright (c) 2013 RC. All rights reserved.
//

#import "PCSEQVisualizer.h"
#import "UIImage+Color.h"

#define kWidth 6
#define kHeight 50
#define kPadding 1


@implementation PCSEQVisualizer
{
    NSTimer* timer;
    NSArray* barArray;
}
- (id)initWithNumberOfBars:(int)numberOfBars
{
    self = [super init];
    if (self) {
        self.barColor = [UIColor whiteColor];
        self.frame = CGRectMake(0, 0, kPadding*numberOfBars+(kWidth*numberOfBars), kHeight);
        
        NSMutableArray* tempBarArray = [[NSMutableArray alloc]initWithCapacity:numberOfBars];
        
        for(int i=0;i<numberOfBars;i++){
            
            UIImageView* bar = [[UIImageView alloc]initWithFrame:CGRectMake(i*kWidth+i*kPadding, 0, kWidth, 1)];
            bar.image = [UIImage imageWithColor:self.barColor];
            [self addSubview:bar];
            [tempBarArray addObject:bar];
            
        }

        barArray = [[NSArray alloc]initWithArray:tempBarArray];
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2*2);
        self.transform = transform;
       
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:@"stopTimer" object:nil];
  
    }
    return self;
}


-(void)start{
    
    self.hidden = NO;
    timer = [NSTimer scheduledTimerWithTimeInterval:.35 target:self selector:@selector(ticker) userInfo:nil repeats:YES];
    
}

- (BOOL)isStart
{
    if (timer && [timer isValid]) {
        return YES;
    }
    return NO;
}
-(void)stop{
    
    [timer invalidate];
    timer = nil;
    [self resetTicker];
    
}

-(void)ticker{

    [UIView animateWithDuration:.35 animations:^{
        
        for(UIImageView* bar in barArray){
            
            CGRect rect = bar.frame;
            rect.size.height = arc4random() % kHeight + 1;
            bar.frame = rect;
            
            
        }
    
    }];
}

- (void)resetTicker
{
    [UIView animateWithDuration:.2 animations:^{
        
        for(UIImageView* bar in barArray){
            
            CGRect rect = bar.frame;
            rect.size.height = 1;
            bar.frame = rect;
            
            
        }
        
    }];
}

@end
