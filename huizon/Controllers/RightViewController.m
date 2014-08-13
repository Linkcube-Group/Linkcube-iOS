//
//  RightViewController.m
//  huizon
//
//  Created by yang Eric on 5/17/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#warning 记得最后改完删掉
/*
 add by yuyang to note
 4.添加好友，消息提示
 7.聊天界面
 9.消息界面问题还很大
 10.注册完成后先给放上默认的nickname
 11.注册我测试了，成功后。登陆进去资料还都是空的。
 */

#import "RightViewController.h"
#import "JASidePanelController.h"
#import "UserViewController.h"
//#import "TalkViewController.h"
#import "ChatWithOtherViewController.h"
#import "FriendViewController.h"
#import "PersonSettingController.h"
#import "RightCell.h"
#import "AddFriendViewController.h"
#import "XMPPvCardTemp.h"
#import "NotificationViewController.h"
#import "FriendInfoViewController.h"
#import "IMControls.h"
#import "JSBadgeView.h"
#import "FileManager.h"

#define FRIEND_LIST @[@"",@"我的",@"消息",@"情侣"]

@interface RightViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSManagedObjectContext *context;
}

@property (strong,nonatomic) IBOutlet UITableView  *tbFriend;
@property (nonatomic, strong) NSMutableArray *friendsArray;
@property (nonatomic, strong) NSMutableDictionary * messageCountDict;

@end



@implementation RightViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.messageCountDict = [FileManager loadObject:XMPP_RECEIVE_MESSAGE_COUNT];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSubscribe:) name:kXMPPNotificationDidReceivePresence object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessage:) name:KXMPPNotificationDidReceiveMessage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessage:) name:@"clearMessageCount" object:nil];

    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friendsArray = [[NSMutableArray alloc] init];
    self.tbFriend.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    context=[[[self appDelegate] xmppRosterStorage] mainThreadManagedObjectContext];
    [theApp getUserCardTemp];
     [theApp.sidePanelController addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
    // Do any additional setup after loading the view from its nib.
    }


- (void) receiveSubscribe:(NSNotification *) notification
{
    //XMPPPresence * presence=[notification.userInfo objectForKey:@"presence"];
    //XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",[presence from]]];
    //[theApp.xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    //[theApp.xmppRoster removeUser:jid];
    //[theApp.xmppRoster addU]
    [self.tbFriend reloadData];
    
}

-(void)receivedMessage:(NSNotification *) notification
{
    self.messageCountDict = [FileManager loadObject:XMPP_RECEIVE_MESSAGE_COUNT];
    [self.tbFriend reloadData];
}
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    
    if ([keyPath isEqual:@"state"] && theApp.sidePanelController.state==JASidePanelRightVisible) {
        
        if ([theApp isXmppAuthenticated]==NO) {
            UserViewController *uvc = [[UserViewController alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:uvc];
            [self presentViewController:nav animated:YES completion:nil];
        }
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([theApp isXmppAuthenticated]==NO) {
        [theApp.sidePanelController showCenterPanelAnimated:YES];
    }
    //导航条背景
    [[UINavigationBar appearance] setBackgroundImage:IMG(@"navigation-and-status") forBarMetrics:UIBarMetricsDefault];

}


-(void)viewDidAppear:(BOOL)animated
{
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        //[self getMessageData];
        [self getData];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[self updateUI:arrayMessage];
            [self.tbFriend reloadData];

        });
        
    });
}

#pragma mark -
#pragma mark GetFriend Data


- (AppDelegate *)appDelegate
{
    theApp.chatDelegate = self;
	return theApp;
}
- (void)getData
{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
    NSError *error ;
    NSArray *friends = [context executeFetchRequest:request error:&error];
    [self.friendsArray removeAllObjects];
    for(XMPPUserCoreDataStorageObject *object in friends)
    {
        if ([object.subscription isEqualToString:@"both"])
        {
            XMPPvCardTemp * temp = [[theApp xmppvCardTempModule] vCardTempForJID:object.jid shouldFetch:YES];
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setObject:object forKey:@"object"];
            [dict setObject:@"0" forKey:@"new"];
            if(temp.photo)
                [dict setObject:temp.photo forKey:@"photo"];
            if(temp.gender)
                [dict setObject:temp.gender forKey:@"gender"];
            [self.friendsArray addObject:dict];
        }
    }

}


