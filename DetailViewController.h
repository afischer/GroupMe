//
//  DetailViewController.h
//  GroupMe
//
//  Created by Andrew Fischer on 12/13/16.
//  Copyright © 2016 Andrew Fischer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>

#import "Group.h"

@interface DetailViewController : JSQMessagesViewController
- (void)initializeGroupWithGroup:(Group *)group;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

