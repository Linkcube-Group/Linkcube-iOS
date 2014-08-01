//
//  ChatWithOtherViewController.m
//  huizon
//
//  Created by apple on 14-8-1.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "ChatWithOtherViewController.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
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
    UITextField *textField;
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
    #warning 没初始化
    //结束游戏按钮
    UIButton *btnHangUp;
    #warning 没初始化
    //倒计时的数
    int secondsCountDown;
    #warning 没初始化
    //计数器
    NSTimer *countDownTimer;
    #warning 没初始化
    //聊天内容数组
    NSMutableArray *bubbleData;
    #warning 没初始化
    //bool isGameDisplayed;
    //模式 0 no one displayed;1 keyboard;2 Game button;3 request interface
    int currentMode;
    #warning 没初始化
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
#warning 没写呢
}

-(AppDelegate *)appDelegate
{
    theApp.chatDelegate = self;
    return theApp;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //列表
    bubbleTable = [[UIBubbleTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    bubbleTable.bubbleDataSource = self;
    bubbleTable.snapInterval = 120;
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
    
    textField = [[UITextField alloc] init];
    textField.frame = CGRectMake(gameButton.frame.origin.x + gameButton.frame.size.width + 5, gameButton.frame.origin.y, self.view.frame.size.width - gameButton.frame.origin.x - gameButton.frame.size.width - 5 - 50, 40);
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.font = [UIFont systemFontOfSize:14.f];
    textField.delegate = self;
    textField.placeholder = NSLocalizedString(@"输入信息", nil);
    [textInputView addSubview:textField];
    
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(textField.frame.origin.x + textField.frame.size.width + 5, textField.frame.origin.y, self.view.frame.size.width - textField.frame.origin.x - textField.frame.size.width - 5 - 5, 40);
    sendButton.layer.cornerRadius = 10.f;
    sendButton.layer.borderWidth = 1.f;
    sendButton.layer.borderColor = [UIColor blueColor].CGColor;
    [sendButton setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithCGColor:sendButton.layer.borderColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    sendButton.enabled = NO;
    [textInputView addSubview:textInputView];
    
    //game的view
    gameView = [[UIView alloc] init];
    gameView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
    gameView.backgroundColor = [UIColor colorWithRed:230/255.f green:230/255.f blue:230/255.f alpha:1.f];
    gameView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:gameView];
    //发起游戏按钮
    askToGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    askToGameButton.frame = CGRectMake((gameView.frame.size.width - 88.f)/2.f, 10, 88.f, 88.f);
    [askToGameButton setBackgroundColor:[UIColor redColor]];
    [askToGameButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [askToGameButton setImage:[UIImage imageNamed:@""] forState:UIControlStateDisabled];
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
    [declineButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
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
    [acceptButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    acceptButton.layer.cornerRadius = 44.f;
    acceptButton.hidden = declineButton.hidden;
    [acceptButton setTitle:NSLocalizedString(@"同意", nil) forState:UIControlStateNormal];
    [acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [acceptButton addTarget:self action:@selector(acceptButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [gameView addSubview:acceptButton];
    //游戏种类
    gameKindScrollView = [[UIScrollView alloc] init];
    gameKindScrollView.frame = CGRectMake((gameView.frame.size.width - 166.f)/2.f, 10, 166.f, 166.f);
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
    shakeImageView.image = [UIImage imageNamed:@""];
    [gameKindScrollView addSubview:shakeImageView];
    //经典7式
    UIImageView *
    
    isWaitingReply = NO;
#warning 没初始化呢
    [btnHangUp setHidden:YES];
    storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    moc = [storage mainThreadManagedObjectContext];
    currentMode = 0;
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
//拒绝按钮
-(void)declineButtonClick
{
#warning declineButtonClick
    NSLog(@"!!!!declineButtonClick!!!!");
}

//同意那妞
-(void)acceptButtonClicked
{
#warning acceptButtonClicked
    NSLog(@"!!!!acceptButtonClicked!!!!");
}

//申请游戏
-(void)applyGame
{
#warning applyGame
    NSLog(@"!!!!applyGame!!!!");
}

//游戏按钮
-(void)gameButtonClicked
{
#warning gameButtonClicked
    NSLog(@"!!!!gameButtonClicked!!!!");
}

//发送按钮
-(void)sendButtonClicked
{
#warning sendButtonClicked
    NSLog(@"!!!!sendButtonClicked!!!!");
    [textField resignFirstResponder];
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
