//
//  AccountManager.m
//  GroupMe
//
//  Created by Andrew Fischer on 12/29/16.
//  Copyright © 2016 Andrew Fischer. All rights reserved.
//

#import "AccountManager.h"
#import "Lockbox.h"

@implementation AccountManager
#pragma mark - Auth
+ (void)signInUser {
    NSURL *oAuthURL = [NSURL URLWithString:@"https://oauth.groupme.com/oauth/authorize?client_id=ArUTvcq7X9Nkt0xJTnkP1wPXfAuOCSNB3lE6ZvxbxGAdDKkr"];
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:oAuthURL];
    if (oAuthURL) {
        if ([SFSafariViewController class] != nil) {
            UIViewController *rootVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
            [rootVC presentViewController:sfvc animated:YES completion:nil];
        } else {
            NSLog(@"Oh no can't open url because no safari view controller");
        }
    } else {
        // will have a nice alert displaying soon.
    }
}

+ (BOOL)isLoggedIn {
    if ([Lockbox unarchiveObjectForKey:@"oAuthToken"]) {
        return YES;
    }
    return NO;
}

+ (NSString *)getAuthToken {
    if ([AccountManager isLoggedIn]) {
        return [Lockbox unarchiveObjectForKey:@"oAuthToken"];
    } else {
        [NSException raise:@"GroupMe Not logged in" format:@"User is not logged in to GroupMe"];
    }
    return nil;
}

+ (NSDictionary *)getUserData {
    NSAssert([AccountManager isLoggedIn], @"Error! User must be logged in before attempting to access data");
    if (![Lockbox unarchiveObjectForKey:@"userData"]) {
        NSMutableString *URLString = [[NSMutableString alloc] init];
        [URLString appendString:@"https://api.groupme.com/v3/users/me?token="];
        [URLString appendString:[AccountManager getAuthToken]];
        NSError* error = nil;
        NSLog(@"%@", URLString);
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:URLString] options:NSDataReadingUncached error:&error];
        NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", userData);
        [Lockbox archiveObject:[userData objectForKey:@"response"] forKey:@"userData"];
    }
    return [Lockbox unarchiveObjectForKey:@"userData"];
}

@end
