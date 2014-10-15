//
//  ViewController.m
//  LUGManipal
//
//  Created by Shubham Sorte on 14/10/14.
//  Copyright (c) 2014 LUG. All rights reserved.
//

#import <Parse/Parse.h>
#import "ViewController.h"
#import "MBProgressHUD.h"
#import "Notifications.h"

@interface ViewController ()
{    
    NSArray *notificationArray;
    MBProgressHUD *hud;
    PFQuery *query;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    //Table Will Be added to view after async request is completed
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Tap to cancel";
    [hud addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hudWasCancelled)]];
    
    query = [Notifications query];
    [query setLimit:1000];


    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSLog(@"Array is %@",[objects objectAtIndex:0]);
        
        notificationArray = [NSArray arrayWithArray:objects];
        [self.tableView reloadData];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [hud hide:YES];
    }];
}

#pragma mark - Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [notificationArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * celIdentifier = @"Cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:celIdentifier forIndexPath:indexPath];
    
    
    Notifications *notification = [notificationArray objectAtIndex:indexPath.row];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.text = notification.title;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.text = notification.detail;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

-(void)hudWasCancelled
{
    [query cancel];
    [hud hide:YES];
}
@end
