//
//  ChatWithOtherViewController.m
//  huizon
//
//  Created by apple on 14-8-1.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "ChatWithOtherViewController.h"
#import "UIBubbleTableView.h"
#import "NSBubbleData.h"
#import "LeDiscovery.h"

@interface ChatWithOtherViewController ()<ChatDelegate,UITextFieldDelegate>

@end

@implementation ChatWithOtherViewController
{
    //tableview
    UIBubbleTableView *bubbleTable;
    //输入的整个view
    UIView *textInputView;
    //游戏键盘的view
    UIView *gameView;
    //输入框
    UITextField *inputTextField;
    //申请游戏的那个按钮
    UIButton *gameButton;
    //要改成发送按钮
    UIButton *sendButton;
    //发起游戏按钮
    UIButton * askToGameButton;
    //游戏种类的scollView
    UIScrollView * gameKindScrollView;
    //拒绝
    UIButton *declineButton;
    //接收
    UIButton *acceptButton;
    //提示
    UILabel *lblPrompt;
    //结束游戏按钮
    UIButton *btnHangUp;
    //倒计时的数
    int secondsCountDown;
    //计数器
    NSTimer *countDownTimer;
    //聊天内容数组
    NSMutableArray *bubbleData;
    //bool isGameDisplayed;
    //模式 0 no one displayed;1 keyboard;2 Game button;3 request interface
    int currentMode;
    //等待答复
    bool isWaitingReply;
    
    XMPPMessageArchivingCoreDataStorage *storage;
    NSManagedObjectContext *moc;
    //message数组
    NSArray *arrayMessage;
}
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
    //标题
    NSString * userName = self.xmppFriendNickname;
    self.navigationItem.titleView = [[Theam currentTheam] navigationTitleViewWithTitle:userName];
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(btBack_DisModal:)];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        [self getMessageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self updateUI:arrayMessage];
        });
        
    });
}

