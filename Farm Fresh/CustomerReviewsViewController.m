//
//  CustomerReviewsViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/23/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "CustomerReviewsViewController.h"
#import "PostReviewViewController.h"
#import "HelperMethods.h"
#import "ChatLabel.h"

@interface CustomerReviewsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *reviewTableView;
@property (nonatomic, strong) NSArray *allMessages;
@property (nonatomic, strong) NSDictionary *allMessagesDic;
@property (nonatomic, strong) FIRDatabaseReference *reviewRef;
@property (weak, nonatomic) IBOutlet UIButton *postReviewButton;
@end

@implementation CustomerReviewsViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reviewTableView.delegate = self;
    self.reviewTableView.dataSource = self;
    
    if(self.isViewingAlert)
        self.postReviewButton.hidden = YES;
    else if([self.farmerSelected[@"farmerID"] isEqualToString:self.userData.user.uid])
        self.postReviewButton.hidden = YES;
    
    [self setupFirebase];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Customer_Reviews_Screen_Loaded" parameters:@{
                                                                                  @"Farmer_Selected" : self.farmerSelected[@"farmerID"]
                                                                                  }];
}

#pragma mark - IBActions

- (IBAction)backButtonPressed:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Methods

- (void)setupFirebase
{
    
    if(self.userData.user.uid)
    {
        self.reviewRef = [self.userData.ref child:[NSString stringWithFormat:@"/farms/%@/reviews/", [self.farmerSelected objectForKey:@"farmerID"]]];
        
        
        
        [self.reviewRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            if(snapshot.value == [NSNull null]) {
                NSLog(@"No messages");
                
                
            } else {
                
                
                NSDictionary *value = snapshot.value;
                //NSLog(@"Unsorted allKeys: %@", value.allKeys);
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedCompare:)];
                NSArray *sortedAllKeys = [value.allKeys sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                //NSLog(@"Sorted allKeys: %@", sortedAllKeys);
                
                self.allMessages = sortedAllKeys;
                self.allMessagesDic = snapshot.value;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //self.loadingIndicatorView.hidden = true;
                    //[self.loadingActivityIndicator stopAnimating];
                    
                 
                [self.reviewTableView reloadData];
                       
                });
                
                
                
                
            }
        }];
        
       
    }
    
    
    
    
}

#pragma mark - Delegate Methods

#pragma mark - Table view data source


