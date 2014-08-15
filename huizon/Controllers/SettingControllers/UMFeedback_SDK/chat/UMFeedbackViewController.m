//
//  UMFeedbackViewController.m
//  UMeng Analysis
//
//  Created by liu yu on 7/12/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "UMFeedbackViewController.h"
#import "UMFeedbackTableViewCellLeft.h"
#import "UMFeedbackTableViewCellRight.h"
#import "UMContactViewController.h"

#import "Config.h"

#define TOP_MARGIN 20.0f
#define kNavigationBar_ToolBarBackGroundColor  [UIColor colorWithRed:0.149020 green:0.149020 blue:0.149020 alpha:1.0]
#define kContactViewBackgroundColor  [UIColor colorWithRed:0.078 green:0.584 blue:0.97 alpha:1.0]

static UITapGestureRecognizer *tapRecognizer;

@implementation UINavigationBar (CustomImage)
- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed:@"nav_btn_bg"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end

@interface UMFeedbackViewController ()
@property(nonatomic, copy) NSString *mContactInfo;
@end

@implementation UMFeedbackViewController

@synthesize mTextField = _mTextField, mTableView = _mTableView, mToolBar = _mToolBar, mFeedbackData = _mFeedbackData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.appkey = kSettingUmeng;
        // Custom initialization
    }
    return self;
}

- (void)customizeNavigationBar:(UINavigationBar *)bar {
    bar.clipsToBounds = YES;
    if ([bar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        UIImage *image = [self imageWithColor:kNavigationBar_ToolBarBackGroundColor];
        
        [bar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setupTableView {
    _tableViewTopMargin = self.navigationController.navigationBar.frame.size.height;
    
    BOOL contactViewHide = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UMFB_ShowContactView"] boolValue];
    
    if (!contactViewHide) {
        _tableViewTopMargin = 88.0f;
        UILabel *title = (UILabel *) [self.mContactView viewWithTag:11];
        title.text = NSLocalizedString(@"Your contact information", @"您的联系方式");
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"UMFB_ShowContactView"];
    } else {
        _tableViewTopMargin = 0;
        [self.mContactView removeFromSuperview];
    }
    
    self.mTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void)setupEGORefreshTableHeaderView {
    if (_refreshHeaderView == nil) {
        
        UMEGORefreshTableHeaderView *view = [[UMEGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.mTableView.bounds.size.height, self.mTableView.frame.size.width, self.mTableView.bounds.size.height)];
        view.delegate = (id <UMEGORefreshTableHeaderDelegate>) self;
        [self.mTableView addSubview:view];
        _refreshHeaderView = view;
    }
    
    [_refreshHeaderView refreshLastUpdatedDate];
}

- (void)setupToolbar {
    self.mToolBar.backgroundColor = RGBColor(231, 231, 231);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    button.frame = CGRectMake(256, 7, 57.0f, 30.0f);
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button setTitle:@"发送" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"140x70_blue.png"] forState:UIControlStateNormal];
    //    [button setBackgroundImage:[UIImage imageNamed:@"send_selected.png"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mToolBar addSubview:button];
    
    [self setupTextField];
}

- (void)setupTextField {
    _mTextField = [[UITextField alloc] initWithFrame:CGRectMake(6, 7, _mToolBar.frame.size.width - 74.0f, 30.0f)];
    _mTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _mTextField.backgroundColor = [UIColor whiteColor];
    _mTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _mTextField.textAlignment = NSTextAlignmentLeft;
    _mTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    // _mTextField.borderStyle = UITextBorderStyleLine;
    _mTextField.font = [UIFont systemFontOfSize:14.0f];
	_mTextField.returnKeyType=UIReturnKeyDone;
    
    UIView *paddingView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)] autorelease];
    _mTextField.leftView = paddingView;
    _mTextField.leftViewMode = UITextFieldViewModeAlways;
    _mTextField.delegate = (id <UITextFieldDelegate>) self;
	_mTextField.placeholder=@"请输入您的宝贵意见";
    [self.mToolBar addSubview:_mTextField];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    
    UMContactViewController *contactViewController = [[UMContactViewController alloc] initWithNibName:@"UMContactViewController" bundle:nil];
    
    contactViewController.delegate = (id <UMContactViewControllerDelegate>) self;
    [self.navigationController pushViewController:contactViewController animated:YES];
    if ([self.mContactInfo length]) {
        contactViewController.textView.text = self.mContactInfo;
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"意见反馈"];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_refreshHeaderView egoRefreshScrollViewShowLoadingManual:self.mTableView];
    [_refreshHeaderView egoRefreshScrollViewDataSourceStartManualLoading:self.mTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // [self setBackButton];
    //    [self setBackgroundColor];
    [self setupTableView];
    [self setupEGORefreshTableHeaderView];
    [self setupToolbar];
    //  [self customizeNavigationBar:self.navigationController.navigationBar];
    [self setFeedbackClient];
    [self updateTableView:nil];
    [self handleKeyboard];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handleSingleTap:)];
    [self.mContactView addGestureRecognizer:singleFingerTap];
    
    _shouldScrollToBottom = YES;
    
    self.navigationItem.leftBarButtonItem =[[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(btBack_PopNav:)];
    
}

