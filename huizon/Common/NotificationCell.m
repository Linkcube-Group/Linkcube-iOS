//
//  NotificationCell.m
//  huizon
//
//  Created by apple on 14-7-28.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "NotificationCell.h"
//cell高度
#define NOTICELLHEIGHT 50.f
//后面状态的宽度
#define TYPELENGTH 60.f

@implementation NotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        //头像
        self.headerImageView = [[UIImageView alloc] init];
        self.headerImageView.frame = CGRectMake(15, 10, NOTICELLHEIGHT - 20, NOTICELLHEIGHT - 20);
        self.headerImageView.layer.cornerRadius = (NOTICELLHEIGHT - 20)/2.f;
        self.headerImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.headerImageView];
        //名字
        UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headerImageView.frame.origin.x + self.headerImageView.frame.size.width + 10, self.headerImageView.frame.origin.y, [UIScreen mainScreen].bounds.size.width - self.headerImageView.frame.origin.x - self.headerImageView.frame.size.width - 15 - 10 - TYPELENGTH, self.headerImageView.frame.size.height)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:17.f];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.text = self.name;
        //后面
        switch (self.notiType)
        {
            case NotificationTypeFrom:
            {
                UILabel * label = [[UILabel alloc] init];
                label.frame = CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width, nameLabel.frame.origin.y, TYPELENGTH, nameLabel.frame.size.height);
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont systemFontOfSize:17.f];
                label.textAlignment = NSTextAlignmentRight;
                label.textColor = [UIColor darkGrayColor];
                label.text = NSLocalizedString(@"等待验证", nil);
                [self.contentView addSubview:label];
                break;
            }
            case NotificationTypeTo:
            {
                UIButton * agreementButton = [UIButton buttonWithType:UIButtonTypeCustom];
                agreementButton.frame = CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width, nameLabel.frame.origin.y, TYPELENGTH, nameLabel.frame.size.height);
                [agreementButton setBackgroundImage:[UIImage imageNamed:@"agree.png"] forState:UIControlStateNormal];
                [self.contentView addSubview:agreementButton];
                break;
            }
            case NotificationTypeBoth:
            {
                UILabel * label = [[UILabel alloc] init];
                label.frame = CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width, nameLabel.frame.origin.y, TYPELENGTH, nameLabel.frame.size.height);
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont systemFontOfSize:17.f];
                label.textAlignment = NSTextAlignmentRight;
                label.textColor = [UIColor darkGrayColor];
                label.text = NSLocalizedString(@"已添加", nil);
                [self.contentView addSubview:label];
                break;
            }
            case NotificationTypeNone:
            {
                break;
            }
                
            default:
                break;
        }
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