// put ur height calculation method i took some hardcoded values change it :)
-(CGFloat)heightForText:(NSString *)text andFontSize:(CGFloat)fontSize andWidth:(CGFloat)width
{
    NSInteger MAX_HEIGHT = 2000;
    UITextView * textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, width, MAX_HEIGHT)];
    textView.text = text;
    textView.font = [UIFont systemFontOfSize:fontSize];
    [textView sizeToFit];
    return textView.frame.size.height;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat heightOfcell = [self heightForText:[[self.allMessagesDic objectForKey:[self.allMessages objectAtIndex:indexPath.row]] objectForKey:@"reviewText"] andFontSize:13.0 andWidth:self.view.frame.size.width - 40];
    NSLog(@"%f",heightOfcell);
    
    
    return 33 + heightOfcell;
    
}

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
    return  [self.allMessages count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"reviewCell";
  
    
    UITableViewCell *cell;
    
    
    NSDictionary *tempDic = [self.allMessagesDic objectForKey:[self.allMessages objectAtIndex:indexPath.row]];
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
   

    UILabel *timeLabel = (UILabel *)[cell viewWithTag:2];
    
    timeLabel.text = [NSString stringWithFormat:@"Submitted %@ ago",[HelperMethods getTimeSinceDate:tempDic[@"reviewDate"]]];
    
    
    
    NSInteger MAX_HEIGHT = 2000;
    UILabel *messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, MAX_HEIGHT)];
    
    UILabel *tempLabel = (UILabel* )[cell viewWithTag:5];
    if(tempLabel)
        [tempLabel removeFromSuperview];
    
    messageLabel.text = tempDic[@"reviewText"];
    
    [messageLabel setFont:[UIFont systemFontOfSize:13.0f]];
    UITextView * textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width - 40, MAX_HEIGHT)];
    textView.text = tempDic[@"reviewText"];
    textView.font = [UIFont systemFontOfSize:13];
    [textView sizeToFit];
    
    [messageLabel setTag:5];
    CGRect frame = messageLabel.frame;
    frame.size.width = textView.frame.size.width;
    frame.size.height = textView.frame.size.height;
    frame.origin.x = 20;
    frame.origin.y = 10;
    frame.size.width += 10;
    if(frame.size.width > self.view.frame.size.width - 40)
    {
        frame.size.width = self.view.frame.size.width - 40;
        
    }
    messageLabel.numberOfLines = 100;
    [messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
    messageLabel.frame = frame;
    [messageLabel.layer setCornerRadius:10.0f];
    [messageLabel setClipsToBounds:YES];
    
    
    [cell addSubview:messageLabel];
    
    int rating = [tempDic[@"reviewRating"]intValue];
    
    
    UIImageView *star5 = (UIImageView *)[cell viewWithTag:14];
    UIImageView *star4 = (UIImageView *)[cell viewWithTag:13];
    UIImageView *star3 = (UIImageView *)[cell viewWithTag:12];
    UIImageView *star2 = (UIImageView *)[cell viewWithTag:11];
    UIImageView *star1 = (UIImageView *)[cell viewWithTag:10];
    star1.hidden = false;
    star2.hidden = false;
    star3.hidden = false;
    star4.hidden = false;
    star5.hidden = false;
    
    
    switch(rating)
    {
        case 1:
            star1.image = [UIImage imageNamed:@"halfStar"];
            break;
        case 2:
            star1.image = [UIImage imageNamed:@"fullStar"];
            break;
        case 3:
            star1.image = [UIImage imageNamed:@"fullStar"];
            star2.image = [UIImage imageNamed:@"halfStar"];
            break;
        case 4:
            star1.image = [UIImage imageNamed:@"fullStar"];
            star2.image = [UIImage imageNamed:@"fullStar"];
            break;
        case 5:
            star1.image = [UIImage imageNamed:@"fullStar"];
            star2.image = [UIImage imageNamed:@"fullStar"];
            star3.image = [UIImage imageNamed:@"halfStar"];
            break;
        case 6:
            star1.image = [UIImage imageNamed:@"fullStar"];
            star2.image = [UIImage imageNamed:@"fullStar"];
            star3.image = [UIImage imageNamed:@"fullStar"];
            break;
        case 7:
            star1.image = [UIImage imageNamed:@"fullStar"];
            star2.image = [UIImage imageNamed:@"fullStar"];
            star3.image = [UIImage imageNamed:@"fullStar"];
            star4.image = [UIImage imageNamed:@"halfStar"];
            break;
        case 8:
            star1.image = [UIImage imageNamed:@"fullStar"];
            star2.image = [UIImage imageNamed:@"fullStar"];
            star3.image = [UIImage imageNamed:@"fullStar"];
            star4.image = [UIImage imageNamed:@"fullStar"];
            break;
        case 9:
            star1.image = [UIImage imageNamed:@"fullStar"];
            star2.image = [UIImage imageNamed:@"fullStar"];
            star3.image = [UIImage imageNamed:@"fullStar"];
            star4.image = [UIImage imageNamed:@"fullStar"];
            star5.image = [UIImage imageNamed:@"halfStar"];
            break;
        case 10:
            star1.image = [UIImage imageNamed:@"fullStar"];
            star2.image = [UIImage imageNamed:@"fullStar"];
            star3.image = [UIImage imageNamed:@"fullStar"];
            star4.image = [UIImage imageNamed:@"fullStar"];
            star5.image = [UIImage imageNamed:@"fullStar"];
            break;
       
    }
    
    
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if([segue.identifier isEqualToString:@"postReviewSegue"])
    {
        
        PostReviewViewController *vc = segue.destinationViewController;
            
        vc.userData = self.userData;
        vc.farmerSelected = self.farmerSelected;
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
