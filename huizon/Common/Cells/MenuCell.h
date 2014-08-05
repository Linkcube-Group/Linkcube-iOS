//
//  MenuCell.h
//  huizon
//
//  Created by yang Eric on 5/25/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuCell : UITableViewCell


- (void)setBlueStatu:(int)flag;
- (void)setMenuImage:(NSString *)imgName Name:(NSString *)name WithSelect:(BOOL)selected;
- (void)setBLueConn:(NSString *)name Status:(BOOL)flag;
- (void)setLineName:(NSString *)name;
@end
