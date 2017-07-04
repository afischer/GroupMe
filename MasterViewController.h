//
//  MasterViewController.h
//  GroupMe
//
//  Created by Andrew Fischer on 12/13/16.
//  Copyright © 2016 Andrew Fischer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController
@property (strong, nonatomic) DetailViewController *detailViewController;
@end

