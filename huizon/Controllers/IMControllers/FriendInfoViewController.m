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

@interface FriendInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>

@end

@implementation FriendInfoViewController
{
    UITableView * _mainTableView;
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
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    _mainTableView.backgroundColor = [UIColor colorWithRed:230/255.f green:230/255.f blue:230/255.f alpha:1.f];
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_mainTableView];
}

#pragma mark
#pragma mark - tableView method

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    switch (indexPath.row)
    {
        case 0:
            height = 100.f;
            break;
        case 1:
            height = 30.f;
            break;
        case 2:
            height = 80.f;
            break;
        case 3:
            height = 44.f;
            break;
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
    //头像
    if(indexPath.row == 0)
    {
        UIImageView * headerImageView = [[UIImageView alloc] init];
#warning 记得改大小
        headerImageView.frame = CGRectMake(0, 0, 100, 100);
        headerImageView.center = CGPointMake(self.view.frame.size.width/2.f, 60.f);
        headerImageView.layer.cornerRadius = headerImageView.frame.size.height/2.f;
        headerImageView.layer.masksToBounds = YES;
        [cell.contentView addSubview:headerImageView];
    }
    //性别和年龄
    if(indexPath.row == 1)
    {
        UIImageView * iconImageView = [[UIImageView alloc] init];
        iconImageView.frame = CGRectMake(0, 0, 30, 30);
        iconImageView.layer.cornerRadius = iconImageView.frame.size.height/2.f;
        iconImageView.layer.masksToBounds = YES;
        [cell.contentView addSubview:iconImageView];
        
        UILabel * ageLabel = [[UILabel alloc] init];
        ageLabel.frame = CGRectMake(30, 0, 60, 30);
        ageLabel.backgroundColor = [UIColor clearColor];
        ageLabel.textAlignment = NSTextAlignmentCenter;
        ageLabel.text = @"23";
        [cell.contentView addSubview:ageLabel];
        //分隔线
        UIView * lineView = [[UIView alloc] init];
        lineView.frame = CGRectMake(0, 29.5, self.view.frame.size.width, 0.5);
        lineView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:lineView];
    }
    //个性签名
    if(indexPath.row == 2)
    {
        UILabel * signatureLabel = [[UILabel alloc] init];
        signatureLabel.frame = CGRectMake(20, 0, 80, 30);
        signatureLabel.backgroundColor = [UIColor clearColor];
        signatureLabel.textAlignment = NSTextAlignmentLeft;
        signatureLabel.font = [UIFont systemFontOfSize:19.f];
        signatureLabel.text = NSLocalizedString(@"个性签名", nil);
        [cell.contentView addSubview:signatureLabel];
        
        UILabel * signatureContentLabel = [[UILabel alloc] init];
        signatureContentLabel.frame = CGRectMake(signatureLabel.frame.origin.x + signatureLabel.frame.size.width + 10, signatureLabel.frame.origin.y, self.view.frame.size.width - signatureLabel.frame.origin.x - signatureLabel.frame.size.width - 10, 80);
        signatureContentLabel.backgroundColor = [UIColor clearColor];
        signatureContentLabel.textColor = [UIColor darkGrayColor];
        signatureContentLabel.numberOfLines = 4;
        signatureContentLabel.text = @"哈哈哈哈哈哈哈哈哈哈哈哈哈哈啊哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈啊哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈啊哈哈哈哈哈哈哈哈哈";
        [cell.contentView addSubview:signatureContentLabel];
    }
    if(indexPath.row == 3)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(30, 0, self.view.frame.size.width - 60, 44);
        [button setBackgroundImage:[UIImage imageNamed:@"blue_button"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"blue_button_s"] forState:UIControlStateSelected];
        if(1)
        {
            [button setTitle:NSLocalizedString(@"发送消息", nil) forState:UIControlStateNormal];
        }
        else
        {
            [button setTitle:NSLocalizedString(@"添加好友", nil) forState:UIControlStateNormal];
        }
        [cell.contentView addSubview:button];
    }
    return cell;
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
