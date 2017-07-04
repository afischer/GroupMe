//
//  DetailViewController.m
//  GroupMe
//
//  Created by Andrew Fischer on 12/13/16.
//  Copyright © 2016 Andrew Fischer. All rights reserved.
//

#import "DetailViewController.h"
#import "AccountManager.h"
#import "UIColor+GroupMe.h"
#import <Contacts/Contacts.h>
#import <AFNetworking/AFNetworking.h>


@interface DetailViewController ()
@property Group * currentGroup;
@property(strong, nonatomic) NSMutableArray *chatData;
@property(nonatomic) NSMutableArray *userData;
@property(strong, nonatomic) NSMutableDictionary *avatarTable;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@end

@implementation DetailViewController
NSString * const mediaTypes[] = { @"image", @"video", @"location" };

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![AccountManager isLoggedIn]) {
        [AccountManager signInUser];
    }
    
    NSDictionary *userData = [AccountManager getUserData];
    self.senderId = [userData objectForKey:@"user_id"];
    self.senderDisplayName = [userData objectForKey:@"name"];
    self.detailDescriptionLabel.text = self.currentGroup.groupDescription;
    //self.collectionView.collectionViewLayout.springinessEnabled = YES;
    
    [self setupChatBubbles];
    self.chatData = [[NSMutableArray alloc]init];
    self.avatarTable = [[NSMutableDictionary alloc] init];
    


    for (NSDictionary *user in [self.currentGroup members]) {
        if ([user objectForKey:@"image_url"] != [NSNull null]) {
            NSLog(@"USER DOES HAVE IMAGE: %@", [user objectForKey:@"image_url"]);
            [self.avatarTable setValue:[NSURL URLWithString:[user objectForKey:@"image_url"]] forKey:[user objectForKey:@"user_id"]];
        }
        NSLog(@"FINISHED LOADING AVATAR TABLE");
    }
    
    NSMutableString *URLString = [[NSMutableString alloc] init];
    [URLString appendString:@"https://api.groupme.com/v3/groups/"];
    [URLString appendString:self.currentGroup.groupID];
    [URLString appendString:@"/messages?token="];
    [URLString appendString:[AccountManager getAuthToken]];
    NSError* error = nil;
    
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:URLString] options:NSDataReadingUncached error:&error];
    if (error){
        NSLog(@"%@", error);
    }
    NSDictionary *messageData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    for (NSDictionary *message in [[messageData objectForKey:@"response"] objectForKey:@"messages"]) {
        JSQMessage *jsqMessage;
        NSString *senderId = [message objectForKey:@"sender_id"];
        NSString *senderName = [message objectForKey:@"name"];
        NSString *dateStr = [message objectForKey:@"created_at"];
        double timestamp = [dateStr doubleValue];
        NSTimeInterval timeInterval = timestamp;
        NSDate *sentDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        NSString *messageText = [message objectForKey:@"text"];
        
        NSLog(@"Media message %@", message);

        // Text messages
        if (![messageText isEqual:[NSNull null]]) {
            NSLog(@"Message %@", [message objectForKey:@"text"]);
            jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                            senderDisplayName:senderName
                                                         date:sentDate
                                                         text:messageText];
            
            if (jsqMessage) {
                [self.chatData addObject:jsqMessage];
                
            }
        }
        
        // Media messages
        if ([[message objectForKey:@"attachments"] count]) {

            for (NSDictionary *attachment in [message objectForKey:@"attachments"]) {
                // IMAGE //
                if ([[attachment objectForKey:@"type"] isEqualToString:@"image"] || [[attachment objectForKey:@"type"] isEqualToString:@"linked_image"]){
                    
                    NSURL *photoURL = [NSURL URLWithString:[attachment objectForKey:@"url"]];
                    NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
                    JSQPhotoMediaItem *photo = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:photoData]];

                    // Don't mark as outgoing if not me
                    if (![senderId isEqualToString:self.senderId]){
                        photo.appliesMediaViewMaskAsOutgoing = NO;
                    }
                    
                    jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                    senderDisplayName:senderName
                                                                 date:sentDate
                                                                media:photo];
                }

                // LOCATION //
                if ([[attachment objectForKey:@"type"] isEqualToString:@"location"]){
                    JSQLocationMediaItem *mediaItem = [[JSQLocationMediaItem alloc] initWithLocation:nil];

                    // Don't mark as outgoing if not me
                    if (![senderId isEqualToString:self.senderId]){
                        mediaItem.appliesMediaViewMaskAsOutgoing = NO;
                    }
                    
                    CLLocationDegrees lng = [[attachment objectForKey:@"lng"] doubleValue];
                    CLLocationDegrees lat = [[attachment objectForKey:@"lat"] doubleValue];
                    NSLog(@"LAT LNG %f %f", lat, lng);
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
                    
                    [mediaItem setLocation:location withCompletionHandler:^{
                        [self.collectionView reloadData];
                    }];
                    
                    jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                    senderDisplayName:senderName
                                                                 date:sentDate
                                                                media:mediaItem];
                }
                
                // VIDEO //
                if ([[attachment objectForKey:@"type"] isEqualToString:@"video"]){
                    JSQVideoMediaItem *mediaItem = [[JSQVideoMediaItem alloc] initWithFileURL:[attachment objectForKey:@"url"] isReadyToPlay:NO];
                    
                    [self.collectionView reloadData];

                    jsqMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                    senderDisplayName:senderName
                                                                 date:sentDate
                                                                media:mediaItem];
                }
                

                if ([[attachment objectForKey:@"type"] isEqualToString:@"mentions"]){

                }
            }
            
            if (jsqMessage) {
                [self.chatData addObject:jsqMessage];
            }
        }

    }
    self.chatData = [[[self.chatData reverseObjectEnumerator] allObjects] mutableCopy];
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - JSQMessage Handling

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate   *)date {
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    [self.chatData addObject:message];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:[AccountManager getAuthToken] forHTTPHeaderField:@"X-Access-Token"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableString *URLString = [[NSMutableString alloc] init];
    [URLString appendString:@"https://api.groupme.com/v3/groups/"];
    [URLString appendString:self.currentGroup.groupID];
    [URLString appendString:@"/messages"];
    
    
    NSDictionary *params =  @{@"message": @{
                                      @"source_guid":[[NSUUID UUID] UUIDString],
                                      @"text":text,
                                      @"attachments":@[]}
                              };
    
    NSLog(@"%@", params);
    
    [manager POST:URLString parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"JSON: %@", responseObject);
     }
          failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
    
    
    [self finishSendingMessageAnimated:YES];

