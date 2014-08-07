//
//  FriendInfoViewController.m
//  huizon
//
//  Created by apple on 14-7-31.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "FriendInfoViewController.h"
#import "XMPPvCardTemp.h"
#import "XMPPvCardTempModule.h"
//#import "TalkViewController.h"
#import "ChatWithOtherViewController.h"

@interface FriendInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>

@end

@implementation FriendInfoViewController
{
    UITableView * _mainTableView;
    NSData * _photo;//头像
    NSString *_gender;//性别
    NSString *_age;//年龄
    NSString *_personstate;//个性签名
    NSString *_nickName;//昵称
    NSString *_email;//邮箱
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem=[[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(back)];
    
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    _mainTableView.backgroundColor = [UIColor colorWithRed:230/255.f green:230/255.f blue:230/255.f alpha:1.f];
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_mainTableView];
    
    //    XMPPvCardTemp * vCardTemp = [theApp vCardTempForJID:nil objectForKey:@"buddyName"]] shouldFetch:YES];
    XMPPvCardTemp * vCardTemp = [theApp.xmppvCardTempModule vCardTempForJID:self.jid shouldFetch:YES];
    _photo = [[NSData alloc] initWithData:vCardTemp.photo];
    _gender = vCardTemp.gender;
    
    _email = vCardTemp.email;
    
    NSLog(@"%@",vCardTemp.birthday);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate * date = [NSDate dateWithString:vCardTemp.birthday Format:@"yyyy-MM-dd"];
    NSTimeInterval  timeInterval = [date timeIntervalSinceNow];
    _age = [NSString stringWithFormat:@"%d",abs((int)(timeInterval/60.f/60.f/24.f/365.f))];
    
    _personstate = vCardTemp.personstate;
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:vCardTemp.nickname];
    _nickName = vCardTemp.nickname;
    
}
-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark - tableView method

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    switch (indexPath.row)
    {
        case 0:
            height = 120.f;
            break;
        case 1:
            height = 40.f;
            break;
        case 2:
            height = 44.f;
            break;
        case 3:
        {
            CGSize signatureSize = [_personstate sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(190, 60) lineBreakMode:NSLineBreakByCharWrapping];
            height = signatureSize.height<44.f?44.f:signatureSize.height;
        }
            break;
        case 4:
            height = 84.f;
        default:
            break;
    }
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier;
    cellIdentifier = [NSString stringWithFormat:@"%d",indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //头像
    if(indexPath.row == 0)
    {
        UIImageView * headerImageView = [[UIImageView alloc] init];
        headerImageView.frame = CGRectMake(0, 0, 100, 100);
        headerImageView.center = CGPointMake(self.view.frame.size.width/2.f, 60.f);
        headerImageView.layer.cornerRadius = headerImageView.frame.size.height/2.f;
        headerImageView.layer.masksToBounds = YES;
        if(_photo.length)
        {
            headerImageView.image = [[UIImage alloc] initWithData:_photo];
        }
        else
        {
            if([_gender isEqualToString:@"男"])
            {
                headerImageView.image = [UIImage imageNamed:@"portrait-male-large.png"];
            }
            else
            {
                headerImageView.image = [UIImage imageNamed:@"portrait-female-large.png"];
            }
        }
        [cell.contentView addSubview:headerImageView];
    }
    //性别和年龄
    if(indexPath.row == 1)
    {
        CGSize ageSize = [_age sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:CGSizeMake(130.0, 999) lineBreakMode:NSLineBreakByCharWrapping];
        
        UIImageView * iconImageView = [[UIImageView alloc] init];
        iconImageView.frame = CGRectMake((self.view.frame.size.width - ageSize.width - 10 - 30)/2.f, 0, 30, 30);
        iconImageView.layer.cornerRadius = iconImageView.frame.size.height/2.f;
        iconImageView.layer.masksToBounds = YES;
        if([_gender isEqualToString:@"男"])
        {
            iconImageView.image = [UIImage imageNamed:@"male-large.png"];
        }
        else
        {
            iconImageView.image = [UIImage imageNamed:@"female-large.png"];
        }
        [cell.contentView addSubview:iconImageView];
        
        UILabel * ageLabel = [[UILabel alloc] init];
        ageLabel.frame = CGRectMake(iconImageView.frame.origin.x + iconImageView.frame.size.width + 10.f, 0, ageSize.width, 30);
        ageLabel.backgroundColor = [UIColor clearColor];
        ageLabel.font = [UIFont systemFontOfSize:17.0];
        ageLabel.textAlignment = NSTextAlignmentCenter;
        ageLabel.text = _age;
        [cell.contentView addSubview:ageLabel];
        //分隔线
        UIView * lineView = [[UIView alloc] init];
        lineView.frame = CGRectMake(20, 39, self.view.frame.size.width - 40, 1);
        lineView.backgroundColor = [UIColor colorWithHexString:@"c6c6c6"];
        [cell.contentView addSubview:lineView];
    }
    //邮箱
    if(indexPath.row == 2)
    {
        UILabel * emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 8, 80, 30)];
        emailLabel.backgroundColor = [UIColor clearColor];
        emailLabel.textAlignment = NSTextAlignmentLeft;
        emailLabel.font = [UIFont systemFontOfSize:15.f];
        emailLabel.text = NSLocalizedString(@"邮箱", nil);
        [cell.contentView addSubview:emailLabel];
        
        UILabel * emailContentLabel = [[UILabel alloc] init];
        emailContentLabel.frame = CGRectMake(emailLabel.frame.origin.x + emailLabel.frame.size.width + 10, emailLabel.frame.origin.y, self.view.frame.size.width - emailLabel.frame.origin.x - emailLabel.frame.size.width - 10 - 40, 30);
        emailContentLabel.backgroundColor = [UIColor clearColor];
        emailContentLabel.textAlignment = NSTextAlignmentLeft;
        emailContentLabel.textColor = [UIColor darkGrayColor];
        emailContentLabel.font = [UIFont systemFontOfSize:15.f];
        emailContentLabel.text = _email;
        [cell.contentView addSubview:emailContentLabel];
        
        //分隔线
        UIView * lineView = [[UIView alloc] init];
        lineView.frame = CGRectMake(20, 43, self.view.frame.size.width - 40, 1);
        lineView.backgroundColor = [UIColor colorWithHexString:@"c6c6c6"];
        [cell.contentView addSubview:lineView];
        
    }
    //个性签名
    if(indexPath.row == 3)
    {
        UILabel * signatureLabel = [[UILabel alloc] init];
        signatureLabel.frame = CGRectMake(20, 8, 80, 30);
        signatureLabel.backgroundColor = [UIColor clearColor];
        signatureLabel.textAlignment = NSTextAlignmentLeft;
        signatureLabel.font = [UIFont systemFontOfSize:15.f];
        signatureLabel.text = NSLocalizedString(@"个性签名", nil);
        [cell.contentView addSubview:signatureLabel];
        
        
        CGSize signatureSize = [_personstate sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(190, 60) lineBreakMode:NSLineBreakByCharWrapping];
        UILabel * signatureContentLabel = [[UILabel alloc] init];
        signatureContentLabel.frame = CGRectMake(signatureLabel.frame.origin.x + signatureLabel.frame.size.width + 10, 14, signatureSize.width, signatureSize.height);
        signatureContentLabel.backgroundColor = [UIColor clearColor];
        signatureContentLabel.textColor = [UIColor darkGrayColor];
        signatureContentLabel.font = [UIFont systemFontOfSize:15.f];
        signatureContentLabel.numberOfLines = 2;
        signatureContentLabel.text = _personstate;
        [cell.contentView addSubview:signatureContentLabel];
        
        //分隔线
        UIView * lineView = [[UIView alloc] init];
        lineView.frame = CGRectMake(20, signatureSize.height < 44?43:signatureSize.height - 1, self.view.frame.size.width - 40, 1);
        lineView.backgroundColor = [UIColor colorWithHexString:@"c6c6c6"];
        [cell.contentView addSubview:lineView];
    }
    if(indexPath.row == 4)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, 40, self.view.frame.size.width - 20, 44);
        [button setBackgroundImage:[UIImage imageNamed:@"blue_button"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"blue_button_s"] forState:UIControlStateSelected];
        if(self.isFriend)
        {
            [button setTitle:NSLocalizedString(@"发送消息", nil) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(sendMessageToOther) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [button setTitle:NSLocalizedString(@"加为情侣", nil) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
        }
        [cell.contentView addSubview:button];
    }
    return cell;
}

-(void)sendMessageToOther
{
    ChatWithOtherViewController *tvc=[[ChatWithOtherViewController alloc]init];
    
    //using nickname for now, change later
    
    //tvc.xmppFriendJID=[XMPPJID jidWithUser:[object nickname] domain:kXMPPmyDomain resource:@"ios"];
    tvc.xmppFriendJID=self.jid;
    tvc.xmppFriendNickname=_nickName;
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:tvc];
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)addFriend
{
    [theApp XMPPAddFriendSubscribeWithJid:[NSString stringWithFormat:@"%@",self.jid]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPPNotificationDidAskFriend object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
