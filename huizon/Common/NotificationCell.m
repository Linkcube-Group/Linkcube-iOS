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
#define TYPELENGTH 80.f

@implementation NotificationCell

@synthesize headerImageView;
@synthesize nameLabel;
@synthesize notiType;
@synthesize temp;
@synthesize jid;
@synthesize agreementButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        //头像
        self.headerImageView = [[UIImageView alloc] init];
        self.headerImageView.frame = CGRectMake(20, 5, NOTICELLHEIGHT - 20, NOTICELLHEIGHT - 20);
        self.headerImageView.layer.cornerRadius = (NOTICELLHEIGHT - 20)/2.f;
        self.headerImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.headerImageView];
        //名字
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headerImageView.frame.origin.x + self.headerImageView.frame.size.width + 10, self.headerImageView.frame.origin.y, [UIScreen mainScreen].bounds.size.width - self.headerImageView.frame.origin.x - self.headerImageView.frame.size.width - 15 - 10 - TYPELENGTH, self.headerImageView.frame.size.height)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:17.f];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:nameLabel];
    }
    return self;
}

-(void)setNotiType:(NotificationType)theNotiType
{
    //后面
    switch (theNotiType)
    {
        case NotificationTypeFrom:
        {
            agreementButton = [UIButton buttonWithType:UIButtonTypeCustom];
            agreementButton.frame = CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width + TYPELENGTH - 60, nameLabel.frame.origin.y, 60.f, nameLabel.frame.size.height);
            [agreementButton setBackgroundImage:[UIImage imageNamed:@"agree.png"] forState:UIControlStateNormal];
            [agreementButton setTitle:@"同意" forState:UIControlStateNormal];
            [agreementButton setTitleColor:[UIColor colorWithRed:38/255.f green:128/255.f blue:38/255.f alpha:1.f] forState:UIControlStateNormal];
            [agreementButton addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:agreementButton];
            break;
        }
        case NotificationTypeTo:
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

-(void)btnClick
{
    NSLog(@"同意%@ %d",temp,notiType);
    [theApp.xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
