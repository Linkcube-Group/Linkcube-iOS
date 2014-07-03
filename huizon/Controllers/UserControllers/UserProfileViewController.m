//
//  UserProfileViewController.m
//  huizon
//
//  Created by meng on 3/17/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "UserProfileViewController.h"
#import "XMPPvCardTemp.h"
#import "XMPPvCardTempModule.h"
@interface UserProfileViewController ()

@end

@implementation UserProfileViewController
@synthesize  list=_list;
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
    // Do any additional setup after loading the view from its nib.
    NSMutableArray *array=[[NSMutableArray alloc]init];//[[NSArray alloc] initWithObjects:@"Test",@"Test2", nil];

    /*XMPPvCardTemp *myvCard=[theApp.xmppvCardTempModule myvCardTemp];
    NSLog(@"%@",myvCard.nickname);
    //[array addObject:myvCard.nickname];
    XMPPvCardTemp *test=[theApp.xmppvCardTempModule vCardTempForJID:[theApp.xmppStream myJID] shouldFetch:YES];
    NSLog(@"%@",test.role);
    XMPPvCardCoreDataStorage *xmppvCardStorage=[XMPPvCardCoreDataStorage sharedInstance];
    XMPPvCardTempModule *xmppvCardTempModule=[[XMPPvCardTempModule alloc]initWithvCardStorage:xmppvCardStorage];
    XMPPJID *jid=[theApp.xmppStream myJID];
    XMPPvCardTemp *xmppvCardTemp=[xmppvCardTempModule vCardTempForJID:jid shouldFetch:YES];
    NSLog(@"%@",xmppvCardTemp.role);*/
    XMPPvCardTemp *myvCard=[theApp.xmppvCardTempModule myvCardTemp];
    NSLog(@"%@",myvCard.nickname);
    if(myvCard.nickname)
        [array addObject:[[NSString alloc]initWithFormat:@"昵称:%@",myvCard.nickname]];
    if(myvCard.email)
        [array addObject:[[NSString alloc]initWithFormat:@"电子邮箱:%@",myvCard.email]];
    if(myvCard.gender)
        [array addObject:[[NSString alloc]initWithFormat:@"性别:%@",myvCard.gender]];
    //XMPPvCardTemp *test=[theApp.xmppvCardTempModule vCardTempForJID:[theApp.xmppStream myJID] shouldFetch:YES];
    //NSLog(@"%@",test.gender);
    //[array addObject:myvCard.nickname];
    /*
    XMPPIQ *iqUpdate=[XMPPIQ iqWithType:@"set"];
    [iqUpdate addAttributeWithName:@"from" stringValue:[[theApp.xmppStream myJID]bare]];
    NSXMLElement *vElementUpdate=[NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    [vElementUpdate addChild:[NSXMLNode elementWithName:@"nickname" stringValue:@"Peter"]];
    [iqUpdate addChild:vElementUpdate];
    [theApp.xmppStream sendElement:iqUpdate];
    
    
    XMPPIQ *iq=[XMPPIQ iqWithType:@"get"];
    [iq addAttributeWithName:@"from" stringValue:[[theApp.xmppStream myJID]bare]];
    NSXMLElement *vElement=[NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    [iq addChild:vElement];
    [theApp.xmppStream sendElement:iq];
    */
    self.list=array;
    self.navigationController.navigationBarHidden=NO;
    //[self.tableView reloadData];
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
    return [self.list count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSUInteger row=[indexPath row];
    cell.textLabel.text=[self.list objectAtIndex:row];
    return cell;
}

- (IBAction)UpdateInfo:(id)sender
{
    XMPPvCardTemp *myvCard=[theApp.xmppvCardTempModule myvCardTemp];
    //[theApp.xmppvCardTempModule updateMyvCardTemp:myvCard];
    [self.list removeAllObjects];
    if(myvCard.nickname)
        [self.list addObject:[[NSString alloc]initWithFormat:@"昵称:%@",myvCard.nickname]];
    if(myvCard.email)
        [self.list addObject:[[NSString alloc]initWithFormat:@"电子邮箱:%@",myvCard.email]];
    if(myvCard.gender)
        [self.list addObject:[[NSString alloc]initWithFormat:@"性别:%@",myvCard.gender]];
    [self.tableView reloadData];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
