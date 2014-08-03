//
//  RightCell.m
//  huizon
//
//  Created by meng on 6/9/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "RightCell.h"
#import "RightViewController.h"
@interface RightCell()
@property (strong,nonatomic) NSString *iconName;
@property (strong,nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong,nonatomic) IBOutlet UIImageView *imgIconRight;
@property (strong,nonatomic) IBOutlet UILabel *lbUserName;
@property (strong,nonatomic) IBOutlet UILabel *lbFriendStatus;
@property (strong,nonatomic) IBOutlet UIButton *btnAdd;
@property (strong,nonatomic) IBOutlet UIButton *btnAcept;
@property (strong,nonatomic) IBOutlet UIButton *btnReject;
@property (strong,nonatomic) NSString *friendName;
@property (strong,nonatomic) NSString *friendId;
@end

@implementation RightCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



// set name of the icon in the front and the name of the text, for the RightCellLabel

- (void)setMenuImage:(NSString *)imgName Name:(NSString *)name
{
    self.iconName = imgName;
    self.imgIcon.image = IMG(_S(@"%@.png",self.iconName));
    self.lbUserName.text = name;
}

// set right icon 

- (void)setRightIcon:(NSString *)imgName
{
    self.imgIconRight.image = IMG(_S(@"%@.png",imgName));
}


- (void)setCellFriendName:(NSString *)friendName
{
    self.friendName=friendName;
}

- (void)setCellFriendId:(NSString *)friendId
{
    self.friendId=friendId;
}

- (void)setFriendStatus:(NSString *)status
{
    if([status isEqualToString:@"None"])
    {
        self.btnAdd.hidden=NO;
        self.lbFriendStatus.hidden=YES;
    }
    else if([status isEqualToString:@"判断"])
    {
        self.btnAdd.hidden=YES;
        self.lbFriendStatus.hidden=YES;
        self.lbFriendStatus.text=status;
        self.btnAcept.hidden=NO;
        self.btnReject.hidden=NO;
    }
    else
    {
        self.btnAdd.hidden=YES;
        self.lbFriendStatus.hidden=NO;
        self.lbFriendStatus.text=status;
    }
    
}

- (void)deleteUserInCoreData:(NSString *)jidStr
{
    
    //XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",presence.from]];
    NSManagedObjectContext *context=[[theApp xmppRosterStorage] mainThreadManagedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc]init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"jidStr==%@",jidStr];
    [request setPredicate:predicate];
    [request setIncludesPropertyValues:NO];
    [request setEntity:entity];
    NSError *error=nil;
    NSArray *datas=[context executeFetchRequest:request error:&error];
    if(!error &&datas &&[datas count])
    {
        for(NSManagedObject *obj in datas)
            [context deleteObject:obj];
        if(![context save:&error])
            NSLog(@"error:%@",error);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPPNotificationDidAskFriend object:nil];

    
}
- (IBAction)acceptSub:(id)sender
{
    NSString *jidStr=self.friendId;
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",jidStr]];
    [theApp.xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    //[[NSNotificationCenter defaultCenter] postNotificationName:kXMPPNotificationDidAskFriend object:nil];
    [self deleteUserInCoreData:jidStr];
}
- (IBAction)declineSub:(id)sender
{
    NSString *jidStr=self.friendId;
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",jidStr]];
    [theApp.xmppRoster rejectPresenceSubscriptionRequestFrom:jid];
    //[[NSNotificationCenter defaultCenter] postNotificationName:kXMPPNotificationDidAskFriend object:nil];
    [self deleteUserInCoreData:jidStr];
}
- (IBAction)AddFriend:(id)sender
{
    
    NSString *jid=self.friendId;
    [theApp XMPPAddFriendSubscribeWithJid:jid];
    //self.lbFriendStatus.text=@"等待验证";
    //[[NSNotificationCenter defaultCenter] postNotificationName:kXMPPNotificationDidAskFriend object:nil];
}

@end
