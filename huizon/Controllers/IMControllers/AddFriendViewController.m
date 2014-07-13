//
//  AddFriendViewController.m
//  huizon
//
//  Created by Meng Wang on 14-6-22.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "AddFriendViewController.h"
#import "RightCell.h"
@interface AddFriendViewController () <UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITextField *txtSearch;
    IBOutlet UITableView *tbResult;
    NSMutableArray *dataArray;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)searchModel:(XMPPSearchModule*)searchModul result:(XMPPSearchReported*)result userData:(id)userData
{
    NSLog(@"search result : %@", result);
    dataArray=[[NSMutableArray alloc] initWithArray:result.items];
    [tbResult reloadData];
    showIndicator(NO);
}

- (void)searchModelGetFields:(XMPPSearchModule *)searchModul
{
    NSLog(@"Get fields : %@", searchModul.result);
}


-(IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
    /*
    NSString *name=txtSearch.text;
    name =[name stringByReplacingOccurrencesOfString:@"@" withString:@"-"];
    NSString *requestText=[NSString stringWithFormat:@"%@%@%@",@"已向",txtSearch.text,@"发出请求"];
    [theApp XMPPAddFriendSubscribe:name];
     */
    [theApp.xmppSearchModule addDelegate:self
                 delegateQueue:dispatch_get_main_queue()];
    //[theApp.xmppSearchModule askForFields];
    XMPPSearchSingleNode *search = [[XMPPSearchSingleNode alloc] init];
    search.name = @"nick";//@"NICKNAME";
    search.value = txtSearch.text;
    [theApp.xmppSearchModule searchWithFields:@[search]
                           userData:nil];
    
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
    [cell setFriendStatus:@"已添加"];
    
    return cell;
}

@end
