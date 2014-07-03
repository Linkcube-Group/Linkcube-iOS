//
//  RightCell.m
//  huizon
//
//  Created by meng on 6/9/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "RightCell.h"
@interface RightCell()
@property (strong,nonatomic) NSString *iconName;
@property (strong,nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong,nonatomic) IBOutlet UIImageView *imgIconRight;
@property (strong,nonatomic) IBOutlet UILabel *lbUserName;
@property (strong,nonatomic) IBOutlet UILabel *lbFriendStatus;
@end

@implementation RightCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



// set name of the icon in the front and the name of the text, for the RightCellLabel

- (void)setMenuImage:(NSString *)imgName Name:(NSString *)name
{
    self.iconName = imgName;
    self.imgIcon.image = IMG(_S(@"%@.png",self.iconName));
    self.lbUserName.text = name;
}

// set right icon 

- (void)setRightIcon:(NSString *)imgName
{
    self.imgIconRight.image = IMG(_S(@"%@.png",imgName));
}

- (void)setFriendStatus:(NSString *)status
{
    self.lbFriendStatus.text=status;
}





@end
