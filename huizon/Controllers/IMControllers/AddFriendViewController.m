//
//  AddFriendViewController.m
//  huizon
//
//  Created by Meng Wang on 14-6-22.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "AddFriendViewController.h"
#import "RightCell.h"
#import "XMPPSearchModule.h"
#import "XMPPvCardTemp.h"
#import "FriendInfoViewController.h"

@interface AddFriendViewController () <UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITextField *txtSearch;
    IBOutlet UITableView *tbResult;
    NSMutableArray *dataArray;
    NSManagedObjectContext *context;
    NSArray *friends;
    NSMutableDictionary *dicJidToStatus;
}

@end

@implementation AddFriendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"添加情侣"];
    self.navigationItem.leftBarButtonItem=[[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(btBack_DisModal:)];
    //[self refreshTable];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    context=[[theApp xmppRosterStorage] mainThreadManagedObjectContext];
    dicJidToStatus=[[NSMutableDictionary alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:kXMPPNotificationDidAskFriend object:nil];
    [self refreshTable];
}

- (void) refreshTableNoGettingData
{
    [tbResult reloadData];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)searchModel:(XMPPSearchModule*)searchModul result:(XMPPSearchReported*)result userData:(id)userData
{
    NSLog(@"search result : %@", result);
    if  ([result.items count]==0)
    {
        showCustomAlertMessage(@"无此账号");
    }
    dataArray = [[NSMutableArray alloc] init];
    for(NSDictionary * dict in result.items)
    {
        NSMutableDictionary * mDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        XMPPvCardTemp * vCardTemp = [theApp.xmppvCardTempModule vCardTempForJID:[XMPPJID jidWithString:[mDict keyForValue:@"jid"]] shouldFetch:YES];
        if(vCardTemp.photo.length)
            [mDict setObject:vCardTemp.photo forKey:@"photo"];
        if(vCardTemp.gender.length)
            [mDict setObject:vCardTemp.gender forKey:@"gender"];
        [dataArray addObject:mDict];
    }
    [tbResult reloadData];
    showIndicator(NO);
}

- (void)searchModelGetFields:(XMPPSearchModule *)searchModul
{
    NSLog(@"Get fields : %@", searchModul.result);
}

- (void)getData
{
    [theApp.xmppRoster fetchRoster];
    //[theApp.xmppRosterStorage.]
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
    
    //XMPPUserCoreDataStorageObject *object
    //[self.friendsArray removeAllObjects];
    //[self.friendsArray addObjectsFromArray:friends];
    
}

-(IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
    
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        //[self getMessageData];
        [self getData];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            /*
             NSString *name=txtSearch.text;
             name =[name stringByReplacingOccurrencesOfString:@"@" withString:@"-"];
             NSString *requestText=[NSString stringWithFormat:@"%@%@%@",@"已向",txtSearch.text,@"发出请求"];
             [theApp XMPPAddFriendSubscribe:name];
             */
            [theApp.xmppSearchModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
            //[theApp.xmppSearchModule askForFields];
            XMPPSearchSingleNode *search = [[XMPPSearchSingleNode alloc] init];
            //nick email
            search.name = @"email";//@"NICKNAME";
            search.value = txtSearch.text;
            [theApp.xmppSearchModule searchWithFields:@[search] userData:nil];
            //[self updateUI:arrayMessage];
            //[tbResult reloadData];
            
        });
        
    });
    
    
    
    
    
    showIndicator(YES);
    //NSString *requestText=[NSString stringWithFormat:@"%@%@%@",@"正在搜索",txtSearch.text,@"用户"];
    //[theApp showAlertView:requestText];
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
    
    //XMPPUserCoreDataStorageObject *object = [dataArray objectAtIndex:indexPath.row];
    NSDictionary *dic=[dataArray objectAtIndex:indexPath.row];
    //    [cell setMenuImage:@"portrait-female-small" Name:[dic keyForValue:@"nick"]];
    if(((NSData *)[dic objectForKey:@"photo"]).length)
    {
        [cell setMenuImageWithData:[dic objectForKey:@"photo"] Name:[dic keyForValue:@"nick"]];
    }
    else if ([[dic keyForValue:@"gender"] isEqualToString:@"男"])
    {
        [cell setMenuImage:@"portrait-male-small" Name:[dic keyForValue:@"nick"]];
    }
    else
    {
        [cell setMenuImage:@"portrait-female-small" Name:[dic keyForValue:@"nick"]];
    }
    NSString *jidStr=[dic keyForValue:@"jid"];
    [cell setCellFriendId:jidStr];
    [cell setCellFriendName:[dic keyForValue:@"nick"]];
    
    NSString *status=[dicJidToStatus valueForKey:jidStr];
    if (status.length==0)
    {
        [cell setFriendStatus:@"None"];
        
    }
    else
    {
        if ([status isEqualToString:@"both"])
        {
            status=@"已添加";

        }
        else
        {
            status=@"等待验证";

            
        }
        [cell setFriendStatus:status];
    }
    //[cell setFriendStatus:@"None"];
    
    return cell;
}

-(void)reloadTableView
{
    [tbResult reloadData];
}

-(void)headerButtonClicked:(UIButton *)button
{
    NSLog(@"tag===%d",button.tag);
    FriendInfoViewController * fvc = [[FriendInfoViewController alloc] init];
    fvc.jid = [XMPPJID jidWithString:[[dataArray objectAtIndex:button.tag] objectForKey:@"jid"]];
    fvc.isFriend = YES;
    UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:fvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

-(void)nHeaderButtonClicked:(UIButton *)button
{
    NSLog(@"tag===%d",button.tag);
    FriendInfoViewController * fvc = [[FriendInfoViewController alloc] init];
    fvc.jid = [XMPPJID jidWithString:[[dataArray objectAtIndex:button.tag] objectForKey:@"jid"]];
    fvc.isFriend = NO;
    UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:fvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

@end
