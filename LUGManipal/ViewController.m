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
#import "Reachability.h"
#import "DetailView.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ViewController ()
{    
    NSArray *notificationArray;
    MBProgressHUD *hud;
    PFQuery *query;
    Notifications *notification;
    
    UIRefreshControl * refreshControl;
    UILabel * noDataLabel;
    DetailView * detailView;
    UIView * blurBackgroundView;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *navBarItems;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

//    if (detailView!= nil) {
//        detailView = nil;
//    }
    
    noDataLabel.tag = 1955;
    refreshControl = [[UIRefreshControl alloc]init];
    refreshControl.tintColor = [UIColor blackColor];
    refreshControl.backgroundColor = [UIColor groupTableViewBackgroundColor];
    NSAttributedString * attributeString = [[NSAttributedString alloc]initWithString:@"Loading"];
    refreshControl.attributedTitle = attributeString;
    [refreshControl addTarget:self
                       action:@selector(sendParseRequest)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];

    //Table Will Be added to view after async request is completed
    if ([self connected]) {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"Tap to cancel";
    [hud addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hudWasCancelled)]];
        
        [self sendParseRequest];
        
    }
    
    
    //Observer for Handling Navigation bar hide or show
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BarsShouldHide"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      //hide tab bar with animation;
                                                      [[self navigationController] setNavigationBarHidden:YES animated:YES];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BarsShouldUnhide"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      //Unhide tab bar with animation;
                                                      [[self navigationController] setNavigationBarHidden:NO animated:YES];
                                                  }];
}

-(void)sendParseRequest
{
    query = [Notifications query];
    [query setLimit:1000];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        notificationArray = [NSArray arrayWithArray:objects];
        [self.tableView reloadData];
        [hud hide:YES];
        [refreshControl endRefreshing];
    }];
    
}


#pragma mark - Detail View

-(void)showTheDetailViewWithTitle:(NSString*)title andContent:(NSString*)content
{
    blurBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [blurBackgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeDetailViewAndBlur)]];
    blurBackgroundView.backgroundColor = [UIColor blackColor];
    blurBackgroundView.alpha = 0;
    [self.navigationController.view addSubview:blurBackgroundView];
    
    NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"DetailView" owner:self options:nil];
    detailView = [nib objectAtIndex:0];
    detailView.frame = CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width - 20,350);
    detailView.eventTitleLabel.text =title;
    detailView.eventTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    detailView.detailTextView.text = content;
    [self.navigationController.view addSubview:detailView];
    
    detailView.center = CGPointMake(self.navigationController.view.center.x,self.navigationController.view.center.y);
    detailView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height - 50);
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        blurBackgroundView.alpha = 0.8;
        detailView.transform = CGAffineTransformIdentity;
        
    } completion:nil];
}

-(void)removeDetailViewAndBlur
{
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            blurBackgroundView.alpha = 0;
            detailView.frame = CGRectMake(10, self.view.frame.size.height, self.view.frame.size.width -20, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            blurBackgroundView = nil;
            detailView = nil;
        }];
}
     
#pragma mark - Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self connected]) {
        
        return 1;
//        if ([_tableView.backgroundView isEqual:(UILabel*)[self.view viewWithTag:1955]]) {
//            NSLog(@"Can access the background view");
//        }
    
    }
    else
    {
        noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,  self.view.bounds.size.width, self.view.bounds.size.height)];
        noDataLabel.text = @"No content available.Pull down to refresh";
        noDataLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        noDataLabel.numberOfLines = 0;
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        [noDataLabel sizeToFit];
        self.tableView.backgroundView = noDataLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 0;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [notificationArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * celIdentifier = @"Cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:celIdentifier forIndexPath:indexPath];
    
    
    notification= [notificationArray objectAtIndex:indexPath.row];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.text = notification.title;
    cell.detailTextLabel.text = notification.detail;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self showTheDetailViewWithTitle:[[notificationArray objectAtIndex:indexPath.row] objectForKey:@"title"] andContent:[[notificationArray objectAtIndex:indexPath.row] objectForKey:@"detail"]];
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
    [refreshControl endRefreshing];
}

#pragma mark - Internet Connection

-(BOOL)connected
{
    
    Reachability * reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];

    return !(networkStatus == NotReachable);
    
}

#pragma mark - Scroll Navbar Hide/Show

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BarsShouldHide" object:self];
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                 willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BarsShouldUnhide"
                                                            object:self];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BarsShouldUnhide"
                                                        object:self];
}



@end
