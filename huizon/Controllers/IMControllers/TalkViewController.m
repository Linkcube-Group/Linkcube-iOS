	//
//  TalkViewController.m
//  huizon
//
//  Created by Yang on 14-3-3.
//  Modified by Meng on 14-3-17.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "TalkViewController.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "LeDiscovery.h"
@interface TalkViewController ()<ChatDelegate>
{
    
    IBOutlet UIBubbleTableView *bubbleTable;
    IBOutlet UIView *textInputView;
    IBOutlet UIView *gameView;
    IBOutlet UITextField *textField;
    IBOutlet UIImageView *imgGame;
    IBOutlet UIImageView *imgSend;
    IBOutlet UIImageView *imgShake;
    IBOutlet UIImageView *imgDecline;
    IBOutlet UIImageView *imgAccept;
    IBOutlet UILabel *lblDecline;
    IBOutlet UILabel *lblAccept;
    IBOutlet UILabel *lblPrompt;
    IBOutlet UIButton *btnHangUp;
    int secondsCountDown;
    NSTimer *countDownTimer;
    NSMutableArray *bubbleData;
    //bool isGameDisplayed;
    //0 no one displayed;1 keyboard;2 Game button;3 request interface
    int currentMode;
    bool isWaitingReply;
    
    XMPPMessageArchivingCoreDataStorage *storage;
    NSManagedObjectContext *moc;
    NSArray *arrayMessage;
}

@end

@implementation TalkViewController

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
    NSString *userName=self.xmppFriendNickname;
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:userName];
    self.navigationItem.leftBarButtonItem=[[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(btBack_DisModal:)];
    
    

}
-(void)viewDidAppear:(BOOL)animated
{
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        [self getMessageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self updateUI:arrayMessage];
        });
        
    });
}


- (AppDelegate *)appDelegate
{
    theApp.chatDelegate = self;
	return theApp;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isWaitingReply=NO;
    [btnHangUp setHidden:YES];
    storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    moc = [storage mainThreadManagedObjectContext];
    currentMode=0;
    //isGameDisplayed=NO;
    [imgGame setUserInteractionEnabled:YES];
    [imgGame addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickGame:)]];
    [imgSend setUserInteractionEnabled:YES];
    [imgSend addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickGame:)]];
    
    [imgShake setUserInteractionEnabled:YES];
    [imgShake addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickGame:)]];
    
    
    [imgDecline setUserInteractionEnabled:YES];
    [imgDecline addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickGame:)]];
    
    [imgAccept setUserInteractionEnabled:YES];
    [imgAccept addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickGame:)]];
    // Do any additional setup after loading the view from its nib.
    
    /*
    NSBubbleData *heyBubble = [NSBubbleData dataWithText:@"Hey, halloween is soon" date:[NSDate dateWithTimeIntervalSinceNow:-300] type:BubbleTypeSomeoneElse];
    heyBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
    
    NSBubbleData *photoBubble = [NSBubbleData dataWithImage:[UIImage imageNamed:@"halloween.jpg"] date:[NSDate dateWithTimeIntervalSinceNow:-290] type:BubbleTypeSomeoneElse];
    photoBubble.avatar = [UIImage imageNamed:@"avatar1.png"];
    
    NSBubbleData *replyBubble = [NSBubbleData dataWithText:@"Wow.. Really cool picture out there. iPhone 5 has really nice camera, yeah?" date:[NSDate dateWithTimeIntervalSinceNow:-5] type:BubbleTypeMine];
    replyBubble.avatar = nil;
    
    bubbleData = [[NSMutableArray alloc] initWithObjects:heyBubble, photoBubble, replyBubble, nil];
    */
    bubbleData=[[NSMutableArray alloc]init];
    [self appDelegate];
    //[self getMessageData];
    bubbleTable.bubbleDataSource = self;
    
    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.
    
    bubbleTable.snapInterval = 120;
    
    // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
    
    bubbleTable.showAvatars = YES;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNone - no "now typing" bubble
    
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    //[self getMessageData];
    //[bubbleTable reloadData];
    
    /*
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        [self getMessageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self updateUI:arrayMessage];
        });
        
    });
    */
    // Keyboard events
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendMessage:) name:kXMPPNotificationDidSendMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:KXMPPNotificationDidReceiveMessage object:nil];
    
    
    
    //NSMutableArray *array=[[NSMutableArray alloc]init];
    //self.messageList=array;
    //[self getMessageData];
    //NSLog(@"%d",bubbleData.count-1);
    
    //NSIndexPath *idxpath=[NSIndexPath indexPathForRow:0 inSection:[bubbleTable numberOfSections]-1];
    //[bubbleTable selectRowAtIndexPath:idxpath animated:YES scrollPosition:UITableViewScrollPositionBottom];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (currentMode>1)
    {
        [self hideGame];
    }
    currentMode=1;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y -= kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height -= kbSize.height;
        bubbleTable.frame = frame;
        [self gotoLastMessage:NO];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (currentMode>1)
    {
        [self displayGame:currentMode];
    }
    currentMode=0;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y += kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height += kbSize.height;
        bubbleTable.frame = frame;
    }];
}


