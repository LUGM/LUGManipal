//
//  Notification.h
//  LUGManipal
//
//  Created by Ankit Aggarwal on 15/10/14.
//  Copyright (c) 2014 LUG. All rights reserved.
//

#import <Parse/Parse.h>

@interface Notifications : PFObject <PFSubclassing>

@property (retain) NSString *detail;
@property (retain) NSString *title;

+ (NSString *)parseClassName;

@end
