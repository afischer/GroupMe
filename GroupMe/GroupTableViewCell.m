//
//  GroupTableViewCell.m
//  GroupMe
//
//  Created by Andrew Fischer on 12/14/16.
//  Copyright © 2016 Andrew Fischer. All rights reserved.
//

#import "GroupTableViewCell.h"

@implementation GroupTableViewCell
@synthesize groupImageView;
@synthesize groupNameLabel;
@synthesize textPreview;
@synthesize timestamp;
@synthesize descriptionLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
