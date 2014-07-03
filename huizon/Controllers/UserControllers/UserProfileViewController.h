//
//  UserProfileViewController.h
//  huizon
//
//  Created by meng on 3/17/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *list;
@end