-(void)displayGame:(int)mode
{
    currentMode=mode;
    int height=200;
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y -= height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height -= height;
        bubbleTable.frame = frame;
        if (mode==2)
        {
            imgShake.hidden=NO;
            imgAccept.hidden=YES;
            imgDecline.hidden=YES;
            lblAccept.hidden=YES;
            lblDecline.hidden=YES;
        }
        else if (mode==3)
        {
            
            imgShake.hidden=YES;
            imgAccept.hidden=NO;
            imgDecline.hidden=NO;
            lblAccept.hidden=NO;
            lblDecline.hidden=NO;
        }
        gameView.hidden=NO;
        [self gotoLastMessage:NO];
    }];
}
-(void)hideGame
{
    currentMode=0;
    int height=200;
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y += height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height += height;
        bubbleTable.frame = frame;
        gameView.hidden=YES;
    }];
}
#pragma mark message
- (void)didSendMessage:(NSNotification*)aNotification
{
    
    //[self getMessageData];
    //[bubbleTable reloadData];
    /*
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        [self getMessageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self updateUI:arrayMessage];
        });
        
    });*/
}
- (void)didReceiveMessage:(NSNotification*)aNotification
{
    //[self getMessageData];
    //[bubbleTable reloadData];
    /*
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        [self getMessageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI:arrayMessage];
        });
        
    });*/
}

#pragma mark - Actions

//not used
- (IBAction)initiateGame:(id)sender
{
    [textField resignFirstResponder];
    NSString *message=@"c:connectrequest";
    //生成消息对象
    //XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:@"test950" domain:kXMPPmyDomain resource:@"ios"]];
    XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:self.xmppFriendJID];
    [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:message]];
    //发送消息
    [theApp.xmppStream sendElement:mes];
    secondsCountDown=30;
    countDownTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    
}
-(void) timeFireMethod
{
    secondsCountDown--;
    NSString *timeLeft=[[NSString alloc] initWithFormat:@"请求已发送,请等待%ds",secondsCountDown ];
    //[theApp showAlertView:timeLeft];
    
    //textField.text=timeLeft;
    lblPrompt.text=timeLeft;
    if (secondsCountDown==0)
    {
        isWaitingReply=NO;
        lblPrompt.hidden=YES;
        [countDownTimer invalidate];
    }
}

// not used
- (IBAction)sayPressed:(id)sender
{
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    /*
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:textField.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    [bubbleData addObject:sayBubble];
    [bubbleTable reloadData];
    */
    //textField.text = @"";
    [textField resignFirstResponder];
    
    
    NSString *message=textField.text;
    //生成消息对象
    
    //XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:@"test950" domain:kXMPPmyDomain resource:@"ios"]];
    XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:self.xmppFriendJID];
    [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:message]];
    
    //发送消息
    [theApp.xmppStream sendElement:mes];
    //[self getMessageData];
    //[bubbleTable reloadData];
    textField.text=@"";


}

