//
//  PersonCell.h
//  huizon
//
//  Created by yang Eric on 3/16/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic,copy) EventHandler  editHandler;
@property (strong,nonatomic)  IBOutlet UILabel     *labelName;
@property (strong,nonatomic)  IBOutlet UITextField *fieldContent;

- (void)initSettingCell:(NSString *)name Content:(NSString *)content Other:(BOOL)flag;
@end
