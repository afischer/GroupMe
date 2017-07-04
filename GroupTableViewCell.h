//
//  GroupTableViewCell.h
//  GroupMe
//
//  Created by Andrew Fischer on 12/14/16.
//  Copyright © 2016 Andrew Fischer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupTableViewCell : UITableViewCell
@property (strong) IBOutlet UIImageView *groupImageView;
@property (strong) IBOutlet UILabel *groupNameLabel;
@property (strong) IBOutlet UILabel *textPreview;
@property (strong) IBOutlet UILabel *timestamp;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@end
