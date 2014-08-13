//
//  ChatWithOtherViewController.m
//  huizon
//
//  Created by apple on 14-8-1.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "ChatWithOtherViewController.h"
#import "UIBubbleTableViewDataSource.h"
#import "UIBubbleTableView.h"
#import "NSBubbleData.h"
#import "LeDiscovery.h"
#import "XmppVcardTemp.h"
#import "XMPPvCardTempModule.h"
#import "ChatViewManager.h"
#import "FileManager.h"

/*
 聊天界面有点问题哈：1）发送按钮改成类似于iphone短信的那个发送吧（颜色为深灰色，字体大一些）；2）现在对话框是根据发出文字长度，直接拉伸的（这样小三角和圆角就变形了），应该只拉伸圆角矩形的长边或短边。文字框和头像应该平行对齐。3）会有一个白底（见上方截图）；4）在聊天界面收不到对方的消息，必须返回到上一层界面，再返回聊天界面，才能看到新消息；
 嗯，还有就是，被对话者，最上方中间没显示对方名称（如截图）。发起对话的人有显示对方名称。
 */
@interface ChatWithOtherViewController ()<ChatDelegate,UITextFieldDelegate>

@end

@implementation ChatWithOtherViewController
{
    //tableview
    UIBubbleTableView *bubbleTable;
    
    ///////////////////////////////////////////////////////
    
    //输入的整个view 上面添加游戏按钮，输入框，发送按钮
    UIView *textInputView;
    //输入框
    UITextField *inputTextField;
    //申请游戏的那个按钮
    UIButton *gameButton;
    //发送按钮
    UIButton *sendButton;
    
    ///////////////////////////////////////////////////////
    
    //发起游戏的按钮的键盘
    UIView *applyKeyboardView;
    //发起游戏按钮等待游戏按钮
    UIButton * askToGameButton;
    //提示
    UILabel *lblPrompt;
    
    ///////////////////////////////////////////////////////
    
    //拒绝接受按钮键盘
    UIView *yesNoKeyboardView;
    //拒绝
    UIButton *declineButton;
    //接收
    UIButton *acceptButton;
    
    ///////////////////////////////////////////////////////
    
    //游戏种类键盘
    UIView *gameKindKeyboardView;
    //游戏种类的scollView
    UIScrollView * gameKindScrollView;
    //经典七式按钮
    UIButton * sevenButton;
    
    ///////////////////////////////////////////////////////
    
    //结束游戏按钮
    UIButton *btnHangUp;
    //倒计时的数
    int secondsCountDown;
    //计数器
    NSTimer *countDownTimer;
    //聊天内容数组
    NSMutableArray *bubbleData;
    //message数组
    NSArray *arrayMessage;
    
    //模式 0 no one displayed;1 keyboard;2 Game button;3 request interface
    
    XMPPMessageArchivingCoreDataStorage *storage;
    NSManagedObjectContext *moc;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self clearMessageCount];
    }
    return self;
}

#pragma mark
#pragma mark - 获取双方头像

-(void)getAvatar
{
    
    if(theApp.xmppvCardUser.photo.length)
    {
        [ChatViewManager defaultManager].avatarOfMe = [[UIImage alloc] initWithData:theApp.xmppvCardUser.photo];
    }
    else if([theApp.xmppvCardUser.gender isEqualToString:@"男"])
    {
        [ChatViewManager defaultManager].avatarOfMe = [UIImage imageNamed:@"portrait-male-small.png"];
    }
    else
    {
        [ChatViewManager defaultManager].avatarOfMe = [UIImage imageNamed:@"portrait-female-small.png"];
    }
    XMPPvCardTemp * vCardTemp = [theApp.xmppvCardTempModule vCardTempForJID:self.xmppFriendJID shouldFetch:YES];
    if(vCardTemp.photo.length)
    {
        [ChatViewManager defaultManager].avatarOfOther = [[UIImage alloc] initWithData:vCardTemp.photo];
    }
    else if([vCardTemp.gender isEqualToString:@"男"])
    {
        [ChatViewManager defaultManager].avatarOfOther = [UIImage imageNamed:@"portrait-male-small.png"];
    }
    else
    {
        [ChatViewManager defaultManager].avatarOfOther = [UIImage imageNamed:@"portrait-female-small.png"];
    }
    self.navigationItem.titleView = [[Theam currentTheam] navigationTitleViewWithTitle:vCardTemp.nickname];
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
    [self clearMessageCount];
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        //获取消息记录
        [self getMessageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新UI
            [self updateUI:arrayMessage];
        });
        
    });
}

