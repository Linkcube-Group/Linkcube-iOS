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
        NSString *title     = @"";
        NSString *message   = @"无此账号";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
        [alertView show];
    }
    dataArray=[[NSMutableArray alloc] initWithArray:result.items];
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
        //[self getData];
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
            search.name = @"nick";//@"NICKNAME";
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
    [cell setMenuImage:@"portrait-female-small" Name:[dic keyForValue:@"nick"]];
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

@end