- (void)handleKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
}

- (void)setFeedbackClient {
    _mFeedbackData = [[NSArray alloc] init];
    feedbackClient = [UMFeedback sharedInstance];
    if ([self.appkey isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NO Umeng kUmengAppkey"
                                                        message:@"Please define UMENG_APPKEY macro!"
                                                       delegate:nil cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    [feedbackClient setAppkey:self.appkey delegate:(id <UMFeedbackDataDelegate>) self];
    
    //    从缓存取topicAndReplies
    self.mFeedbackData = feedbackClient.topicAndReplies;
}

- (void)setBackgroundColor {
    self.mTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"messages_tableview_background"]];
    if ([self.mToolBar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) {
        UIImage *image = [self imageWithColor:kNavigationBar_ToolBarBackGroundColor];
        [self.mToolBar setBackgroundImage:image forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    } else {
        self.mToolBar.barStyle = UIBarStyleBlack;
    }
    self.mContactView.backgroundColor = kContactViewBackgroundColor;
}

- (void)setBackButton {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backBtn addTarget:self action:@selector(backToPrevious) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backBtn] autorelease];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    backBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [backBtn setTitle:NSLocalizedString(@"Close", @"关闭") forState:UIControlStateNormal];
    
    [backBtn setBackgroundImage:[UIImage imageNamed:@"nav_btn_bg"] forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"nav_btn_bg_lighted"] forState:UIControlStateHighlighted];
    backBtn.frame = CGRectMake(0, 0, 51.0f, self.navigationController.navigationBar.frame.size.height * 0.7);
    backBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

- (void)didTapAnywhere:(UITapGestureRecognizer *)recognizer {
    [self.mTextField resignFirstResponder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark keyboard notification

- (void)keyboardWillShow:(NSNotification *)notification
{
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect toolbarFrame = self.mToolBar.frame;
                         toolbarFrame.origin.y = self.view.bounds.size.height - keyboardHeight - toolbarFrame.size.height;
                         self.mToolBar.frame = toolbarFrame;
                         CGRect tableViewFrame = self.mTableView.frame;
                         tableViewFrame.size.height = self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - keyboardHeight;
                         self.mTableView.frame = tableViewFrame;
                     }
                     completion:^(BOOL finished) {
                         if (_shouldScrollToBottom) {
                             [self scrollToBottom];
                         }
                     }
     ];
    
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    CGRect toolbarFrame = self.mToolBar.frame;
    toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
    self.mToolBar.frame = toolbarFrame;
    
    CGRect tableViewFrame = self.mTableView.frame;
    tableViewFrame.size.height = self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height;
    self.mTableView.frame = tableViewFrame;
    
    [UIView commitAnimations];
    
    [self.view removeGestureRecognizer:tapRecognizer];
}

- (void)backToPrevious {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)sendFeedback:(id)sender {
    if ([self.mTextField.text length]) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:self.mTextField.text forKey:@"content"];
        
        if ([self.mContactInfo length]>0) {
            [dictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:self.mContactInfo, @"plain", nil] forKey:@"contact"];
        }
        
        [feedbackClient post:dictionary];
        [self.mTextField resignFirstResponder];
        _shouldScrollToBottom = YES;
    }
}

#pragma mark -
#pragma mark DES


