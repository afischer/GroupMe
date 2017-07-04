//
//  GroupDetailViewController.h
//  GroupMe
//
//  Created by Andrew Fischer on 12/18/16.
//  Copyright © 2016 Andrew Fischer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextView *topicField;
@property (strong, nonatomic) IBOutlet UIImageView *groupImageView;
@property (strong, nonatomic) IBOutlet UILabel *imageSelectText;
@property (strong, nonatomic) NSMutableArray * contacts;
@end
