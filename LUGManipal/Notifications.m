//
//  Notification.m
//  LUGManipal
//
//  Created by Ankit Aggarwal on 15/10/14.
//  Copyright (c) 2014 LUG. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "Notifications.h"

@implementation Notifications

@dynamic detail;
@dynamic title;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Notifications";
}

@end
