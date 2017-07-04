//
//  MasterViewController.m
//  GroupMe
//
//  Created by Andrew Fischer on 12/13/16.
//  Copyright © 2016 Andrew Fischer. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NewGroupViewController.h"
#import "AccountManager.h"
#import "UIColor+GroupMe.h"


#import "AFNetworking.h"
#import "Lockbox.h"
#import "Group.h"
#import "GroupTableViewCell.h"


@interface MasterViewController ()
@property NSMutableArray *groups;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentNewGroupController)];
    
    
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    //[[UINavigationBar appearance] setTintColor:[UIColor groupMeBlue]];
    //[[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    //self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    //self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

-(void)viewDidAppear:(BOOL)animated {
    if (![AccountManager isLoggedIn]) {
        [AccountManager signInUser];
    } else {
        NSMutableString *URLString = [[NSMutableString alloc] init];
        [URLString appendString:@"https://api.groupme.com/v3/groups?token="];
        [URLString appendString:[AccountManager getAuthToken]];
        NSLog(@"%@", URLString);
        NSError* error = nil;
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:URLString] options:NSDataReadingUncached error:&error];
        [self setupGroupsFromJSONArray:data];
        

    }
    
}

- (void)refresh {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)setClientID:(NSString *)ID {
//    if ([Lockbox unarchiveObjectForKey:@"oAuthToken"] != nil) {
//        [self.sfvc dismissViewControllerAnimated:YES completion:nil];
//    }
//}

#pragma mark - Data
-(void)setupGroupsFromJSONArray:(NSData*)dataFromServerArray{
    NSError *error;
    self.groups = [[NSMutableArray alloc] init];
    NSDictionary *arrayFromServer = [NSJSONSerialization JSONObjectWithData:dataFromServerArray options:0 error:nil];
    arrayFromServer = [arrayFromServer objectForKey:@"response"];
    
    if(error){
        NSLog(@"error parsing the json data from server with error description - %@", [error localizedDescription]);
    }
    else {
        self.groups = [[NSMutableArray alloc] init];
        for(NSDictionary *eachGroup in arrayFromServer){
            Group *group = [[Group alloc] initWithJSONData:eachGroup];
            [self.groups addObject:group];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSLog(@"SENDING FROM %@", sender);
        Group *segueToGroup = self.groups[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        controller.title = segueToGroup.groupName;
        [controller initializeGroupWithGroup:segueToGroup];
        
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - New Group

- (void) presentNewGroupController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *newGroupController = [storyboard instantiateViewControllerWithIdentifier:@"GroupDetailNavigationController"];
    newGroupController.navigationController.navigationItem.rightBarButtonItem.title = @"Create";
    [newGroupController setModalPresentationStyle:UIModalPresentationPopover];
    [self presentViewController:newGroupController animated:YES completion: nil];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groups count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    GroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        Group *currentGroup = self.groups[indexPath.row];
        NSLog(@"HELLO %@", [currentGroup groupName]);
        cell.groupNameLabel.text = [currentGroup groupName];
        
        cell.descriptionLabel.text = [currentGroup groupDescription];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [cell.groupImageView setImage:[currentGroup groupImage]];
            if ([cell.descriptionLabel.text isEqual: @""]) {
                NSLog(@"WOOOOOOO");
                [cell.textPreview setNumberOfLines:3];
                [cell.textPreview setCenter:CGPointMake(cell.textPreview.center.x, 48)];
            }

            NSTimeInterval seconds = [[currentGroup groupLastUpdated] doubleValue];
            NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yy h:mm"];

            cell.timestamp.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:epochNSDate]];
            cell.textPreview.text = [NSString stringWithFormat:@"%@: %@",[currentGroup lastSender], [currentGroup lastMessage]];
        });
    });
    
    
    return cell;
}

@end
