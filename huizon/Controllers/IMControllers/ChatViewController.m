//
//  ChatViewController.m
//  huizon
//
//  Created by yang Eric on 3/2/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "ChatViewController.h"
#import "UserViewController.h"
#import "FriendViewController.h"
#import "UserProfileViewController.h"
@interface ChatViewController ()<ChatDelegate>

@end

@implementation ChatViewController


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
    [self appDelegate];
    //[self testMessageArchiving];

    // Do any additional setup after loading the view from its nib.
}

- (IBAction)friendAction:(id)sender
{
    FriendViewController *fvc = [[FriendViewController alloc] init];
    [self.navigationController pushViewController:fvc animated:YES];
}
- (IBAction)TestButton:(id)sender
{
    [self testPref];
}
-(void)testPref
{
    NSXMLElement *pf=[theApp.xmppMessageArchivingModule preferences];
    
    /*
    NSXMLElement *pref=[NSXMLElement elementWithName:@"pref" xmlns:@"urn:xmpp:archive"];
    NSXMLElement *aut=[NSXMLElement elementWithName:@"auto"];
    [aut addAttributeWithName:@"save" stringValue:@"true"];
    [pref addChild:aut];
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"auto1"];
    [iq addChild:pref];
    [theApp.xmppStream sendElement:iq];
    */
    /*
    NSXMLElement *pref=[NSXMLElement elementWithName:@"pref" xmlns:@"urn:xmpp:archive"];
    NSXMLElement *aut=[NSXMLElement elementWithName:@"auto"];
    [aut addAttributeWithName:@"save" stringValue:@"true"];
    [pref addChild:aut];
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"auto1"];
    [iq addAttributeWithName:@"to" stringValue:[theApp.xmppStream.myJID full]];
    [iq addChild:pref];
    [theApp.xmppStream sendElement:iq];
    */
    /*
    NSXMLElement *pref=[NSXMLElement elementWithName:@"pref" xmlns:@"urn:xmpp:archive"];
    NSXMLElement *aut=[NSXMLElement elementWithName:@"auto"];
    [aut addAttributeWithName:@"save" stringValue:@"true"];
    [pref addChild:aut];
    [theApp.xmppMessageArchivingModule setPreferences:pref];
    [self testMessageArchiving];
     */
    /*
    NSXMLElement *pref2=[NSXMLElement elementWithName:@"pref" xmlns:@"urn:xmpp:archive"];
    NSXMLElement *iq2=[NSXMLElement elementWithName:@"iq"];
    [iq2 addAttributeWithName:@"type" stringValue:@"get"];
    [iq2 addChild:pref2];
    [iq2 addAttributeWithName:@"to" stringValue:[theApp.xmppStream.myJID full]];
    [theApp.xmppStream sendElement:iq2];
     */
    
}


- (void)testMsg{
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Contact_CoreDataObject"
                                                     inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    NSError *error;
    NSArray *messages = [moc executeFetchRequest:request error:&error];
    
    [self print:[[NSMutableArray alloc]initWithArray:messages]];
//    _contactsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:@"MessagesContactListCache"];
}

- (void)deleteMessage:(XMPPMessageArchiving_Message_CoreDataObject *)rmMesg
{
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
    [moc deleteObject:rmMesg];
    
}

-(void)testMessageArchiving{
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    NSString *bareJid=[theApp.xmppStream.myJID bare];
    //NSPredicate *predicat=[NSPredicate predicateWithFormat:@"bareJidStr==%@",bareJid];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"streamBareJidStr==%@",bareJid];
    [request setEntity:entityDescription];
    [request setPredicate:predicate]; //查找条件
    NSError *error=nil;
    NSArray *messageArray=[moc executeFetchRequest:request error:&error]; //查找与当前用户聊天记录

    
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc]init];
//    [request setEntity:entityDescription];
//    NSError *error;
//    NSArray *messages = [moc executeFetchRequest:request error:&error];
    
    [self print:[[NSMutableArray alloc]initWithArray:messageArray]];
}

-(void)print:(NSMutableArray*)messages{
    @autoreleasepool {
        for (XMPPMessageArchiving_Message_CoreDataObject *message in messages) {
            NSLog(@"messageStr param is %@",message.messageStr);
            NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
            NSLog(@"to param is %@",[element attributeStringValueForName:@"to"]);
            NSLog(@"NSCore object id param is %@",message.objectID);
            NSLog(@"bareJid param is %@",message.bareJid);
            NSLog(@"bareJidStr param is %@",message.bareJidStr);
            NSLog(@"body param is %@",message.body);
            NSLog(@"timestamp param is %@",message.timestamp);
            NSLog(@"outgoing param is %d",[message.outgoing intValue]);
            
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([theApp isXmppAuthenticated]) {
        //[self testMessageArchiving];
    }
    else{
        UserViewController *uvc = [[UserViewController alloc] init];
        [self.navigationController pushViewController:uvc animated:YES];
    }
    
}
- (IBAction)disconnect
{
    [theApp disconnect];
    UserViewController *uvc=[[UserViewController alloc] init];
    [self.navigationController pushViewController:uvc animated:YES];
}
//
- (IBAction)displayUserProfile:(id)sender
{
    UserProfileViewController *upc=[[UserProfileViewController alloc] init];
    [self.navigationController pushViewController:upc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - my method
- (AppDelegate *)appDelegate
{
    theApp.chatDelegate = self;
	return theApp;
}
#pragma mark - ChatDelegate
-(void)getNewMessage:(AppDelegate *)appD Message:(XMPPMessage *)message
{
   // [self getMessageData];
  //  [self.tableView reloadData];
}
-(void)friendStatusChangePresence:(XMPPPresence *)presence
{
}
-(void)friendSubscription:(XMPPPresence *)presence
{
    
    NSLog(@"-----------------------%@",presence.toStr);
    showCustomAlertMessage(presence.description);
    //[theApp.xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
}
@end
