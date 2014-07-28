//
//  PersonSettingController.m
//  huizon
//
//  Created by yang Eric on 3/11/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "PersonSettingController.h"
#import "PersonCell.h"
#import "ChangePwdController.h"
#import "XMPPvCardTemp.h"
#import "XMPPvCardTempModule.h"
#import "InputViewController.h"

@interface PersonSettingController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    IBOutlet UITableViewCell  *cellHead;
    IBOutlet UIImageView      *imageHead;
    NSArray     *nameArray;
    
    IBOutlet UIView     *viewBg;
    IBOutlet UIDatePicker   *pickerBirth;
    
    IBOutlet UILabel *lblMail;
}

@property (strong,nonatomic) IBOutlet UITableView *tableviewSetting;
@end

@implementation PersonSettingController
@synthesize tableviewSetting;


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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];//键盘将要显示的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHidden:) name:UIKeyboardWillHideNotification object:nil];//键盘将要隐藏的通知
    
    [imageHead.layer setBorderWidth:1];
    imageHead.layer.masksToBounds = YES;
    [imageHead.layer setCornerRadius:50];
    [theApp getUserCardTemp];
    if (theApp.xmppvCardUser && StringNotNullAndEmpty(theApp.xmppvCardUser.email))
    {
        lblMail.text=theApp.xmppvCardUser.email;
        [self.tableviewSetting reloadData];
    }
    else{
        [theApp getUserCardTemp];
        showCustomAlertMessage(@"获取您的个人信息失败");
    }
    
    //imageHead.image = [UIImage imageWithData:theApp.xmppvCardUser.photo];
    if ([theApp.xmppvCardUser.gender isEqualToString:@"男"])
    {
        imageHead.image=[UIImage imageNamed:@"portrait-male-large.png"];
    }
    else
    {
        imageHead.image=[UIImage imageNamed:@"portrait-female-large.png"];
    }
    
    //nameArray = @[@"",@"昵称",@"性别",@"出生年月",@"个性签名",@"连酷ID",@"注册邮箱"];
    nameArray = @[@"",@"昵称",@"性别",@"出生年月",@"个性签名"];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRect frame = self.tableviewSetting.frame;
    frame.origin.y = 63.f;
    self.tableviewSetting.frame = frame;
    if (theApp.xmppvCardUser==nil) {
        [self backAction:nil];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"我"];
    //self.navigationItem.rightBarButtonItem=[[Theam currentTheam] navigationBarRightButtonItemWithImage:Nil Title:@"修改密码" Target:self Selector:@selector(btnChangeTap:)];
    self.navigationItem.leftBarButtonItem=[[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(btBack_DisModal:)];
    
    
}

- (void)backAction:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Action

- (IBAction)changePassword:(id)sender
{
    ChangePwdController *cvc = [[ChangePwdController alloc] init];
    [self.navigationController pushViewController:cvc animated:YES];
}
- (void)btnChangeTap:(id)sender
{
    ChangePwdController *cvc = [[ChangePwdController alloc] init];
    [self.navigationController pushViewController:cvc animated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return 130;
    }
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        if(theApp.xmppvCardUser.photo.length)
        {
            imageHead.image = [[UIImage alloc] initWithData:theApp.xmppvCardUser.photo];
        }
        return cellHead;
    }
    static NSString *cellIdentifier = @"PersonCell";
    PersonCell *cell = (PersonCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    switch (indexPath.row) {
        case 1:
            [cell initSettingCell:nameArray[indexPath.row] Content:theApp.xmppvCardUser.nickname Other:NO];
            break;
        case 2:
            [cell initSettingCell:nameArray[indexPath.row] Content:theApp.xmppvCardUser.gender Other:NO];
            break;
        case 3:
            [cell initSettingCell:nameArray[indexPath.row] Content:theApp.xmppvCardUser.birthday Other:NO];
            break;
        case 4:
            [cell initSettingCell:nameArray[indexPath.row] Content:theApp.xmppvCardUser.personstate Other:NO];
            break;
            /*
             case 5:
             [cell initSettingCell:nameArray[indexPath.row] Content:theApp.xmppvCardUser.mailer Other:NO];
             break;
             case 6:
             [cell initSettingCell:nameArray[indexPath.row] Content:theApp.xmppvCardUser.email Other:NO];
             break;
             */
        default:
            break;
    }
    
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_block_t reload=^{
		[self.tableviewSetting reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
	};
    
    IMP_BLOCK_SELF(PersonSettingController)
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            CTActionSheet *sheet = [[CTActionSheet alloc] initWithTitle:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil HandleBlock:^(int btnIndex) {
                if (btnIndex==0) {
                    [self selectPhoto];
                }
                else if (btnIndex==1){
                    [self takePhoto];
                }
            }];
            [sheet addButtonWithTitle:@"相册"];
            [sheet addButtonWithTitle:@"拍摄"];
            [sheet addButtonWithTitle:@"取消"];
            [sheet setCancelButtonIndex:2];
            [sheet showInView:self.view];
        }
            break;
        case 1:  //nickname
        {
            InputViewController *ivc =  [[InputViewController alloc] init];
            ivc.modifyStr = theApp.xmppvCardUser.nickname;
            ivc.NavTitle = @"修改昵称";
            ivc.numberOfword = 10;
            
            ivc.saveHandler = ^(id sender){
                NSString *str = (NSString *)sender;
                [block_self.tableviewSetting reloadData];
                theApp.xmppvCardUser.nickname = str;
                [theApp updateUserCardTemp:theApp.xmppvCardUser];
                
            };
            [self.navigationController pushViewController:ivc animated:YES];
        }
            break;
        case 2:  ///sex
        {
            CTActionSheet *sheet = [[CTActionSheet alloc] initWithTitle:@"请选择性别" cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil HandleBlock:^(int btnIndex) {
                if (btnIndex==0) {
                    theApp.xmppvCardUser.gender = @"男";
                    [theApp updateUserCardTemp:theApp.xmppvCardUser];
                    reload();
                }
                else if (btnIndex==1){
                    theApp.xmppvCardUser.gender = @"女";
                    [theApp updateUserCardTemp:theApp.xmppvCardUser];
                    reload();
                }
            }];
            [sheet addButtonWithTitle:@"男"];
            [sheet addButtonWithTitle:@"女"];
            [sheet addButtonWithTitle:@"取消"];
            [sheet setCancelButtonIndex:2];
            [sheet showInView:self.view];
        }
            break;
        case 3: ///birthday
        {
            [self showPicker];
        }
            break;
        case 4:{
            InputViewController *ivc =  [[InputViewController alloc] init];
            ivc.modifyStr = theApp.xmppvCardUser.personstate;
            ivc.NavTitle = @"修改个性签名";
            ivc.numberOfword = 140;
            ivc.saveHandler = ^(id sender){
                NSString *str = (NSString *)sender;
                theApp.xmppvCardUser.personstate = str;
                [theApp updateUserCardTemp:theApp.xmppvCardUser];
                [block_self.tableviewSetting reloadData];
            };
            [self.navigationController pushViewController:ivc animated:YES];
            break;
        }
        default:
            break;
    }
}