- (NSString *)encryptUseDES:(NSString *)plainText
{
    static char charTable[64] = {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
        'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
        'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
    };
    NSString *strbefor = [plainText base64Encode];
    
    for (int i=0; i<6; i++) {
        srandom(time(0));
        char charRand = charTable[arc4random()%64];
        
        if (i<3) {
            strbefor=[NSString stringWithFormat:@"%c%@",charRand,strbefor];
        }
        else{
            strbefor=[NSString stringWithFormat:@"%@%c",strbefor,charRand];
        }
    }
    
    return strbefor;
    
}

#pragma mark tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_mFeedbackData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *content = [[feedbackClient.topicAndReplies objectAtIndex:(NSUInteger) indexPath.row] objectForKey:@"content"];
    CGSize labelSize = [content sizeWithFont:[UIFont systemFontOfSize:14.0f]
                           constrainedToSize:CGSizeMake(226.0f, MAXFLOAT)
                               lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height + 40 + TOP_MARGIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *L_CellIdentifier = @"L_UMFBTableViewCell";
    static NSString *R_CellIdentifier = @"R_UMFBTableViewCell";
    
    NSDictionary *data = [self.mFeedbackData objectAtIndex:(NSUInteger) indexPath.row];
    
    if ([[data valueForKey:@"type"] isEqualToString:@"dev_reply"]) {
        UMFeedbackTableViewCellLeft *cell = (UMFeedbackTableViewCellLeft *) [tableView dequeueReusableCellWithIdentifier:L_CellIdentifier];
        if (cell == nil) {
            cell = [[[UMFeedbackTableViewCellLeft alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:L_CellIdentifier] autorelease];
        }
        
        cell.textLabel.text = [data valueForKey:@"content"];
        cell.timestampLabel.text = [data valueForKey:@"datetime"];
        
        return cell;
    }
    else {
        
        UMFeedbackTableViewCellRight *cell = (UMFeedbackTableViewCellRight *) [tableView dequeueReusableCellWithIdentifier:R_CellIdentifier];
        if (cell == nil) {
            cell = [[[UMFeedbackTableViewCellRight alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:R_CellIdentifier] autorelease];
        }
        
        cell.textLabel.text = [data valueForKey:@"content"];
        cell.timestampLabel.text = [data valueForKey:@"datetime"];
        
        return cell;
        
    }
}

#pragma mark ContactViewController delegate method

- (void)updateContactInfo:(UMContactViewController *)controller contactInfo:(NSString *)info {
    if ([info length]) {
        self.mContactInfo = info;
        UILabel *title = (UILabel *) [self.mContactView viewWithTag:11];
        title.text = [NSString stringWithFormat:@"%@ : %@", NSLocalizedString(@"Your contact information", @"您的联系方式"), info];
    }
}

#pragma mark Umeng Feedback delegate

- (void)updateTableView:(NSError *)error {
    if ([self.mFeedbackData count]) {
        [self.mTableView reloadData];
    }
}

- (void)updateTextField:(NSError *)error {
    if (!error) {
        self.mTextField.text = @"";
        [feedbackClient get];
    }
}

- (void)getFinishedWithError:(NSError *)error {
    if (!error) {
        [self updateTableView:error];
    }
    
    if (_shouldScrollToBottom) {
        [self scrollToBottom];
    }
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
}

- (void)postFinishedWithError:(NSError *)error {
    //    UIAlertView *alertView;
    //    if (!error)
    //    {
    //        alertView = [[UIAlertView alloc] initWithTitle:@"感谢您的反馈!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    }
    //    else
    //    {
    //        alertView = [[UIAlertView alloc] initWithTitle:@"发送失败!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    }
    //
    //    [alertView show];
    
    [self updateTextField:error];
}

- (void)doneLoadingTableViewData {
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.mTableView];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollToBottom {
    if ([self.mTableView numberOfRowsInSection:0] > 1) {
        int lastRowNumber = [self.mTableView numberOfRowsInSection:0] - 1;
        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
        [self.mTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)reloadTableViewDataSource {
    _reloading = YES;
    [feedbackClient get];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(UMEGORefreshTableHeaderView *)view {
    _shouldScrollToBottom = NO;
    [self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(UMEGORefreshTableHeaderView *)view {
    return _reloading; // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(UMEGORefreshTableHeaderView *)view {
    return [NSDate date]; // should return date data source was last changed
}

#pragma mark UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    feedbackClient.delegate = nil;
    [super dealloc];
}

@end
