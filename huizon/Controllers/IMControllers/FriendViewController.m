//
//  FriendViewController.m
//  huizon
//
//  Created by Yang on 14-2-26.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "FriendViewController.h"
#import "UserViewController.h"
#import "TalkViewController.h"
#import "RightCell.h"
#import "NotificationCell.h"
#import "FileManager.h"

@interface FriendViewController ()<UITableViewDataSource,UITableViewDelegate,ChatDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray * receiveAddFriendArray;
@property (nonatomic, strong) IBOutlet UITableView *tableFriends;

@end

@implementation FriendViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:kXMPPNotificationDidReceivePresence object:nil];
    }
    return self;
}

-(void)reloadTableData
{
    [self getAddFriendIQFromCache];
    [self.tableFriends reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataArray = [[NSMutableArray alloc] init];
    self.receiveAddFriendArray = [[NSMutableArray alloc] init];
    self.tableFriends.delegate = self;
    self.tableFriends.dataSource = self;
    [self getData];
    [self reloadTableData];
    [self.tableFriends reloadData];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark
#pragma mark - 获得收到的加好友请求

-(void)getAddFriendIQFromCache
{
    self.receiveAddFriendArray = [FileManager loadArray:XMPP_RECEIVE_ADDFRIEND_IQ];
}

#pragma mark - 再存回去

-(void)SaveNewCache
{
    [FileManager saveObject:self.receiveAddFriendArray filePath:XMPP_RECEIVE_ADDFRIEND_IQ];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - my method

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"消息"];
    self.navigationItem.leftBarButtonItem=[[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(btBack_DisModal:)];
}


- (AppDelegate *)appDelegate
{
    theApp.chatDelegate = self;
	return theApp;
}

- (void)getData
{
    NSManagedObjectContext *context = [[[self appDelegate] xmppRosterStorage] mainThreadManagedObjectContext];
    //XMPPUserCoreDataStorageObject
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
    NSError *error ;
    NSArray *friends = [context executeFetchRequest:request error:&error];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:friends];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count] + [self.receiveAddFriendArray count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


#if 0

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *cellIdentifier = @"RightCellRequest";
    RightCell *cell = (RightCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    XMPPUserCoreDataStorageObject *object = [self.dataArray objectAtIndex:indexPath.row];
    NSString *name = [object displayName];
    if (!name) {
        name = [object nickname];
    }
    if (!name) {
        name = [object jidStr];
    }
    
    
    
    
    
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    NSString *bareJid=[theApp.xmppStream.myJID bare];
    
    NSString *messageFromBareJid=[object.jid bare];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"bareJidStr==%@ AND streamBareJidStr==%@",messageFromBareJid,bareJid];
    [request setEntity:entityDescription];
    [request setPredicate:predicate]; //查找条件
    NSError *error=nil;
    NSArray *messageArray=[moc executeFetchRequest:request error:&error]; //查找与当前用户聊天记录
    
    XMPPMessageArchiving_Message_CoreDataObject *message=messageArray.lastObject;
    
    NSString *lastMessage=message.body;
    
    int statusNum=[object.sectionNum intValue];
    NSString *status=@"";
    NSString *subStatus=@"";
    NSString *askStatus=@"";
    if(statusNum==0)
        status=@"在线";
    else if (statusNum==1)
        status=@"离开";
    else
        status=@"离线";
    if ([object.subscription isEqualToString:@"both"])
        //subStatus=@"互加好友";
        subStatus=@"已添加";
    else if ([object.subscription isEqualToString:@"from"])
        subStatus=@"";
    else if ([object.subscription isEqualToString:@"to"])
        subStatus=@"你已关注对方";
    else
        
        if ([object.ask isEqualToString:@"subscribe"])
            //subStatus=@"已发出请求";
            subStatus=@"等待验证";
        else
            subStatus=@"";
    NSString *numUnreadMessages=[NSString stringWithFormat:@"%d",[object.unreadMessages intValue]];
    __unused NSString *allStatus=[NSString stringWithFormat:@"%@,%@,%@,%@,%@",status,subStatus,askStatus,numUnreadMessages,lastMessage];
    
    
    if(object.photo)
    {
        [cell setMenuImageWithImage:object.photo Name:name];
    }
    else
        [cell setMenuImage:@"portrait-female-small" Name:name];
    [cell setFriendStatus:subStatus];
    
    return cell;
}

#else
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //测试用163添加qq
    static NSString *cellIdentifier = @"RightCellRequest";
    NotificationCell *cell = (NotificationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if(indexPath.row < self.receiveAddFriendArray.count)
    {
        XMPPPresence * presence = [self.receiveAddFriendArray objectAtIndex:indexPath.row];
        cell.headerImageView.image = [UIImage imageNamed:@"portrait-female-small"];
        cell.nameLabel.text = [NSString stringWithFormat:@"%@",[presence from]];
        cell.notiType = NotificationTypeFrom;
        cell.jid = [presence from];
    }
    else
    {
        XMPPUserCoreDataStorageObject *object = [self.dataArray objectAtIndex:indexPath.row-self.receiveAddFriendArray.count];
        NSString *name = [object displayName];
        if (!name) {
            name = [object nickname];
        }
        if (!name) {
            name = [object jidStr];
        }
        NSLog(@"=================>%@ %@",object.subscription,object.ask);
        int statusNum=[object.sectionNum intValue];
        NSString *status=@"";
        NSString *subStatus=@"";
        if(statusNum==0)
            status=@"在线";
        else if (statusNum==1)
            status=@"离开";
        else
            status=@"离线";
        if ([object.subscription isEqualToString:@"both"])
            //subStatus=@"互加好友";
            subStatus=@"已添加";
        else if ([object.subscription isEqualToString:@"from"])
            subStatus=@"对方已关注你";
        else if ([object.subscription isEqualToString:@"to"])
            subStatus=@"你已关注对方";
        else
            
            if ([object.ask isEqualToString:@"subscribe"])
                //subStatus=@"已发出请求";
                subStatus=@"等待验证";
            else
                subStatus=@"";
        
        cell.headerImageView.image = [UIImage imageNamed:@"portrait-female-small"];
        cell.nameLabel.text = name;
        if([object.subscription isEqualToString:@"both"])
        {
            cell.notiType = NotificationTypeBoth;
        }
        else
        {
            cell.notiType = NotificationTypeTo;
        }
    }
    
    
    
    return cell;
}
#endif

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 static NSString *CellIdentifier = @"Cell";
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (cell==nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
 }
 XMPPUserCoreDataStorageObject *object = [self.dataArray objectAtIndex:indexPath.row];
 NSString *name = [object displayName];
 if (!name) {
 name = [object nickname];
 }
 if (!name) {
 name = [object jidStr];
 }
 cell.textLabel.text = name;
 
 //if([objcet.sectionNum intValue==0)
 
 
 XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
 NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
 NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
 inManagedObjectContext:moc];
 
 NSFetchRequest *request=[[NSFetchRequest alloc] init];
 NSString *bareJid=[theApp.xmppStream.myJID bare];
 
 NSString *messageFromBareJid=[object.jid bare];
 NSPredicate *predicate=[NSPredicate predicateWithFormat:@"bareJidStr==%@ AND streamBareJidStr==%@",messageFromBareJid,bareJid];
 [request setEntity:entityDescription];
 [request setPredicate:predicate]; //查找条件
 NSError *error=nil;
 NSArray *messageArray=[moc executeFetchRequest:request error:&error]; //查找与当前用户聊天记录
 
 XMPPMessageArchiving_Message_CoreDataObject *message=messageArray.lastObject;
 
 NSString *lastMessage=message.body;
 
 
 
 
 
 
 int statusNum=[object.sectionNum intValue];
 NSString *status=@"";
 NSString *subStatus=@"";
 NSString *askStatus=@"";
 if(statusNum==0)
 status=@"在线";
 else if (statusNum==1)
 status=@"离开";
 else
 status=@"离线";
 if ([object.subscription isEqualToString:@"both"])
 subStatus=@"互加好友";
 else if ([object.subscription isEqualToString:@"from"])
 subStatus=@"对方已关注你";
 else if ([object.subscription isEqualToString:@"to"])
 subStatus=@"你已关注对方";
 else
 
 if ([object.ask isEqualToString:@"subscribe"])
 subStatus=@"已发出请求";
 else
 subStatus=@"";
 NSString *numUnreadMessages=[NSString stringWithFormat:@"%d",[object.unreadMessages intValue]];
 NSString *allStatus=[NSString stringWithFormat:@"%@,%@,%@,%@,%@",status,subStatus,askStatus,numUnreadMessages,lastMessage];
 
 cell.detailTextLabel.text = allStatus ;//[[[object primaryResource] presence] status];
 cell.tag = indexPath.row;
 return cell;
 }
 */
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *object = [self.dataArray objectAtIndex:indexPath.row];
    TalkViewController *tvc=[[TalkViewController alloc]init];
    
    //using nickname for now, change later
    
    //tvc.xmppFriendJID=[XMPPJID jidWithUser:[object nickname] domain:kXMPPmyDomain resource:@"ios"];
    tvc.xmppFriendJID=[XMPPJID jidWithString:[object jidStr] resource:@"iOS"];
    [self.navigationController pushViewController:tvc animated:YES];
}
- (void)prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender;
    //    if ([[segue destinationViewController] isKindOfClass:[ChatViewController class] ]) {
    //        XMPPUserCoreDataStorageObject *object = [self.dataArray objectAtIndex:cell.tag];
    //        ChatViewController *chat = segue.destinationViewController;
    //        chat.xmppUserObject = object;
    //    }
}
#pragma mark - IBAction




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



#pragma mark - Chat Delegate
-(void)friendStatusChange:(AppDelegate *)appD Presence:(XMPPPresence *)presence
{
    for (XMPPUserCoreDataStorageObject *object in self.dataArray) {
        if ([object.jidStr isEqualToString:presence.fromStr] || [object.jidStr isEqualToString:presence.from.bare]) {
            [[[[object primaryResource] presence] childAtIndex:0] setStringValue:presence.status];
        }
    }
    [self.tableFriends reloadData];
}
- (void)receiveMessage:(XMPPMessage *)message
{
    //[theApp showAlertView:message.body];
    
}



-(void)receiveIQ:(XMPPIQ *)iq
{
    //[theApp.xmppRoster fetchRoster];
    [self getData];
    [self.tableFriends reloadData];
}
-(void)friendSubscription:(XMPPPresence *)presence
{
    [theApp.xmppRoster addUser:presence.to withNickname:presence.toStr groups:Nil subscribeToPresence:NO];
    [self getData];
    [self.tableFriends reloadData];
}

@end
