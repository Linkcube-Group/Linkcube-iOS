//
//  NotificationViewController.m
//  huizon
//
//  Created by Meng Wang on 14-7-23.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "NotificationViewController.h"
#import "RightCell.h"
#import "XMPPvCardTemp.h"
#import "IMControls.h"

@interface NotificationViewController () <UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *tbResult;
    NSMutableArray *dataArray;
    NSManagedObjectContext *context;
    NSArray *friends;
    NSMutableDictionary *dicJidToStatus;
}

@end

@implementation NotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dataArray=[[NSMutableArray alloc]init];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSubscribe:) name:kXMPPNotificationDidReceivePresence object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:kXMPPNotificationDidAskFriend object:nil];

    }
    return self;
}

//not used any more
- (void) receiveSubscribe:(NSNotification *) notification
{
    XMPPPresence * presence=[notification.userInfo objectForKey:@"presence"];
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",[presence from]]];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];

    XMPPUserCoreDataStorageObject *object =[[XMPPUserCoreDataStorageObject alloc]initWithEntity:entity insertIntoManagedObjectContext:context];
    object.jid=jid;
    object.jidStr=jid.bare;
    object.subscription=@"Ask";
    //dicJidToStatus[object.jidStr]=@"Ask";
    [dataArray addObject:object];
    [tbResult reloadData];
    //[theApp.xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    //[theApp.xmppRoster removeUser:jid];
    //[theApp.xmppRoster addU]
    
}

- (void) refreshTable
{
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        [self getData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [tbResult reloadData];
            
        });
        
    });
    //[self getData];
    //get[tbResult reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"消息"];
    self.navigationItem.leftBarButtonItem=[[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(btBack_DisModal:)];
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        //[self getMessageData];
        [self getData];
        dispatch_async(dispatch_get_main_queue(), ^{
            

            [tbResult reloadData];
            
        });
        
    });

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //进来清空通知数
    [[IMControls defaultControls] clearNewNoticesCountWithType:NotificationCountTypeAddfriend];
    context=[[theApp xmppRosterStorage] mainThreadManagedObjectContext];
    dicJidToStatus=[[NSMutableDictionary alloc] init];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:kXMPPNotificationDidAskFriend object:nil];
}






#pragma customised method




//first add add friend request then other friend status
- (void)getData
{


    /*
    //theApp.xmppRoster.autoClearAllUsersAndResources=YES;
    for (NSManagedObject *obj in friends)
    {
        [context deleteObject:obj];
    }
    [theApp.xmppRoster fetchRoster];
    
    friends = [context executeFetchRequest:request error:&error];
    */
    [dataArray removeAllObjects];
    //[dataArray addObjectsFromArray:friends];
    
    /*
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSArray *subscribePresence=[defaults arrayForKey:@"subscribe"];
    
    for(NSString *from in subscribePresence)
    {
        //XMPPPresence * presence=[notification.userInfo objectForKey:@"presence"];
        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",from]];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];
        
        XMPPUserCoreDataStorageObject *object =[[XMPPUserCoreDataStorageObject alloc]initWithEntity:entity insertIntoManagedObjectContext:context];
        object.jid=jid;
        object.jidStr=jid.bare;
        object.subscription=@"Ask";
        dicJidToStatus[object.jidStr]=@"Ask";
        //[dataArray addObject:object];
        
    }
    */
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
    NSError *error ;
    friends = [context executeFetchRequest:request error:&error];
    for (XMPPUserCoreDataStorageObject *object in friends)
    {
        NSString *jidStr=object.jidStr;
        NSString *status=object.subscription;
        [dicJidToStatus setObject:status forKey:jidStr];
    }
    
    for(XMPPUserCoreDataStorageObject *object in friends)
    {
        NSString * status=object.subscription;
        if(status.length!=0)//&&!([status isEqualToString:@"none"]))
        {
            [dataArray addObject:object];
        }
    }
    
    
    //XMPPUserCoreDataStorageObject *object
    //[self.friendsArray removeAllObjects];
    //[self.friendsArray addObjectsFromArray:friends];
    
}


#pragma table delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [dataArray count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    return 50;
}




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
    
    XMPPUserCoreDataStorageObject *object = [dataArray objectAtIndex:indexPath.row];
    //NSDictionary *dic=[dataArray objectAtIndex:indexPath.row];
    /*
    NSString *name = [object displayName];
    if (!name) {
        name = [object nickname];
    }
    if (!name) {
        name = [object jidStr];
    }
    */
    NSString *name=nil;

    name=[theApp.xmppvCardTempModule vCardTempForJID:object.jid shouldFetch:YES].nickname;
    [cell setMenuImage:@"portrait-female-small" Name:name];
    NSString *jidStr=object.jidStr;
    [cell setCellFriendId:jidStr];
    [cell setCellFriendName:name];
    
    NSString *status=object.subscription;
    
        if ([status isEqualToString:@"both"])
        {
            status=@"已添加";
        }
        else if([status isEqualToString:@"Ask"])
        {
            status=@"判断";
        }
        else if([status isEqualToString:@"from"])
        {
            status=@"等待验证";
            
        }
        else if([status isEqualToString:@"none"])
        {
            status=@"判断";
        }
        [cell setFriendStatus:status];
        
    
    //[cell setFriendStatus:@"None"];
    
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
