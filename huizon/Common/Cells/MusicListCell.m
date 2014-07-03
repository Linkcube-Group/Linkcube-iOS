//
//  MusicListCell.m
//  huizon
//
//  Created by yang Eric on 5/25/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "MusicListCell.h"
@interface MusicListCell()
@property (strong,nonatomic) IBOutlet UILabel *lbName;
@property (strong,nonatomic) IBOutlet UILabel *lbAuthor;
@property (strong,nonatomic) IBOutlet UILabel *lbBlock;
@end

@implementation MusicListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
      
    }
    return self;
}
- (void)setMusiceCell:(NSString *)name Author:(NSString *)author
{
    self.lbName.text = name;
    self.lbAuthor.text = author;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        self.lbBlock.hidden = NO;
        self.contentView.backgroundColor = RGBColor(244, 209, 234);

    }
    else{
        self.contentView.backgroundColor = RGBColor(246, 233, 239);
        self.lbBlock.hidden = YES;
    }
    // Configure the view for the selected state
}

@end