-(IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}


/*
- (IBAction)sendIt:(id)sender
{
    NSString *message=self.textMessage.text;
    //生成消息对象
    XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:@"test001" domain:kXMPPmyDomain resource:@"ios"]];
    [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:message]];
    
    //发送消息
    [theApp.xmppStream sendElement:mes];
    
    [self.textMessage setText:nil];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSUInteger row=[indexPath row];
    XMPPMessageArchiving_Message_CoreDataObject *message=[self.messageList objectAtIndex:row];
    cell.textLabel.text=message.body;
    cell.detailTextLabel.text=message.bareJidStr;
    return cell;
}
*/



-(void)clickGame:(UITapGestureRecognizer *)gestureRecognizer
{
    NSLog(@"click");
    NSLog(@"%hhd",[gestureRecognizer isMemberOfClass:[UITapGestureRecognizer class]]);
    
    UIView *viewClicked=[gestureRecognizer view];
    if (viewClicked==imgGame)
    {
        //NSLog(@"GameImage");
        
        if (currentMode==0)
        {
            [self displayGame:2];
        }
        else if (currentMode==1)
        {
            [textField resignFirstResponder];
            [self displayGame:2];
        }
        else if (currentMode>=2)
        {
            [self hideGame];
        }
        
        
    }
    else if(viewClicked==imgSend)
    {
        bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
        [textField resignFirstResponder];
        

        
        NSString *message=textField.text;
        NSString *messageBody=[self filterMessage:message];
        NSBubbleData *bb;
        bb=[NSBubbleData dataWithText:messageBody date:[NSDate date] type:BubbleTypeMine];
        bb.avatar=[UIImage imageNamed:@"portrait-female-small.png"];
        [bubbleData addObject:bb];
        [bubbleTable reloadData];
        [self gotoLastMessage:NO];
        //生成消息对象
         //XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:@"test950" domain:kXMPPmyDomain resource:@"ios"]];
        XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:self.xmppFriendJID];
        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:message]];
        //发送消息
        [theApp.xmppStream sendElement:mes];
        textField.text=@"";
    }
    else if(viewClicked==imgShake)
    {
        if (!isWaitingReply)
        {
            //[textField resignFirstResponder];
            NSString *message=@"c:connectrequest";
            NSString *messageBody=[self filterMessage:message];
            NSBubbleData *bb;
            bb=[NSBubbleData dataWithText:messageBody date:[NSDate date] type:BubbleTypeMine];
            bb.avatar=[UIImage imageNamed:@"portrait-female-small.png"];
            [bubbleData addObject:bb];
            [bubbleTable reloadData];
            [self gotoLastMessage:NO];

            
            
            //生成消息对象
            XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:self.xmppFriendJID];
            [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:message]];
            //发送消息
            [theApp.xmppStream sendElement:mes];
            secondsCountDown=30;
            lblPrompt.hidden=NO;
            isWaitingReply=YES;
            countDownTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
        }
    }
    else if(viewClicked==imgAccept)
    {
        NSString *message=@"c:acceptconnect";
        XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:self.xmppFriendJID];
        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:message]];
        [theApp.xmppStream sendElement:mes];
        [self hideGame];
        
        NSString *messageBody=[self filterMessage:message];
        NSBubbleData *bb;
        bb=[NSBubbleData dataWithText:messageBody date:[NSDate date] type:BubbleTypeMine];
        bb.avatar=[UIImage imageNamed:@"portrait-female-small.png"];
        [bubbleData addObject:bb];
        [bubbleTable reloadData];
        [self gotoLastMessage:NO];
        
        
        
        //to add game code here
        [theApp showAlertView:@"游戏连接已建立"];
        [countDownTimer invalidate];
        lblPrompt.text=@"游戏中";
        lblPrompt.hidden=NO;
        [btnHangUp setHidden:NO];
        theApp.currentGamingJid=self.xmppFriendJID;
        if (currentMode==0)
        {
            [self displayGame:3];
        }
        else if (currentMode==1)
        {
            [textField resignFirstResponder];
            [self displayGame:3];
        }
        else if (currentMode==2)
        {
            [self hideGame];
            [self displayGame:3];
        }
        imgShake.hidden=NO;
        imgAccept.hidden=YES;
        imgDecline.hidden=YES;
        lblAccept.hidden=YES;
        lblDecline.hidden=YES;
        
    }
    else if(viewClicked==imgDecline)
    {
        NSString *message=@"c:refuseconnect";
        XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:self.xmppFriendJID];
        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:message]];
        [theApp.xmppStream sendElement:mes];
        [self hideGame];
        
        NSString *messageBody=[self filterMessage:message];
        NSBubbleData *bb;
        bb=[NSBubbleData dataWithText:messageBody date:[NSDate date] type:BubbleTypeMine];
        bb.avatar=[UIImage imageNamed:@"portrait-female-small.png"];
        [bubbleData addObject:bb];
        [bubbleTable reloadData];
        [self gotoLastMessage:NO];
    }
    
}