//    [self.collectionView reloadData];
    [self scrollToBottomAnimated:YES];
    
}


- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Handle what happens when a user selects a cell. It should segue to the MapViewController and display the location
    // Of the message sent.
    JSQMessage *msg = [self.chatData objectAtIndex:indexPath.row];
    NSLog(@"%@", msg);
    
}


- (void)initializeGroupWithGroup:(Group *)group {
   self.currentGroup = group;
}


#pragma oof

- (void)setupChatBubbles {
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData =
    [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor groupMeBlue]];
    self.incomingBubbleImageData =
    [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor groupMeLightGray]];
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.chatData objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = [self.chatData objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.chatData objectAtIndex:indexPath.item];

    if ([[self.avatarTable allKeys] containsObject:message.senderId]) {
        UIImage *avatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self.avatarTable valueForKey:message.senderId]]];
        UIImage *circularImage = [JSQMessagesAvatarImageFactory circularAvatarHighlightedImage:avatar withDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];

        return [JSQMessagesAvatarImage avatarWithImage:circularImage];
    } else {
        NSMutableString * firstCharacters = [NSMutableString string];
        NSArray * words = [message.senderDisplayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        for (NSString * word in words) {
            if ([word length] > 0) {
                NSString * firstLetter = [word substringToIndex:1];
                [firstCharacters appendString:[firstLetter uppercaseString]];
            }
        }
        return [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:firstCharacters backgroundColor:[UIColor groupMeGray] textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:14] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    }
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.chatData objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.chatData objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatData objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.chatData count];
}


- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.chatData objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                               NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    return cell;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item % 3 == 0) { //Timestamp an item
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *currentMessage = [self.chatData objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatData objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0f;
}

#pragma mark - Group Editing

/*
- (IBAction)didRequestGroupEditView:(id)sender {
    GroupDetailViewController *groupDetailView = [[GroupDetailViewController alloc] init];
    groupDetailView.transitioningDelegate = self;

    groupDetailView.nameField.text = [self.currentGroup groupName];
    groupDetailView.topicField.text = [self.currentGroup groupDescription];
    groupDetailView.groupImageView.image = [self.currentGroup groupImage];
    for (NSDictionary *user in [self.currentGroup members]) {
        CNContact *contact = [[CNContact alloc] init];
        [contact setValue:[user objectForKey:@"name"] forKey:@"givenName"];
        [groupDetailView.contacts addObject:contact];
    }
    
//    DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
    //controller.title = segueToGroup.groupName;
    [groupDetailView setModalPresentationStyle:UIModalPresentationOverCurrentContext];

    [self presentViewController:groupDetailView animated:YES completion:nil];

    //groupDetailView.cre
    //[self presentViewController:newGroupController animated:YES completion: nil];

}*/


@end
