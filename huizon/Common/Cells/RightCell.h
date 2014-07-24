//
//  RightCell.h
//  huizon
//
//  Created by meng on 6/9/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RightCell : UITableViewCell
- (void)setMenuImage:(NSString *)img Name:(NSString *)name;
- (void)setRightIcon:(NSString *)imgName;
- (void)setFriendStatus:(NSString *)status;
- (void)setCellFriendName:(NSString *)friendName;
- (void)setCellFriendId:(NSString *)friendId;
@end