-(NSString *)filterMessage:(NSString *)originMessage
{
    NSString *messageBody=originMessage;
    if ([messageBody isEqualToString:@"c:connectrequest"])
    {
        messageBody=@"已发起游戏邀请";
    }
    else if ([messageBody isEqualToString:@"c:refuseconnect"])
    {
        messageBody=@"拒绝游戏邀请";
    }
    else if ([messageBody isEqualToString:@"c:acceptconnect"])
    {
        messageBody=@"已接受游戏邀请";
    }
    else if ([messageBody isEqualToString:@"c:disconnect"])
    {
        messageBody=@"游戏已结束";
    }

    return messageBody;

}
-(void) updateUI:(NSArray *)data
{
    NSArray *messageArray=data;
    for (XMPPMessageArchiving_Message_CoreDataObject *message in messageArray)
    {
        NSBubbleData* bb;
        NSString *body=message.body;
        NSString *messageBody=[self filterMessage:body];
        if(message.isOutgoing)
        {
            bb=[NSBubbleData dataWithText:messageBody date:message.timestamp type:BubbleTypeMine];
            bb.avatar=[UIImage imageNamed:@"portrait-female-small.png"];
        }
        else
        {
            bb=[NSBubbleData dataWithText:messageBody date:message.timestamp type:BubbleTypeSomeoneElse];
            bb.avatar=[UIImage imageNamed:@"portrait-female-small.png"];
        }
        [bubbleData addObject:bb];

                /*
         NSLog(@"messageStr param is %@",message.messageStr);
         NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
         NSLog(@"to param is %@",[element attributeStringValueForName:@"to"]);
         NSLog(@"NSCore object id param is %@",message.objectID);
         NSLog(@"bareJid param is %@",message.bareJid);
         NSLog(@"bareJidStr param is %@",message.bareJidStr);
         NSLog(@"body param is %@",message.body);
         NSLog(@"timestamp param is %@",message.timestamp);
         NSLog(@"outgoing param is %d",[message.outgoing intValue]);
         */
    }
    [bubbleTable reloadData];
    [self gotoLastMessage:NO];


}
-(void) gotoLastMessage:(bool) animated
{
    
    int numSections=[bubbleTable numberOfSections];
    if (numSections>0)
    {
        int numRowInLastSection=[bubbleTable numberOfRowsInSection:numSections-1];
        NSIndexPath *idxpath=[NSIndexPath indexPathForRow:numRowInLastSection-1 inSection:numSections-1];
        [bubbleTable selectRowAtIndexPath:idxpath animated:animated scrollPosition:UITableViewScrollPositionBottom];
    }

    
}
-(void) getMessageData
{
    [bubbleData removeAllObjects];

    NSError *error=nil;
    [moc save:&error];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    NSString *bareJid=[theApp.xmppStream.myJID bare];
    NSString *messageFromBareJid=[self.xmppFriendJID bare];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"bareJidStr==%@ AND streamBareJidStr==%@",messageFromBareJid,bareJid];
    [request setEntity:entityDescription];
    [request setPredicate:predicate]; //查找条件
    
    arrayMessage=[moc executeFetchRequest:request error:&error]; //查找与当前用户聊天记录
    
    
    
    
}
- (void)receiveMessage:(XMPPMessage *)message
{
    //[theApp showAlertView:message.body];
    
    NSString *body=message.body;
    //control device of this phone
    if ([body length]>4&&[[body substringToIndex:4] isEqualToString:@"ctl:"])
    {
         [[LeDiscovery sharedInstance] sendCommand:[body substringFromIndex:4]];
    }
    
    NSString *messageBody=[self filterMessage:body];
    NSBubbleData *bb;
    bb=[NSBubbleData dataWithText:messageBody date:[NSDate date] type:BubbleTypeSomeoneElse];
    bb.avatar=[UIImage imageNamed:@"portrait-female-small.png"];
    [bubbleData addObject:bb];
    [bubbleTable reloadData];
    [self gotoLastMessage:NO];
    
    if ([body isEqualToString:@"c:connectrequest"])
    {
        if (currentMode==0)
        {
            [self displayGame:3];
        }
        else if (currentMode==1)
        {
            [textField resignFirstResponder];
            [self displayGame:3];
        }
        else if (currentMode==2)
        {
            [self hideGame];
            [self displayGame:3];
        }
        
        //UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"游戏邀请" message:@"对方发来游戏邀请" delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"接受", nil];
        //[alertView show];
    }
    else if ([body isEqualToString:@"c:acceptconnect"])
    {
        [theApp showAlertView:@"游戏连接已建立"];
        [countDownTimer invalidate];
        lblPrompt.text=@"游戏中";
        lblPrompt.hidden=NO;
        [btnHangUp setHidden:NO];
        theApp.currentGamingJid=self.xmppFriendJID;
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle=[alertView buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"接受"])
    {
        NSString *message=@"c:acceptconnect";
        //生成消息对象
        XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:self.xmppFriendJID];
        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:message]];
        //发送消息
        [theApp.xmppStream sendElement:mes];
        lblPrompt.text=@"游戏中";
        lblPrompt.hidden=NO;
        [btnHangUp setHidden:NO];
        theApp.currentGamingJid=self.xmppFriendJID;
    }
    else if([buttonTitle isEqualToString:@"拒绝"])
    {
        NSString *message=@"c:refuseconnect";
        //生成消息对象
        XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:self.xmppFriendJID];
        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:message]];
        //发送消息
        [theApp.xmppStream sendElement:mes];
    }
    
    
}


-(IBAction)hangUp:(id)sender
{
    NSString *message=@"c:disconnect";
    //生成消息对象
    XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:self.xmppFriendJID];
    [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:message]];
    //发送消息
    [theApp.xmppStream sendElement:mes];
    
    
    NSString *messageBody=[self filterMessage:message];
    NSBubbleData *bb;
    bb=[NSBubbleData dataWithText:messageBody date:[NSDate date] type:BubbleTypeMine];
    bb.avatar=[UIImage imageNamed:@"portrait-female-small.png"];
    [bubbleData addObject:bb];
    [bubbleTable reloadData];
    [self gotoLastMessage:NO];
    
    isWaitingReply=NO;
    lblPrompt.hidden=YES;
    showCustomAlertMessage(@"已挂断");
    [btnHangUp setHidden:YES];
    theApp.currentGamingJid = nil;
    
}

@end