//not used
- (IBAction)addFriendButton:(id)sender
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"请输入用户名" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    [alert show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle=[alertView buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"确定"])
    {
        UITextField *tf=[alertView textFieldAtIndex:0];
        NSString *text=tf.text;
        //[theApp showAlertView:text];
        [theApp XMPPAddFriendSubscribe:text];
        //[theApp.xmppRoster fetchRoster];
        //[self getData];
        //[tableFriends reloadData];
    }
    
}


#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4+[self.friendsArray count];
    //return [FRIEND_LIST count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        return 70;
    }
    else if(indexPath.row==1)
    {
        return 50;
    }
    else if(indexPath.row==2||indexPath.row==3)
    {
        return 35;
    }
    else if (indexPath.row>3 && indexPath.row<4+[self.friendsArray count])
    {
        return 50;
    }

    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *cellIdentifier = @"UITableViewCell";
    
    if (indexPath.row==0)
    {
        cellIdentifier = @"RightCellHead";
    }
    else if(indexPath.row==1 || indexPath.row==4 || indexPath.row==5)
    {
        cellIdentifier = @"RightCellUser";
    }
    else if(indexPath.row==2||indexPath.row==3)
    {
        cellIdentifier = @"RightCellLabel";
    }

    
    RightCell *cell = (RightCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
//    cell.contentView.backgroundColor = [UIColor whiteColor];
    if (indexPath.row==0)
    {
        
    }
    else if(indexPath.row==1)
    {
        if ([theApp.xmppStream isAuthenticated])
        {
            XMPPvCardTemp *xmppvCardTemp=[theApp.xmppvCardTempModule myvCardTemp];
            NSData * photo = xmppvCardTemp.photo;
            //NSString *uname = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID];
            NSString *name=theApp.xmppvCardUser.nickname;
            if (!name)
            {
                name=theApp.xmppvCardUser.email;
            }
            if (!name)
            {
                name=[theApp.xmppvCardUser.jid bare];
            }
            if(photo.length)
            {
                [cell setMenuImageWithData:photo Name:name];
            }
            else if ([xmppvCardTemp.gender isEqualToString:@"男"])
            {
                [cell setMenuImage:@"portrait-male-small" Name:name];
            }
            else
            {
                [cell setMenuImage:@"portrait-female-small" Name:name];
            }
        }
        else
        {
            [cell setMenuImage:@"portrait-male-small" Name:NSLocalizedString(@"未登录", nil)];
        }
        [cell.headerButton addTarget:self action:@selector(selfInfo) forControlEvents:UIControlEventTouchUpInside];
    }
    else if(indexPath.row==2)
    {
        [cell setMenuImage:@"icon-message" Name:@"消息"];
        [cell setRightIcon:@"next_grey"];
        UIView * lineView = [[UIView alloc] init];
        lineView.frame = CGRectMake(0, 34.f, self.view.frame.size.width, 1);
        lineView.backgroundColor = [UIColor colorWithHexString:@"afafaf"];
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"cccccc"];
        [cell.contentView addSubview:lineView];
        
        JSBadgeView * jsbView = [[JSBadgeView alloc] initWithParentView:cell.contentView alignment:JSBadgeViewAlignmentBottomRight];
        jsbView.badgePositionAdjustment = CGPointMake(-45.0, -17.5);
        NSInteger count = theApp.isXmppAuthenticated?[[IMControls defaultControls] getNewNoticesCountWithType:NotificationCountTypeAddfriend]:0;
        jsbView.badgeText = count>0?[NSString stringWithFormat:@"%d",count]:nil;
    }
    else if(indexPath.row==3)
    {
        [cell setMenuImage:@"icon-lover" Name:@"情侣"];
        [cell setRightIcon:@"button-add"];
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"cccccc"];
        
        JSBadgeView * jsbView = [[JSBadgeView alloc] initWithParentView:cell.contentView alignment:JSBadgeViewAlignmentBottomRight];
        jsbView.badgePositionAdjustment = CGPointMake(-45.0, -18.0);
        jsbView.badgeText = nil;
        
    }
    else if (indexPath.row>3 && indexPath.row<4+[self.friendsArray count])
    {
        if(self.friendsArray.count > 1)
        {
            UIView * lineView = [[UIView alloc] init];
            lineView.frame = CGRectMake(0, 49.f, self.view.frame.size.width, 1);
            lineView.backgroundColor = [UIColor colorWithHexString:@"c6c6c6"];
            [cell.contentView addSubview:lineView];
        }
        
        XMPPUserCoreDataStorageObject *object = [[self.friendsArray objectAtIndex:indexPath.row-4] objectForKey:@"object"];
        /*
        NSString *name= [object displayName];
        if (!name) {
            name = [object nickname];
        }
        if (!name) {
            name = [object jidStr];
        }
         */
        NSString *name=[theApp.xmppvCardTempModule vCardTempForJID:object.jid shouldFetch:YES].nickname;
        NSData * photoImageData = [[self.friendsArray objectAtIndex:indexPath.row - 4] objectForKey:@"photo"];
        NSString * gender = [[self.friendsArray objectAtIndex:indexPath.row - 4] objectForKey:@"gender"];
        if(photoImageData.length)
        {
            [cell setMenuImageWithData:photoImageData Name:name];
        }
        else if ([gender isEqualToString:@"男"])
        {
            [cell setMenuImage:@"portrait-male-small" Name:name];
        }
        else
        {
            [cell setMenuImage:@"portrait-female-small" Name:name];
        }
        cell.headerButton.tag = indexPath.row - 4;
        [cell.headerButton addTarget:self action:@selector(friendInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        JSBadgeView * jsbView = [[JSBadgeView alloc] initWithParentView:cell.contentView alignment:JSBadgeViewAlignmentBottomRight];
        jsbView.badgePositionAdjustment = CGPointMake(-20.0, -25.0);
        NSString * count = [self.messageCountDict objectForKey:object.jidStr];
        if([count isEqualToString:@"1"])
        {
            jsbView.badgeText = @"";
        }
        else
        {
            jsbView.badgeText = nil;
        }
    }
    //cell.textLabel.text = [FRIEND_LIST objectAtIndex:indexPath.row];
    return cell;
}

-(void)friendInfo:(UIButton *)button
{
    XMPPUserCoreDataStorageObject *object = [[self.friendsArray objectAtIndex:button.tag] objectForKey:@"object"];
    FriendInfoViewController * fvc = [[FriendInfoViewController alloc] init];
    fvc.isFriend = YES;
    fvc.jid = object.jid;
    UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:fvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

-(void)selfInfo
{
    PersonSettingController *psc=[[PersonSettingController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:psc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    UINavigationController *nav = nil;
    if (indexPath.row==1)
    {
        if (![theApp.xmppStream isAuthenticated])
        {
            UserViewController *uvc = [[UserViewController alloc] init];
            nav = [[UINavigationController alloc] initWithRootViewController:uvc];
            //[self presentViewController:nav animated:YES completion:nil];
        }
        else
        {
            PersonSettingController *psc=[[PersonSettingController alloc] init];
            nav = [[UINavigationController alloc] initWithRootViewController:psc];
            //[self presentViewController:nav animated:YES completion:nil];
        }

    }
    else if (indexPath.row==2)
    {
        FriendViewController *fvc = [[FriendViewController alloc] init];
        //NotificationViewController *nvc = [[NotificationViewController alloc] init];
        nav = [[UINavigationController alloc] initWithRootViewController:fvc];
    }
    else if (indexPath.row==3)
    {
        /*
         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"请输入用户名" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        alert.alertViewStyle=UIAlertViewStylePlainTextInput;
        [alert show];
         */
        AddFriendViewController *afvc=[[AddFriendViewController alloc]init];
        nav = [[UINavigationController alloc] initWithRootViewController:afvc];
    }
    else if (indexPath.row>3 && indexPath.row<4+[self.friendsArray count])
    {
        XMPPUserCoreDataStorageObject *object = [[self.friendsArray objectAtIndex:indexPath.row-4] objectForKey:@"object"];
        ChatWithOtherViewController *tvc=[[ChatWithOtherViewController alloc]init];
        
        //using nickname for now, change later
        
        //tvc.xmppFriendJID=[XMPPJID jidWithUser:[object nickname] domain:kXMPPmyDomain resource:@"ios"];
        tvc.xmppFriendJID=[XMPPJID jidWithString:[object jidStr] resource:@"iOS"];
        tvc.xmppFriendNickname=[object nickname];
        nav = [[UINavigationController alloc] initWithRootViewController:tvc];
    }
    if (nav) {
        [self presentViewController:nav animated:YES completion:nil];
        //[theApp.sidePanelController setCenterPanel:nav];
    }
    
}

- (IBAction)presentModal:(id)sender {
   
//    [self presentViewController:controller animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