//获得代理
-(AppDelegate *)appDelegate
{
    theApp.chatDelegate = self;
    return theApp;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [ChatViewManager defaultManager];
    [[ChatViewManager defaultManager] clearData];
    //获取头像
    [self getAvatar];
    bubbleData = [[NSMutableArray alloc] init];
    storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    moc = [storage mainThreadManagedObjectContext];
    //不弹出任何键盘
    [ChatViewManager defaultManager].chatKeyboardType = chatKeyboardTypeNormal;
    //输入文字
    [ChatViewManager defaultManager].inputTextViewType = inputTextViewTypeText;
    //不是等待游戏中
    [ChatViewManager defaultManager].isWaitingReply = NO;
    //不在游戏中
    [ChatViewManager defaultManager].isGamePlaying = NO;
    
    //列表tableView
    bubbleTable = [[UIBubbleTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50) style:UITableViewStylePlain];
    //代理
    bubbleTable.bubbleDataSource = self;
    //120秒没有人发言就加入时间
    bubbleTable.snapInterval = 120;
    //显示头像
    bubbleTable.showAvatars = YES;
    bubbleTable.backgroundColor = [UIColor colorWithRed:230/255.f green:230/255.f blue:230/255.f alpha:1.f];
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    [self.view addSubview:bubbleTable];
    
    //////////////////////////////////////////////////////////////////////////////////////////
    
    //键盘上方输入控制view
    textInputView = [[UIView alloc] init];
    textInputView.frame = CGRectMake(0, self.view.frame.size.height - 50, [UIScreen mainScreen].bounds.size.width, 50);
    textInputView.backgroundColor = [UIColor colorWithRed:204/255.f green:204/255.f blue:204/255.f alpha:1.f];
    textInputView.userInteractionEnabled = YES;
    [self.view addSubview:textInputView];
    
    gameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    gameButton.frame = CGRectMake(5, 5, 40, 40);
    [gameButton setImage:[UIImage imageNamed:@"button-connect.png"] forState:UIControlStateNormal];
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
    
    sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.frame = CGRectMake(inputTextField.frame.origin.x + inputTextField.frame.size.width + 5, inputTextField.frame.origin.y + 5, self.view.frame.size.width - inputTextField.frame.origin.x - inputTextField.frame.size.width - 5 - 5, 30);
    [sendButton setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:19];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    sendButton.enabled = YES;
    [textInputView addSubview:sendButton];
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //申请游戏按钮的键盘
    applyKeyboardView  = [[UIView alloc] init];
    //先放在屏幕的外面
    applyKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
    applyKeyboardView.backgroundColor = [UIColor colorWithRed:230/255.f green:230/255.f blue:230/255.f alpha:1.f];
    applyKeyboardView.userInteractionEnabled = YES;
    [self.view addSubview:applyKeyboardView];
    
    //发起游戏按钮
    askToGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    askToGameButton.frame = CGRectMake((applyKeyboardView.frame.size.width - 88.f)/2.f, 40, 88.f, 88.f);
    [askToGameButton setBackgroundColor:[UIColor redColor]];
//    [askToGameButton setImage:[UIImage imageNamed:@"button-circle-red.png"] forState:UIControlStateNormal];
//    [askToGameButton setImage:[UIImage imageNamed:@"button-circle-grey.png"] forState:UIControlStateDisabled];
    [askToGameButton setBackgroundImage:[UIImage imageNamed:@"button-circle-red.png"] forState:UIControlStateNormal];
    [askToGameButton setBackgroundImage:[UIImage imageNamed:@"button-circle-grey.png"] forState:UIControlStateDisabled];
    [askToGameButton setTitle:NSLocalizedString(@"发起游戏", nil) forState:UIControlStateNormal];
    [askToGameButton setTitle:NSLocalizedString(@"等待答复", nil) forState:UIControlStateDisabled];
    [askToGameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [askToGameButton addTarget:self action:@selector(applyGame) forControlEvents:UIControlEventTouchUpInside];
    askToGameButton.layer.cornerRadius = 44.f;
    askToGameButton.enabled = YES;
    [applyKeyboardView addSubview:askToGameButton];
    
    //提示信息
    lblPrompt = [[UILabel alloc] init];
    lblPrompt.frame = CGRectMake(0, askToGameButton.frame.origin.y + askToGameButton.frame.size.height, self.view.frame.size.width, 20);
    lblPrompt.backgroundColor = [UIColor clearColor];
    lblPrompt.textAlignment = NSTextAlignmentCenter;
    lblPrompt.font = [UIFont systemFontOfSize:14.f];
    lblPrompt.textColor = [UIColor blackColor];
    lblPrompt.hidden = YES;
    [applyKeyboardView addSubview:lblPrompt];
    
    //////////////////////////////////////////////////////////////////////////////////////////
    
    //拒绝还是同意的按钮键盘
    yesNoKeyboardView  = [[UIView alloc] init];
    //先放在屏幕的外面
    yesNoKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
    yesNoKeyboardView.backgroundColor = [UIColor colorWithRed:230/255.f green:230/255.f blue:230/255.f alpha:1.f];
    yesNoKeyboardView.userInteractionEnabled = YES;
    [self.view addSubview:yesNoKeyboardView];
    
    //拒绝按钮
    declineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    declineButton.frame = CGRectMake((yesNoKeyboardView.frame.size.width - 88.f*2)/3.f, 10, 88.f, 88.f);
    [declineButton setBackgroundColor:[UIColor redColor]];
    [declineButton setImage:[UIImage imageNamed:@"button-circle-red.png"] forState:UIControlStateNormal];
    declineButton.layer.cornerRadius = 44.f;
    [declineButton setTitle:NSLocalizedString(@"拒绝", nil) forState:UIControlStateNormal];
    [declineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [declineButton addTarget:self action:@selector(declineButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [yesNoKeyboardView addSubview:declineButton];
    //同意按钮
    acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    acceptButton.frame = CGRectMake(declineButton.frame.origin.x + declineButton.frame.size.width + (yesNoKeyboardView.frame.size.width - 88.f*2)/3.f, declineButton.frame.origin.y, 88.f, 88.f);
    [acceptButton setBackgroundColor:[UIColor greenColor]];
    [acceptButton setImage:[UIImage imageNamed:@"button-circle-green.png"] forState:UIControlStateNormal];
    acceptButton.layer.cornerRadius = 44.f;
    [acceptButton setTitle:NSLocalizedString(@"同意", nil) forState:UIControlStateNormal];
    [acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [acceptButton addTarget:self action:@selector(acceptButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [yesNoKeyboardView addSubview:acceptButton];
    
    //////////////////////////////////////////////////////////////////////////////////////////
    
    //游戏种类键盘
    gameKindKeyboardView  = [[UIView alloc] init];
    //先放在屏幕的外面
    gameKindKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
    gameKindKeyboardView.backgroundColor = [UIColor colorWithRed:230/255.f green:230/255.f blue:230/255.f alpha:1.f];
    gameKindKeyboardView.userInteractionEnabled = YES;
    [self.view addSubview:gameKindKeyboardView];
    
    //游戏种类
    gameKindScrollView = [[UIScrollView alloc] init];
    gameKindScrollView.frame = CGRectMake((gameKindKeyboardView.frame.size.width - 166.f)/2.f, 10, 166.f, 166.f);
    gameKindScrollView.userInteractionEnabled = YES;
    gameKindScrollView.contentSize = CGSizeMake(166.f * 2, 166.f);
    gameKindScrollView.pagingEnabled = YES;
    gameKindScrollView.bounces = NO;
    gameKindScrollView.backgroundColor = [UIColor clearColor];
    gameKindScrollView.showsHorizontalScrollIndicator = NO;
    gameKindScrollView.showsVerticalScrollIndicator = NO;
    [gameKindKeyboardView addSubview:gameKindScrollView];
    
    //摇一摇
    UIImageView * shakeImageView = [[UIImageView alloc] init];
    shakeImageView.frame = CGRectMake(0, 0, 166.f, 166.f);
    shakeImageView.image = [UIImage imageNamed:@"mode_shake.png"];
    [gameKindScrollView addSubview:shakeImageView];
    
    //经典7式
    sevenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sevenButton.frame = CGRectMake(166.f, 0, 166.f, 166.f);
    sevenButton.layer.cornerRadius = 83.f;
    sevenButton.layer.masksToBounds = YES;
    [sevenButton setImage:[UIImage imageNamed:@"posture_0.png"] forState:UIControlStateNormal];
    [sevenButton addTarget:self action:@selector(sevenButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [gameKindScrollView addSubview:sevenButton];
    
    //////////////////////////////////////////////////////////////////////////////////////////
    
    //结束游戏按钮
    btnHangUp = [UIButton buttonWithType:UIButtonTypeCustom];
    btnHangUp.frame = CGRectMake(self.view.frame.size.width - 60, 7, 50, 30);
    btnHangUp.hidden = YES;
    [btnHangUp setTitle:NSLocalizedString(@"结束游戏", nil) forState:UIControlStateNormal];
    [btnHangUp addTarget:self action:@selector(hangUpButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnHangUp];
    
    //////////////////////////////////////////////////////////////////////////////////////////
    
    //几个通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendMessage:) name:kXMPPNotificationDidSendMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:KXMPPNotificationDidReceiveMessage object:nil];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
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
    [ChatViewManager defaultManager].chatKeyboardType = chatKeyboardTypeKeyboard;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.2f animations:^{

        CGRect frame = textInputView.frame;
        frame.origin.y = self.view.frame.size.height - kbSize.height - 50;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height = self.view.frame.size.height - kbSize.height - 50;
        bubbleTable.frame = frame;
        [self gotoLastMessage:NO];
        
        applyKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
        yesNoKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
        gameKindKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);


    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    switch ([ChatViewManager defaultManager].chatKeyboardType) {
        case chatKeyboardTypeApply:
        {
            //申请游戏
            [UIView animateWithDuration:0.2 animations:^{
                applyKeyboardView.frame = CGRectMake(0, self.view.frame.size.height - 216, self.view.frame.size.width, 216.f);
                yesNoKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                gameKindKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                bubbleTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50 - 216);
                textInputView.frame = CGRectMake(0, self.view.frame.size.height - 50 - 216, self.view.frame.size.width, 50);
            }];
        }
        break;
        case chatKeyboardTypeYesNo:
        {
            //同意还是拒绝按钮
            [UIView animateWithDuration:0.2 animations:^{
                applyKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                yesNoKeyboardView.frame = CGRectMake(0, self.view.frame.size.height - 216, self.view.frame.size.width, 216.f);
                gameKindKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                bubbleTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50 - 216);
                textInputView.frame = CGRectMake(0, self.view.frame.size.height - 50 - 216, self.view.frame.size.width, 50);
            }];
        }
        break;
        case chatKeyboardTypeGameKind:
        {
            //游戏种类
            [UIView animateWithDuration:0.2 animations:^{
                applyKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                yesNoKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                gameKindKeyboardView.frame = CGRectMake(0, self.view.frame.size.height - 216, self.view.frame.size.width, 216.f);
                bubbleTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50 - 216);
                textInputView.frame = CGRectMake(0, self.view.frame.size.height - 50 - 216, self.view.frame.size.width, 50);
            }];
        }
        break;
        default:
        {
            [UIView animateWithDuration:0.2 animations:^{
                applyKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                yesNoKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                gameKindKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                textInputView.frame = CGRectMake(0, self.view.frame.size.height - 50, [UIScreen mainScreen].bounds.size.width, 50);
                bubbleTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50);
                textInputView.frame = CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50);
            }];
        }
            break;
    }
    [self gotoLastMessage:NO];
}

-(void)displayGame:(ChatKeyboardType)mode
{
    switch ([ChatViewManager defaultManager].chatKeyboardType) {
        case chatKeyboardTypeApply:
        {
            //申请游戏
            [UIView animateWithDuration:0.2 animations:^{
                applyKeyboardView.frame = CGRectMake(0, self.view.frame.size.height - 216, self.view.frame.size.width, 216.f);
                yesNoKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                gameKindKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                bubbleTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50 - 216);
                textInputView.frame = CGRectMake(0, self.view.frame.size.height - 50 - 216, self.view.frame.size.width, 50);
            }];
        }
            break;
        case chatKeyboardTypeYesNo:
        {
            //同意还是拒绝按钮
            [UIView animateWithDuration:0.2 animations:^{
                applyKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                yesNoKeyboardView.frame = CGRectMake(0, self.view.frame.size.height - 216, self.view.frame.size.width, 216.f);
                gameKindKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                bubbleTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50 - 216);
                textInputView.frame = CGRectMake(0, self.view.frame.size.height - 50 - 216, self.view.frame.size.width, 50);
            }];
        }
            break;
        case chatKeyboardTypeGameKind:
        {
            //游戏种类
            [UIView animateWithDuration:0.2 animations:^{
                applyKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                yesNoKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                gameKindKeyboardView.frame = CGRectMake(0, self.view.frame.size.height - 216, self.view.frame.size.width, 216.f);
                bubbleTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50 - 216);
                textInputView.frame = CGRectMake(0, self.view.frame.size.height - 50 - 216, self.view.frame.size.width, 50);
            }];
        }
            break;
        default:
        {
            //申请游戏
            [UIView animateWithDuration:0.2 animations:^{
                applyKeyboardView.frame = CGRectMake(0, self.view.frame.size.height - 216, self.view.frame.size.width, 216.f);
                yesNoKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                gameKindKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
                bubbleTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50 - 216);
                textInputView.frame = CGRectMake(0, self.view.frame.size.height - 50 - 216, self.view.frame.size.width, 50);
            }];
        }
            break;
    }
    [self gotoLastMessage:NO];
}


-(void)hideGame
{
    [ChatViewManager defaultManager].chatKeyboardType = chatKeyboardTypeNormal;
    [UIView animateWithDuration:0.2f animations:^{
        
        applyKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
        yesNoKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
        gameKindKeyboardView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216.f);
        textInputView.frame = CGRectMake(0, self.view.frame.size.height - 50, [UIScreen mainScreen].bounds.size.width, 50);
        bubbleTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50);
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
    [self getMessageData];
    [bubbleTable reloadData];
    
     dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     dispatch_async(concurrentQueue, ^{
     
     [self getMessageData];
     dispatch_async(dispatch_get_main_queue(), ^{
     [self updateUI:arrayMessage];
     });
     
     });
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
        [ChatViewManager defaultManager].isWaitingReply = NO;
        lblPrompt.hidden=YES;
        askToGameButton.enabled = YES;
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
            bb.avatar = [ChatViewManager defaultManager].avatarOfMe;
        }
        else
        {
            bb=[NSBubbleData dataWithText:messageBody date:message.timestamp type:BubbleTypeSomeoneElse];
            bb.avatar = [ChatViewManager defaultManager].avatarOfOther;
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
-(void)clearMessageCount
{
    NSMutableDictionary * dict = [FileManager loadObject:XMPP_RECEIVE_MESSAGE_COUNT];
    [dict setObject:@"0" forKey:[NSString stringWithFormat:@"%@",self.xmppFriendJID]];
    [FileManager saveObject:dict filePath:XMPP_RECEIVE_MESSAGE_COUNT];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clearMessageCount" object:nil];
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
    bb.avatar=[ChatViewManager defaultManager].avatarOfOther;
    [bubbleData addObject:bb];
    [bubbleTable reloadData];
    [self gotoLastMessage:NO];
    
    if ([body isEqualToString:@"c:connectrequest"])
    {
        if ([ChatViewManager defaultManager].chatKeyboardType == chatKeyboardTypeNormal)
        {
            [self displayGame:chatKeyboardTypeYesNo];
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
    bb.avatar=[ChatViewManager defaultManager].avatarOfMe;
    [bubbleData addObject:bb];
    [bubbleTable reloadData];
    [self gotoLastMessage:NO];
    
    [ChatViewManager defaultManager].isWaitingReply=NO;
    lblPrompt.hidden=YES;
    showCustomAlertMessage(@"已挂断");
    [btnHangUp setHidden:YES];
    theApp.currentGamingJid = nil;
}

//经典7式按钮
-(void)sevenButtonClicked
{
    if (!([ChatViewManager defaultManager].isWaitingReply))
    {
        //[textField resignFirstResponder];
        NSString *message=@"c:connectrequest";
        NSString *messageBody=[self filterMessage:message];
        NSBubbleData *bb;
        bb=[NSBubbleData dataWithText:messageBody date:[NSDate date] type:BubbleTypeMine];
        bb.avatar=[ChatViewManager defaultManager].avatarOfMe;
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
        [ChatViewManager defaultManager].isWaitingReply=YES;
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
    bb.avatar=[ChatViewManager defaultManager].avatarOfMe;
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
    bb.avatar=[ChatViewManager defaultManager].avatarOfMe;
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
    [self displayGame:chatKeyboardTypeGameKind];
}

//申请游戏
-(void)applyGame
{
    askToGameButton.enabled = NO;
    lblPrompt.hidden = NO;
    secondsCountDown=30;
    [ChatViewManager defaultManager].isWaitingReply=YES;
    countDownTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    [self displayGame:chatKeyboardTypeApply];
}

//游戏按钮
-(void)gameButtonClicked
{
    //正常键盘
    if([ChatViewManager defaultManager].chatKeyboardType == chatKeyboardTypeKeyboard || [ChatViewManager defaultManager].chatKeyboardType == chatKeyboardTypeNormal)
    {
        [gameButton setImage:[UIImage imageNamed:@"button-connect.png"] forState:UIControlStateNormal];
    }
    else
    {
        [gameButton setImage:[UIImage imageNamed:@"button_keyboard.png"] forState:UIControlStateNormal];
    }
    switch ([ChatViewManager defaultManager].chatKeyboardType) {
        case chatKeyboardTypeApply:
            [self displayGame:chatKeyboardTypeApply];
            break;
        case chatKeyboardTypeYesNo:
            [self displayGame:chatKeyboardTypeYesNo];
        case chatKeyboardTypeGameKind:
            [self displayGame:chatKeyboardTypeGameKind];
            break;
        default:
            [self displayGame:chatKeyboardTypeApply];
            break;
    }
}

//发送按钮
-(void)sendButtonClicked
{
    if(!inputTextField.text.length)
        return;
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    [inputTextField resignFirstResponder];
    
    
    
    NSString *message=inputTextField.text;
    NSString *messageBody=[self filterMessage:message];
    NSBubbleData *bb;
    bb=[NSBubbleData dataWithText:messageBody date:[NSDate date] type:BubbleTypeMine];
    bb.avatar=[ChatViewManager defaultManager].avatarOfMe;
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
