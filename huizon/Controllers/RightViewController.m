//
//  RightViewController.m
//  huizon
//
//  Created by yang Eric on 5/17/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "RightViewController.h"
#import "JASidePanelController.h"
#import "UserViewController.h"
#import "TalkViewController.h"
#import "FriendViewController.h"
#import "PersonSettingController.h"
#import "RightCell.h"
#import "AddFriendViewController.h"
#import "XMPPvCardTemp.h"
#define FRIEND_LIST @[@"",@"我的",@"消息",@"情侣"]

@interface RightViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSManagedObjectContext *context;
}

@property (strong,nonatomic) IBOutlet UITableView  *tbFriend;
@property (nonatomic, strong) NSMutableArray *friendsArray;

@end



@implementation RightViewController

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
    self.friendsArray = [[NSMutableArray alloc] init];
    
    context=[[[self appDelegate] xmppRosterStorage] mainThreadManagedObjectContext];
    [theApp getUserCardTemp];
     [theApp.sidePanelController addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
    // Do any additional setup after loading the view from its nib.
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
    [self.friendsArray addObjectsFromArray:friends];

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
    if (indexPath.row==0)
    {
        
    }
    else if(indexPath.row==1)
    {
        if ([theApp.xmppStream isAuthenticated])
        {
            //XMPPvCardTemp *xmppvCardTemp=[theApp.xmppvCardTempModule myvCardTemp];
            
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
            
            [cell setMenuImage:@"portrait-male-small" Name:name];
        }
        else
        {
            [cell setMenuImage:@"portrait-male-small" Name:@"未登录"];
        }
        
    }
    else if(indexPath.row==2)
    {
        [cell setMenuImage:@"icon-message" Name:@"消息"];
        [cell setRightIcon:@"button-add"];
    }
    else if(indexPath.row==3)
    {
        [cell setMenuImage:@"icon-lover" Name:@"情侣"];
        [cell setRightIcon:@"button-add"];
        
        
    }
    else if (indexPath.row>3 && indexPath.row<4+[self.friendsArray count])
    {
        
        XMPPUserCoreDataStorageObject *object = [self.friendsArray objectAtIndex:indexPath.row-4];
        NSString *name= [object displayName];
        if (!name) {
            name = [object nickname];
        }
        if (!name) {
            name = [object jidStr];
        }
        [cell setMenuImage:@"portrait-female-small" Name:name];
        
    }
    //cell.textLabel.text = [FRIEND_LIST objectAtIndex:indexPath.row];
    return cell;
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
        XMPPUserCoreDataStorageObject *object = [self.friendsArray objectAtIndex:indexPath.row-4];
        TalkViewController *tvc=[[TalkViewController alloc]init];
        
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
