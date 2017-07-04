//
//  Group.h
//  GroupMe
//
//  Created by Andrew Fischer on 12/13/16.
//  Copyright © 2016 Andrew Fischer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Group : NSObject
-(id)initWithJSONData:(NSDictionary*)data;
@property (assign) NSString *groupID;
@property (strong) NSString *groupName;
@property (assign) NSString *groupLastUpdated;
@property (strong, nonatomic) NSURL *groupImageURL;
@property (strong) UIImage *groupImage;
@property (strong) NSString *groupDescription;
@property (strong) NSString *lastSender;
@property (strong) NSString *lastMessage;
@property (strong) NSMutableDictionary *members;

@end