-(AppDelegate *)appDelegate
{
    theApp.chatDelegate = self;
    return theApp;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isWaitingReply = NO;
    storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    moc = [storage mainThreadManagedObjectContext];
    currentMode = 0;
    
    //列表
    bubbleTable = [[UIBubbleTableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44 - 50) style:UITableViewStylePlain];
    //代理
    bubbleTable.bubbleDataSource = self;
    //120秒没有人发言就加入时间
    bubbleTable.snapInterval = 120;
    //显示头像
    bubbleTable.showAvatars = YES;
    bubbleTable.backgroundColor = [UIColor colorWithRed:230/255.f green:230/255.f blue:230/255.f alpha:1.f];
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    [self.view addSubview:bubbleTable];
    
    //键盘上方输入控制view
    textInputView = [[UIView alloc] init];
    textInputView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50, [UIScreen mainScreen].bounds.size.width, 50);
    textInputView.backgroundColor = [UIColor colorWithRed:204/255.f green:204/255.f blue:204/255.f alpha:1.f];
    textInputView.userInteractionEnabled = YES;
    [self.view addSubview:textInputView];
    
    gameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    gameButton.frame = CGRectMake(5, 5, 40, 40);
    [gameButton setImage:[UIImage imageNamed:@"button-connect.png"] forState:UIControlStateNormal];
    [gameButton setImage:[UIImage imageNamed:@"button-connect-pressed.png"] forState:UIControlStateSelected];
    [gameButton addTarget:self action:@selector(gameButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [textInputView addSubview:gameButton];
    
    inputTextField = [[UITextField alloc] init];
    inputTextField.frame = CGRectMake(gameButton.frame.origin.x + gameButton.frame.size.width + 5, gameButton.frame.origin.y, self.view.frame.size.width - gameButton.frame.origin.x - gameButton.frame.size.width - 5 - 50, 40);
    inputTextField.borderStyle = UITextBorderStyleRoundedRect;
    inputTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    inputTextField.font = [UIFont systemFontOfSize:14.f];
    inputTextField.delegate = self;
    inputTextField.placeholder = NSLocalizedString(@"输入信息", nil);
    [textInputView addSubview:inputTextField];
    
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(inputTextField.frame.origin.x + inputTextField.frame.size.width + 5, inputTextField.frame.origin.y, self.view.frame.size.width - inputTextField.frame.origin.x - inputTextField.frame.size.width - 5 - 5, 40);
    sendButton.layer.cornerRadius = 10.f;
    sendButton.layer.borderWidth = 1.f;
    sendButton.layer.borderColor = [UIColor blueColor].CGColor;
    [sendButton setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithCGColor:sendButton.layer.borderColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    sendButton.enabled = NO;
    [textInputView addSubview:sendButton];
    
    //game的view
    gameView = [[UIView alloc] init];
    gameView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
    gameView.backgroundColor = [UIColor colorWithRed:230/255.f green:230/255.f blue:230/255.f alpha:1.f];
    [self.view addSubview:gameView];
    //发起游戏按钮
    askToGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    askToGameButton.frame = CGRectMake((gameView.frame.size.width - 88.f)/2.f, 10, 88.f, 88.f);
    [askToGameButton setBackgroundColor:[UIColor redColor]];
    [askToGameButton setImage:[UIImage imageNamed:@"button-circle-red.png"] forState:UIControlStateNormal];
    [askToGameButton setImage:[UIImage imageNamed:@"button-circle-grey.png"] forState:UIControlStateDisabled];
    [askToGameButton setTitle:isWaitingReply?NSLocalizedString(@"等待答复", nil):NSLocalizedString(@"发起游戏", nil) forState:UIControlStateNormal];
    [askToGameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [askToGameButton addTarget:self action:@selector(applyGame) forControlEvents:UIControlEventTouchUpInside];
    askToGameButton.layer.cornerRadius = 44.f;
    askToGameButton.enabled = YES;
    askToGameButton.hidden = NO;
    [gameView addSubview:askToGameButton];
    //提示信息
    lblPrompt = [[UILabel alloc] init];
    lblPrompt.frame = CGRectMake(0, askToGameButton.frame.origin.y + askToGameButton.frame.size.height, self.view.frame.size.width, 20);
    lblPrompt.backgroundColor = [UIColor clearColor];
    lblPrompt.textAlignment = NSTextAlignmentCenter;
    lblPrompt.font = [UIFont systemFontOfSize:14.f];
    lblPrompt.textColor = [UIColor blackColor];
    lblPrompt.hidden = YES;
    [gameView addSubview:lblPrompt];
    //拒绝按钮
    declineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    declineButton.frame = CGRectMake((gameView.frame.size.width - 88.f*2)/3.f, 10, 88.f, 88.f);
    [declineButton setBackgroundColor:[UIColor redColor]];
    [declineButton setImage:[UIImage imageNamed:@"button-circle-red.png"] forState:UIControlStateNormal];
    declineButton.layer.cornerRadius = 44.f;
    declineButton.hidden = YES;
    [declineButton setTitle:NSLocalizedString(@"拒绝", nil) forState:UIControlStateNormal];
    [declineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [declineButton addTarget:self action:@selector(declineButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [gameView addSubview:declineButton];
    //同意按钮
    acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    acceptButton.frame = CGRectMake(declineButton.frame.origin.x + declineButton.frame.size.width + (gameView.frame.size.width - 88.f*2)/3.f, declineButton.frame.origin.y, 88.f, 88.f);
    [acceptButton setBackgroundColor:[UIColor greenColor]];
    [acceptButton setImage:[UIImage imageNamed:@"button-circle-green.png"] forState:UIControlStateNormal];
    acceptButton.layer.cornerRadius = 44.f;
    acceptButton.hidden = declineButton.hidden;
    [acceptButton setTitle:NSLocalizedString(@"同意", nil) forState:UIControlStateNormal];
    [acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [acceptButton addTarget:self action:@selector(acceptButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [gameView addSubview:acceptButton];
    //游戏种类
    gameKindScrollView = [[UIScrollView alloc] init];
    gameKindScrollView.frame = CGRectMake((gameView.frame.size.width - 166.f)/2.f, 10, 166.f, 166.f);
    gameKindScrollView.userInteractionEnabled = YES;
    gameKindScrollView.contentSize = CGSizeMake(166.f * 2, 166.f);
    gameKindScrollView.pagingEnabled = YES;
    gameKindScrollView.bounces = NO;
    gameKindScrollView.backgroundColor = [UIColor clearColor];
    gameKindScrollView.showsHorizontalScrollIndicator = NO;
    gameKindScrollView.showsVerticalScrollIndicator = NO;
    gameKindScrollView.hidden = YES;
    [gameView addSubview:gameKindScrollView];
    //摇一摇
    UIImageView * shakeImageView = [[UIImageView alloc] init];
    shakeImageView.frame = CGRectMake(0, 0, 166.f, 166.f);
    shakeImageView.hidden = YES;
    shakeImageView.image = [UIImage imageNamed:@"mode_shake.png"];
    [gameKindScrollView addSubview:shakeImageView];
    //经典7式
    UIButton * sevenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sevenButton.frame = CGRectMake(166.f, 0, 166.f, 166.f);
    sevenButton.layer.cornerRadius = 83.f;
    sevenButton.hidden = YES;
    sevenButton.layer.masksToBounds = YES;
    [sevenButton setImage:[UIImage imageNamed:@"posture_0.png"] forState:UIControlStateNormal];
    [sevenButton addTarget:self action:@selector(sevenButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [gameKindScrollView addSubview:sevenButton];
    
    //结束游戏按钮
    btnHangUp = [UIButton buttonWithType:UIButtonTypeCustom];
    btnHangUp.frame = CGRectMake(gameView.frame.size.width - 60, gameView.frame.size.height - 40, 50, 30);
    btnHangUp.hidden = YES;
    [btnHangUp setTitle:NSLocalizedString(@"结束游戏", nil) forState:UIControlStateNormal];
    [btnHangUp addTarget:self action:@selector(hangUpButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [gameView addSubview:btnHangUp];
    
    //几个通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendMessage:) name:kXMPPNotificationDidSendMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:KXMPPNotificationDidReceiveMessage object:nil];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.text.length)
    {
        sendButton.enabled = YES;
    }
    else
    {
        sendButton.enabled = NO;
    }
    return YES;
}

#pragma mark - UIBubbleTableViewDataSource implementation

//多少行
- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

//每行数据
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
            gameKindScrollView.hidden=NO;
            acceptButton.hidden=YES;
            declineButton.hidden=YES;
        }
        else if (mode==3)
        {
            gameKindScrollView.hidden=YES;
            acceptButton.hidden=NO;
            declineButton.hidden=NO;
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


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
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
            [inputTextField resignFirstResponder];
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

//结束游戏按钮
-(void)hangUpButtonClicked
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

//经典7式按钮
-(void)sevenButtonClicked
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

//拒绝按钮
-(void)declineButtonClick
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

//同意那妞
-(void)acceptButtonClicked
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
        [inputTextField resignFirstResponder];
        [self displayGame:3];
    }
    else if (currentMode==2)
    {
        [self hideGame];
        [self displayGame:3];
    }
    gameKindScrollView.hidden=NO;
    acceptButton.hidden=YES;
    declineButton.hidden=YES;
}

//申请游戏
-(void)applyGame
{
    if (currentMode==0)
    {
        [self displayGame:2];
    }
    else if (currentMode==1)
    {
        [inputTextField resignFirstResponder];
        [self displayGame:2];
    }
    else if (currentMode>=2)
    {
        [self hideGame];
    }
}

//游戏按钮
-(void)gameButtonClicked
{
    if (currentMode==0)
    {
        [self displayGame:2];
    }
    else if (currentMode==1)
    {
        [inputTextField resignFirstResponder];
        [self displayGame:2];
    }
    else if (currentMode>=2)
    {
        [self hideGame];
    }
}

//发送按钮
-(void)sendButtonClicked
{
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    [inputTextField resignFirstResponder];
    
    
    
    NSString *message=inputTextField.text;
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
    inputTextField.text=@"";
//    [inputTextField resignFirstResponder];
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
