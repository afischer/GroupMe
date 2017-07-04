//
//  AccountManager.h
//  GroupMe
//
//  Created by Andrew Fischer on 12/29/16.
//  Copyright © 2016 Andrew Fischer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SafariServices/SafariServices.h>


@interface AccountManager : NSObject
+ (void)signInUser;
+ (BOOL)isLoggedIn;
+ (NSString *)getAuthToken;
+ (NSDictionary *)getUserData;
@end
