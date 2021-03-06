//
//  MenuCell.m
//  huizon
//
//  Created by yang Eric on 5/25/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "MenuCell.h"

@interface MenuCell()

@property (strong,nonatomic) NSString *iconName;

@property (strong,nonatomic) IBOutlet UILabel *lbBlueStatus;
@property (strong,nonatomic) IBOutlet UILabel *lbBlueName;
@property (strong,nonatomic) IBOutlet UILabel *lbBlueConn;
@property (strong,nonatomic) IBOutlet UILabel *lbControlName;
@property (strong,nonatomic) IBOutlet UILabel *lbLine;
@property (strong,nonatomic) IBOutlet UIImageView *imgIcon;

@property (strong,nonatomic) IBOutlet UIImageView *imgRefresh;

@property (nonatomic) BOOL  selectItem;
@end

@implementation MenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark -
#pragma mark Func
- (void)setBlueStatu:(int)flag
{
    self.lbBlueStatus.text = flag>0?@"已连接":@"未连接";
    if (flag!=0) {
        [self.layer removeAllAnimations];
    }
    else{
        [self animationRefresh];
    }
}
- (void)setMenuImage:(NSString *)imgName Name:(NSString *)name WithSelect:(BOOL)selected
{
    self.selectItem = selected;
    self.iconName = imgName;
   
    self.lbControlName.text = name;
    if (selected) {
        self.imgIcon.image = IMG(_S(@"%@_s.png",self.iconName));
        self.lbControlName.textColor = RGBColor(109, 0, 64);
    }
    else{
         self.imgIcon.image = IMG(_S(@"%@.png",self.iconName));
        self.lbControlName.textColor = RGBColor(97, 97, 97);
    }
}
- (void)setBLueConn:(NSString *)name Status:(BOOL)flag
{
    self.lbBlueName.text = name;
    self.lbBlueConn.text = flag?@"已连接":@"点击连接";
    if (flag) {
        self.lbBlueName.textColor = [UIColor colorWithHexString:@"#A52A2A"];
    }
    else{
        self.lbBlueName.textColor = [UIColor colorWithHexString:@"#747474"];;
    }
}
- (void)setLineName:(NSString *)name
{
    self.lbLine.text = name;
}




- (void)animationRefresh
{
    if (self.imgRefresh) {
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
        animation.duration = 1.0f;
        animation.repeatCount = HUGE_VALF;
        [self.imgRefresh.layer addAnimation:animation forKey:nil];
        
    
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
//    if (selected) {
//        self.imgIcon.image = IMG(_S(@"%@_s.png",self.iconName));
//        self.lbControlName.textColor = RGBColor(109, 0, 64);
//    }
//    else{
//        self.imgIcon.image = IMG(_S(@"%@.png",self.iconName));
//       self.lbControlName.textColor = RGBColor(97, 97, 97);
//    }
    // Configure the view for the selected state
}

@end
