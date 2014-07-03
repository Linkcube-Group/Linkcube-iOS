//
//  PersonCell.m
//  huizon
//
//  Created by yang Eric on 3/16/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "PersonCell.h"

@implementation PersonCell
@synthesize labelName,fieldContent;
@synthesize editHandler;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initSettingCell:(NSString *)name Content:(NSString *)content Other:(BOOL)flag
{
    labelName.text = name;
    if (flag) {
        fieldContent.text = content;
    }
    else{
        fieldContent.placeholder = content;
    }
    fieldContent.enabled = flag;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