#pragma mark -
#pragma mark OtherAction
- (void)showPicker
{
    
    NSDate *selDate = [NSDate dateWithString:@"1998-09-23" Format:@"YYYY-MM-dd"];
    [pickerBirth setDate:selDate animated:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        viewBg.frame = CGRectMake(0, self.view.height-viewBg.height, 320, viewBg.height);
    }];
}

- (void)hidePicker
{
    [UIView animateWithDuration:0.3 animations:^{
        viewBg.frame = CGRectMake(0, self.view.height, 320, viewBg.height);
    }];
}
- (IBAction)pickerCancel:(id)sender
{
    [self hidePicker];
}

- (IBAction)pickerChoose:(id)sender
{
    [self hidePicker];
    NSDate *selectedDate = [pickerBirth date];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:3600*8];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateString = [formatter stringFromDate:selectedDate];
    
    theApp.xmppvCardUser.birthday=dateString;
    [theApp updateUserCardTemp:theApp.xmppvCardUser];
    
    [self.tableviewSetting reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -
#pragma mark IMageTake
- (void) takePhoto
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        [imagePicker setAllowsEditing:NO];
        [self presentViewController:imagePicker animated:YES completion:nil];
        
	}
}
- (void) selectPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [imagePicker setAllowsEditing:YES];
        [self presentViewController:imagePicker animated:YES completion:nil];
	}
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo
{
    
    CGSize size = img.size;
	CGFloat ratio = 1;
	if (size.width>440) {
		ratio = 440/size.width;
	}
    int ratwid = ratio*size.width;
    int rathig = ratio*size.height;
    if (ratwid<1) {
        ratwid = 1;
    }
    if (rathig<1) {
        rathig = 1;
    }
    
	CGRect rect = CGRectMake(0.0, 0.0, ratwid, rathig);
	UIGraphicsBeginImageContext(rect.size);
	[img drawInRect:rect];
	img = UIGraphicsGetImageFromCurrentImageContext();
	
    imageHead.image = img;
    NSData *imgData = UIImageJPEGRepresentation(img,0.7);
    
    
    theApp.xmppvCardUser.photo=imgData;
    [theApp updateUserCardTemp:theApp.xmppvCardUser];
    
    [self.tableviewSetting reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    // showIndicator(YES);
    //    [[BaseEngine sharedEngine] RunRequest:dict path:HK_USER_MODIFY completionHandler:^(NSDictionary *responseDict) {
    //        [HK_Singleton sharedSingleton].userItem.picture = imgStr;
    //        showCustomAlertMessage(@"保存成功");
    //
    //    } errorHandler:^(NSError *error) {
    //
    //        showCustomAlertMessage(@"请求失败，请检查网络设置");
    //
    //    } finishHandler:^(NSString *resString) {
    //
    //    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
	[picker dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark -
#pragma mark Action
-(void)keyBoardWillShow:(NSNotification *)notif{
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    //整个UIViewControll中加一个scrollView控件 然后再把各种控件放在其中就行
    if ([value CGRectValue].origin.y<self.view.height) {
        NSTimeInterval animation = 0.30f;
        [UIView beginAnimations:@"animal" context:nil];
        [UIView setAnimationDuration:animation];
        float temph = self.view.height-keyboardSize.height;
        
        self.tableviewSetting.frame = CGRectMake(0, 0, 320, temph);
        
        [UIView commitAnimations];
    }
}
-(void)keyBoardWillHidden:(NSNotification *)notif{
    
    self.tableviewSetting.frame = CGRectMake(0, 0, 320, self.view.height);
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    
    if (textField.text && StringNotNullAndEmpty(textField.text)) {
        
        if (theApp.xmppvCardUser.personstate != textField.text) {
            theApp.xmppvCardUser.personstate = textField.text;
            [theApp updateUserCardTemp:theApp.xmppvCardUser];
        }
        
        
    }
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
