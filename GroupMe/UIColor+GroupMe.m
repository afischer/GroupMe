//
//  UIColor+GroupMe.m
//  GroupMe
//
//  Created by Andrew Fischer on 12/24/16.
//  Copyright © 2016 Andrew Fischer. All rights reserved.
//

#import "UIColor+GroupMe.h"

@implementation UIColor (GroupMe)

+(UIColor *) groupMeBlue {
    return [UIColor colorWithRed:0.f/255.f green:175.f/255.f blue:240.f/255.f alpha:1.f];
}

+(UIColor *) groupMeLightBlue {
    return [UIColor colorWithRed:204.f/255.f green:239.f/255.f blue:252.f/255.f alpha:1.f];
}

+(UIColor *) groupMeWhite {
    return [UIColor whiteColor];
}

+(UIColor *) groupMeGray {
    return [UIColor colorWithRed:130.f/255.f green:130.f/255.f blue:130.f/255.f alpha:1.f];
}

+(UIColor *) groupMeLightGray {
    return [UIColor colorWithRed:230.f/255.f green:230.f/255.f blue:230.f/255.f alpha:1.f];
}
@end
