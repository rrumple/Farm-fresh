//
//  ChatMenuViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/22/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "ChatMenuViewController.h"
#import "ChatMessagesViewController.h"

@interface ChatMenuViewController () <UITableViewDelegate, UITableViewDataSource, UserModelDelegate>
@property (weak, nonatomic) IBOutlet UITableView *chatMenuTableView;
@property (nonatomic, strong) NSArray *chatFarmers;
@property (nonatomic) NSDictionary *farmerSelected;
@property (nonatomic) NSInteger sectionSelected;
@property (nonatomic, strong) UIFontDescriptor* boldFontDescriptor;
@property (nonatomic, strong) UIFontDescriptor* fontDescriptor;
@property (nonatomic, strong) NSArray *notificationsNew;

@property (nonatomic, strong) FIRDatabaseReference *userRef;
@property (nonatomic, strong) FIRDatabaseReference *recRef;
@property (nonatomic, strong) FIRDatabaseReference *userNotificationRef;
@property (nonatomic, strong) FIRDatabaseReference *recNotificationRef;

@end

@implementation ChatMenuViewController

- (NSArray *)notificationsNew
{
    if(!_notificationsNew) _notificationsNew = [[NSArray alloc]init];
    return _notificationsNew;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatMenuTableView.delegate = self;
    self.chatMenuTableView.dataSource = self;
    self.userData.delegate = self;
    
    self.fontDescriptor = [UIFontDescriptor
                           preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    self.boldFontDescriptor = [self.fontDescriptor
                               fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    //[self.userData updateFavoriteFarmersData];
    [self setupFirebase];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     [FIRAnalytics logEventWithName:@"Chat_Menu_Screen_Loaded" parameters:nil];
    
    [self getNewNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.userNotificationRef removeAllObservers];
    
    self.notificationsNew = nil;
    [self.chatMenuTableView reloadData];
}
#pragma mark - IBActions

- (IBAction)menuButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Methods

- (void)getNewNotifications
{
    
    
    [self.userNotificationRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot2) {
        
        if(snapshot2.value == [NSNull null]) {
            NSLog(@"No messages");
            self.notificationsNew = [[NSArray alloc]init];
            [self.chatMenuTableView reloadData];
            
        } else {
            NSDictionary *value1 = snapshot2.value;
            NSArray *keys = value1.allKeys;
            NSMutableArray *values = [[NSMutableArray alloc]init];
            
            for(NSString *key in keys)
            {
                
                NSDictionary *tempDic = [value1 objectForKey:key];
                [values addObject:[tempDic objectForKey:@"userID"]];
                
            }
            
            self.notificationsNew = values;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.notificationsNew count] != 0)
                    [self.chatMenuTableView reloadData];
            });
            
        }
        
    }];

}

- (void)setupFirebase
{
    if(self.userData.user.uid)
    {
        self.userRef = [self.userData.ref child:[NSString stringWithFormat:@"/messages/%@-%@", self.userData.user.uid, [self.farmerSelected objectForKey:@"userID"]]];
        self.recRef = [self.userData.ref child:[NSString stringWithFormat:@"/messages/%@-%@", [self.farmerSelected objectForKey:@"userID"], self.userData.user.uid]];
        self.userNotificationRef = [self.userData.ref child:[NSString stringWithFormat:@"/notification/%@", self.userData.user.uid]];
        self.recNotificationRef = [self.userData.ref child:[NSString stringWithFormat:@"/notification/%@", [self.farmerSelected objectForKey:@"userID"]]];
        
        

    }
    
    
    
    
    
}

- (void)favoriteFarmersUpdated
{
    self.chatFarmers = [self.userData getFarmersThatChat];
    
    [self.chatMenuTableView reloadData];
}


#pragma mark - Delegate Methods

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.userData.chatList.count == 0 && self.userData.chatFollowers.count > 0 && section == 0)
        return @"Customers";
    else
    {
        switch (section) {
            case 0:
                return @"Farms";
                break;
            case 1:
                return @"Customers";
                break;
            default:
                return @"";
                break;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    if(self.userData.chatList.count > 0 && self.userData.chatFollowers.count > 0)
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.userData.chatList.count == 0 && self.userData.chatFollowers.count > 0 && section == 0)
        return self.userData.chatFollowers.count;
    else
    {
        switch (section) {
            case 0:
                return self.userData.chatList.count;
                break;
            case 1:
                return self.userData.chatFollowers.count;
                break;
            default:
                return 0;
                break;
        }
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"chatMenuCell";
    
    UITableViewCell *cell;
    
    

    NSDictionary *tempDic;
    if(self.userData.chatList.count == 0 && self.userData.chatFollowers.count > 0 && indexPath.section == 0)
        tempDic = [self.userData.chatFollowers objectAtIndex:indexPath.row];
    else
    {
        switch (indexPath.section) {
            case 0:
                tempDic = [self.userData.chatList objectAtIndex:indexPath.row];
                break;
            case 1:
                tempDic = [self.userData.chatFollowers objectAtIndex:indexPath.row];
                break;
            default:
                break;
        }
    }
    
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel *farmNameLabel = (UILabel *)[cell viewWithTag:1];
    farmNameLabel.text = tempDic[@"name"];
    UIImageView *chatImage = (UIImageView *)[cell viewWithTag:2];
    
     [farmNameLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody ]];
    chatImage.hidden = true;
    for(NSString *userID in self.notificationsNew)
    {
        if([userID isEqualToString:[tempDic objectForKey:@"userID"]])
        {
            chatImage.hidden = false;
            [farmNameLabel setFont:[UIFont fontWithDescriptor:self.boldFontDescriptor size:0.0]];
        }
        
    }

    
    
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.userData.chatList.count == 0 && self.userData.chatFollowers.count > 0 && indexPath.section == 0)
    {
        self.farmerSelected = [self.userData.chatFollowers objectAtIndex:indexPath.row];
        self.sectionSelected = 1;
        [self performSegueWithIdentifier:@"chatMessagesSegue" sender:self];
    }
    else
    {
        self.sectionSelected = indexPath.section;
        
        switch (indexPath.section) {
            case 0:
                if(self.userData.chatList.count > 0)
                {
                    self.farmerSelected = [self.userData.chatList objectAtIndex:indexPath.row];
                    [self.userData addUserToFarmersChatList:self.farmerSelected[@"userID"] isFavoriting:NO];
                }
                break;
            case 1:
                if(self.userData.chatFollowers.count > 0)
                    self.farmerSelected = [self.userData.chatFollowers objectAtIndex:indexPath.row];
                break;
            default:
                break;
        }
        if(self.farmerSelected)
            [self performSegueWithIdentifier:@"chatMessagesSegue" sender:self];
    }

   
}


#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"chatMessagesSegue"])
    {
        ChatMessagesViewController *vc = segue.destinationViewController;
        vc.userData = self.userData;
        vc.userSelected = self.farmerSelected;
        vc.userType = self.sectionSelected;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
