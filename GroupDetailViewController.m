//
//  GroupDetailViewController.m
//  GroupMe
//
//  Created by Andrew Fischer on 12/18/16.
//  Copyright © 2016 Andrew Fischer. All rights reserved.
//

#import "GroupDetailViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "Lockbox.h"
#import <ContactsUI/ContactsUI.h>

@interface GroupDetailViewController () <CNContactPickerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *contactsTable;
@end

@implementation GroupDetailViewController
@synthesize nameField = _nameField;
@synthesize topicField = _topicField;
@synthesize groupImageView = _groupImageView;
@synthesize imageSelectText = _imageSelectText;
@synthesize contacts = _contacts;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.contacts = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)userDidCancelGroupCreation:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)userDidInitiateGroupCreation:(id)sender {
    NSLog(@"CREATING NEW GROUP");
    NSMutableString *URLString = [[NSMutableString alloc] init];
    [URLString appendString:@"https://api.groupme.com/v3/groups"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:[Lockbox unarchiveObjectForKey:@"oAuthToken"] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params =  @{@"name": self.nameField.text,
                              @"share": @"false",
                              @"description": self.topicField.text
                              };
    
    NSLog(@"%@", params);
    
    [manager POST:URLString parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"JSON: %@", responseObject);
         [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
     }
          failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];

    
    // POST HERE
}


#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - CNContactPickerDelegate

- (IBAction)didRequestContactsView:(id)sender {
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
    contactPicker.delegate = self;
    contactPicker.predicateForEnablingContact = [NSPredicate predicateWithFormat:@"phoneNumbers.@count > 0"];
    contactPicker.displayedPropertyKeys = @[CNContactGivenNameKey, CNContactPhoneNumbersKey];
    [self presentViewController:contactPicker animated:YES completion:nil];
}

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts{
    NSLog(@"%@", contacts);
    for (NSDictionary *contact in contacts) {
        if (![self.contacts containsObject:contact]) {
            [self.contacts addObject:contact];
        }
    }
    [self.contactsTable reloadData];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"ADDING CELL YO");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    
    CNContact *currContact = [self.contacts objectAtIndex:indexPath.row];
    
    NSString *labelText = [NSString stringWithFormat:@"%@ %@", [currContact givenName], [currContact familyName]];
    cell.textLabel.text = labelText;
    return cell;
}

@end
