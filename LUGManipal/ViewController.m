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

@interface ViewController ()
{    
    NSArray * mainArray;
    UITableView * myTable;
    MBProgressHUD * hud;
    PFQuery * query;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    //Table Will Be added to view after async request is completed
    myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    myTable.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    myTable.delegate = self;
    myTable.dataSource = self;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Tap to cancel";
    [hud addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hudWasCancelled)]];
    
    
    query = [PFQuery queryWithClassName:@"Notifications"];
    [query setLimit:1000];


    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSLog(@"Array is %@",[objects objectAtIndex:0]);
        
        mainArray =[[NSArray alloc]initWithArray:objects];
        [myTable reloadData];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.view addSubview:myTable];
    }
     ];
}

-(void)viewDidLayoutSubviews
{
    myTable.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mainArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * celIdentifier = @"Cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:celIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:celIdentifier];
    }
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.text = [[mainArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.text = [[mainArray objectAtIndex:indexPath.row] objectForKey:@"detail"];
    
    
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
    UIView * blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    blankView.backgroundColor = [UIColor clearColor];
    return blankView;
}

-(void)hudWasCancelled
{
    [query cancel];
    [hud hide:YES];
}
@end
