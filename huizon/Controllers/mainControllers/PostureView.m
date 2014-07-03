//
//  PostureView.m
//  huizon
//
//  Created by yang Eric on 3/2/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "PostureView.h"
#import "PostureScrollView.h"
#import "ShakeControls.h"

@interface PostureView()
{
    int totalCount;
    int currentIndex;
    NSString *_stateName;
    UIButton *_stateButton;
    PatternState currentState;
}
@property (strong,nonatomic) UIButton *stateButton;
@property (strong,nonatomic) NSString *stateName;
@end

#define ControlImages [NSArray arrayWithObjects:@"shake",@"posture",@"music",nil]
#define ControlCount [NSArray arrayWithObjects:@"4",@"7",@"4",nil]


@implementation PostureView
@synthesize _delegate;

- (id)initWithFrame:(CGRect)frame PatternType:(PatternState)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        currentState = type;
        currentIndex = 0;
        totalCount = [[ControlCount objectAtIndex:type] intValue];
        self.stateName = [ControlImages objectAtIndex:type];
        
        
        self.stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.stateButton.frame = self.bounds;

        NSString *imgName = _S(@"%@_0.png",self.stateName);
        [self.stateButton addTarget:self action:@selector(postureAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.stateButton setImage:IMG(imgName) forState:UIControlStateNormal];
        [self addSubview:self.stateButton];

    }
    return self;
}

- (void)postureAction:(id)sender
{
    currentIndex++;
    if (currentIndex>totalCount) {
        currentIndex = 0;
    }
    NSString *imgName = _S(@"%@_%d.png",self.stateName,currentIndex);
    [self.stateButton setImage:IMG(imgName) forState:UIControlStateNormal];
    NSString *cmd = nil;
    switch (currentState) {
        case PatternStateShake:
            cmd =_S(@"%d",currentIndex);
            break;
        case PatternStatePosture:
            cmd = [kBluetoothPostures objectAtIndex:currentState];
            break;
        case PatternStateVoice:
            cmd = _S(@"%d",currentIndex);
            break;
        default:
            break;
    }

    if (self._delegate && [self._delegate respondsToSelector:@selector(patternCommand:)]) {
        [self._delegate patternCommand:cmd];
    }
        

}


- (void)dealloc
{
    _delegate = nil;
}

@end
