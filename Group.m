//
//  Group.m
//  GroupMe
//
//  Created by Andrew Fischer on 12/13/16.
//  Copyright © 2016 Andrew Fischer. All rights reserved.
//

#import "Group.h"
#import "UIColor+GroupMe.h"
#import <JSQMessagesViewController/JSQMessagesAvatarImageFactory.h>

@implementation Group
@synthesize groupID;
@synthesize groupName;
@synthesize groupLastUpdated;
@synthesize groupImageURL;
@synthesize groupImage;
@synthesize groupDescription;
@synthesize lastSender;
@synthesize lastMessage;
@synthesize members;

-(id)initWithJSONData:(NSDictionary*)data{
    self = [super init];
    if(self){
        
        self.groupID = [data objectForKey:@"group_id"];
        self.groupName =  [data objectForKey:@"name"];
        self.groupDescription = [data objectForKey:@"description"];
        NSDictionary *lastSenderData = [[data objectForKey:@"messages"] objectForKey:@"preview"];
        self.lastSender = [lastSenderData objectForKey:@"nickname"];
        self.lastMessage = [lastSenderData objectForKey:@"text"];
        self.members = [data objectForKey:@"members"];
        self.groupLastUpdated = [data objectForKey:@"updated_at"];
        if ([data objectForKey:@"image_url"] != [NSNull null]){
            self.groupImageURL = [NSURL URLWithString:[data objectForKey:@"image_url"]];
            NSData *groupImageData = [NSData dataWithContentsOfURL:self.groupImageURL];
            self.groupImage = [UIImage imageWithData:groupImageData];
        } else {
            NSMutableString * firstCharacters = [NSMutableString string];
            NSArray * words = [self.groupName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            for (NSString * word in words) {
                if ([word length] > 0) {
                    NSString * firstLetter = [word substringToIndex:1];
                    [firstCharacters appendString:[firstLetter uppercaseString]];
                }
            }
            self.groupImageURL = nil;
            self.groupImage = [[JSQMessagesAvatarImageFactory avatarImageWithUserInitials:firstCharacters backgroundColor:[UIColor groupMeLightBlue] textColor:[UIColor groupMeGray] font:[UIFont systemFontOfSize:18] diameter:50] avatarImage];
        }
        
    }
    return self;
}

@end
