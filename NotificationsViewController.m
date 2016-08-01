//
//  NotificationsViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/22/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "NotificationsViewController.h"
#import "Firebase.h"
#import "HelperMethods.h"
#import "Constants.h"

@interface NotificationsViewController ()<UITableViewDelegate, UITableViewDataSource, UserModelDelegate>

@property (nonatomic, strong) NSArray *notifications;
@property (weak, nonatomic) IBOutlet UITableView *notificationsTableView;

@end

@implementation NotificationsViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.notificationsTableView.delegate = self;
    self.notificationsTableView.dataSource = self;
    self.userData.delegate = self;
    
    [self.userData getUsersNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Notifications_Screen_Loaded" parameters:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.userData clearNotifications];
    
}

#pragma mark - IBActions

- (IBAction)menuButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Methods

- (void)notificationsLoaded:(NSArray *)notificaitons
{
    
    
    NSSortDescriptor *categoryDescriptor = [[NSSortDescriptor alloc] initWithKey:@"alertTimeSent" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:categoryDescriptor];
    self.notifications = [notificaitons sortedArrayUsingDescriptors:sortDescriptors];
    
    [self.notificationsTableView reloadData];
}

- (void)loadProductImageAtIndex:(NSIndexPath *)path forImage:(UIImageView *)imageView withActivityIndicator:(UIActivityIndicatorView *)spinner
{
    NSDictionary *tempDic = [self.notifications objectAtIndex:path.row];
    NSString *fileName = [NSString stringWithFormat:@"%@_1.png",[tempDic objectForKey:@"productID"]];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir,fileName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
            [spinner stopAnimating];
        });
        
    }
    else
    {
        
        // Create a reference to the file you want to download
        FIRStorageReference *fileRef = [[[FIRStorage storage] reference] child:[NSString stringWithFormat:@"%@/farm/products/%@/images/%@", tempDic[@"fromUserID"], tempDic[@"productID"], fileName]];
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        [fileRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
            if (error != nil) {
                // Uh-oh, an error occurred!
                [spinner stopAnimating];
            } else {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
                [data writeToFile:filePath atomically:YES];
                
                UIImage *image = [UIImage imageWithData:data];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    imageView.image = image;
                    
                    [spinner stopAnimating];
                });
                
            }
            
        }];
        
        
        
    }
    
}

#pragma mark - Delegate Methods

#pragma mark - Table view data source

/*
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.layer.cornerRadius = 10;
    cell.layer.masksToBounds = YES;
}
 */

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
    return self.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"notificationCell";
    static NSString *noResultsCellIdentifier = @"noResultsCell";
    
    UITableViewCell *cell;
    
    
    if(self.notifications.count == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:noResultsCellIdentifier forIndexPath:indexPath];
    }
    else
    {
        NSDictionary *tempDic = [self.notifications objectAtIndex:indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIImageView *notificationsImageView = (UIImageView *)[cell viewWithTag:1];
        UILabel *farmNameLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *notificationMessage = (UILabel *)[cell viewWithTag:3];
        UILabel *sentDate = (UILabel *)[cell viewWithTag:4];
        
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell.contentView viewWithTag:5];
        
        [self loadProductImageAtIndex:indexPath forImage:notificationsImageView withActivityIndicator:spinner];
        
        
        
        farmNameLabel.text = tempDic[@"farmName"];
        
        NSString *alertText = [tempDic[@"alertText"] stringByReplacingOccurrencesOfString:tempDic[@"farmName"] withString:@""];
        
        notificationMessage.text = [NSString stringWithFormat:@"    %@%@",[[alertText substringToIndex:2] uppercaseString],[alertText substringFromIndex:2] ];
        
        sentDate.text = [HelperMethods formatSentDateForNotifications:tempDic[@"alertTimeSent"]];
        
        
        
        notificationsImageView.layer.cornerRadius = 30.0f;
        notificationsImageView.layer.masksToBounds = YES;
    }
    
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.notifications.count != 0)
    {
         NSDictionary *tempDic = [self.notifications objectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:ALERT_RECIEVED];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:SCREEN_TO_LOAD];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSUserDefaults standardUserDefaults] setObject: tempDic[@"productID"] forKey:@"productID"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:tempDic[@"fromUserID"] forKey:@"fromUserID"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Navigation



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
