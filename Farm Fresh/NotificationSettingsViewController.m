//
//  NotificationSettingsViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/23/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "NotificationSettingsViewController.h"
#import "UIView+AddOns.h"

@interface NotificationSettingsViewController () <UITableViewDelegate, UITableViewDataSource, UserModelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *notificationTableView;

@end

@implementation NotificationSettingsViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userData.delegate = self;
    self.notificationTableView.delegate = self;
    self.notificationTableView.dataSource = self;
    
    [self.userData updateFavoriteFarmersData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Notification_Settings_Screen_Loaded" parameters:nil];
}

#pragma mark - IBActions

- (IBAction)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Methods

- (void)notificationSwitchedForFarmer:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    UIView *myView = (UIView *)theSwitch.superview;
    
    UITableViewCell *cell = (UITableViewCell *)myView.superview;
    
    NSIndexPath *indexPath = [self.notificationTableView indexPathForCell:cell];
    
    [self.userData changeFavoriteFarmer:[[self.userData.favoriteFarmersData objectAtIndex:indexPath.row]objectForKey:@"farmerID"] withNotificationStatus:theSwitch.isOn];
}

#pragma mark - Delegate Methods

-(void)favoriteFarmersUpdated
{
    [self.notificationTableView reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  
    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.userData.favoriteFarmersData.count == 0)
        return 1;
    else
        return self.userData.favoriteFarmersData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"notificationCell";
    static NSString *noResultsCellIdentifier = @"noResultsCell";
    
    UITableViewCell *cell;
    
    
    if(self.userData.favoriteFarmersData.count == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:noResultsCellIdentifier forIndexPath:indexPath];
    }
    else
    {
        NSDictionary *tempDic = [self.userData.favoriteFarmersData objectAtIndex:indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UISwitch *notificationSwitch = (UISwitch *)[cell viewWithTag:2];
        UILabel *farmNameLabel = (UILabel *)[cell viewWithTag:1];
        
        farmNameLabel.text = tempDic[@"farmName"];
        [notificationSwitch setOn:[self.userData getNotificationStatusForFarmer:tempDic[@"farmerID"]]];
        
        [notificationSwitch addTarget:self action:@selector(notificationSwitchedForFarmer:) forControlEvents:UIControlEventValueChanged];
    }
    
    
    
    
    return cell;
}


#pragma mark - Navigation



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
