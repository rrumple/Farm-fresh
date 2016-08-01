//
//  FavoritesViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/22/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "FavoritesViewController.h"
#import "FarmProfileViewController.h"
#import "HelperMethods.h"

@interface FavoritesViewController ()<UITableViewDataSource, UITableViewDelegate, UserModelDelegate>
@property (weak, nonatomic) IBOutlet UITableView *favoritesTableView;
@property (nonatomic) BOOL isFavoritesDoneLoading;

@end

@implementation FavoritesViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userData.delegate = self;
    self.favoritesTableView.delegate = self;
    self.favoritesTableView.dataSource = self;
    
    self.isFavoritesDoneLoading = NO;
    
    [self.userData updateFavoriteFarmersData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Favorites_Screen_Loaded" parameters:nil];
}

#pragma mark - IBActions

- (IBAction)menuButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Methods

- (void)loadFarmProfileImageAtIndex:(NSIndexPath *)path forImage:(UIImageView *)imageView withActivityIndicator:(UIActivityIndicatorView *)spinner
{
    NSDictionary *tempDic = [self.userData.favoriteFarmersData objectAtIndex:path.section];
    NSString *fileName = [NSString stringWithFormat:@"%@_farmProfile.png",[tempDic objectForKey:@"farmerID"]];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@_farmProfile.png",docDir, tempDic[@"farmerID"]];
    
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
        FIRStorageReference *fileRef = [[[FIRStorage storage] reference] child:[NSString stringWithFormat:@"%@/farm/products/%@/images/%@", tempDic[@"farmerID"], tempDic[@"productID"], fileName]];
        
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

-(void)favoriteFarmersUpdated
{
    self.isFavoritesDoneLoading = YES;
    [self.favoritesTableView reloadData];
}

#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.layer.cornerRadius = 10;
    cell.layer.masksToBounds = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.isFavoritesDoneLoading)
    {
        if(self.userData.favoriteFarmersData.count == 0)
            return 1;
        else
            return self.userData.favoriteFarmersData.count;
    }
    else
        return 0;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isFavoritesDoneLoading)
        return 1;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"farmCell";
    static NSString *noResultsCellIdentifier = @"noResultsCell";
    
    UITableViewCell *cell;
    
    
    if(self.userData.favoriteFarmersData.count == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:noResultsCellIdentifier forIndexPath:indexPath];
    }
    else
    {
        NSDictionary *tempDic = [self.userData.favoriteFarmersData objectAtIndex:indexPath.section];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIImageView *farmerProfileImageView = (UIImageView *)[cell viewWithTag:5];
        UILabel *farmNameLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *farmDescriptionLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *distanceToFarmLabel = (UILabel *)[cell viewWithTag:3];
        UILabel *openClosedLabel = (UILabel *)[cell viewWithTag:4];
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell.contentView viewWithTag:13];
        farmerProfileImageView.image = [UIImage imageNamed:@"profile"];
        spinner.hidden = NO;
        [self loadFarmProfileImageAtIndex:indexPath forImage:farmerProfileImageView withActivityIndicator:spinner];
        
        farmNameLabel.text = tempDic[@"farmName"];
        farmDescriptionLabel.text = tempDic[@"farmDescription"];
        
        distanceToFarmLabel.text = tempDic[@"distanceToFarmString"];
        
        int rating = [tempDic[@"rating"]intValue];
        openClosedLabel.text = @"CLOSED";
        
        if(![tempDic[@"activeLocation"] isEqualToString:@""])
        {
            NSMutableDictionary *day = [[tempDic[@"schedule"] objectForKey:[NSString stringWithFormat:@"%ld", (long)[HelperMethods getWeekday]]]mutableCopy];
            
            if([day[@"locationID"] isEqualToString:tempDic[@"activeLocation"]])
            {
                    if([HelperMethods isLocationOpen:day[@"openTime"] closed:day[@"closeTime"]])
                    {
                        openClosedLabel.text = @"OPEN";
                    }
            }
        }
        
        UILabel *noRatingLabel = (UILabel *)[cell viewWithTag:11];
        UIImageView *star5 = (UIImageView *)[cell viewWithTag:10];
        UIImageView *star4 = (UIImageView *)[cell viewWithTag:9];
        UIImageView *star3 = (UIImageView *)[cell viewWithTag:8];
        UIImageView *star2 = (UIImageView *)[cell viewWithTag:7];
        UIImageView *star1 = (UIImageView *)[cell viewWithTag:6];
        star1.hidden = false;
        star2.hidden = false;
        star3.hidden = false;
        star4.hidden = false;
        star5.hidden = false;
        noRatingLabel.hidden = true;
        
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
            case 99:
                star1.hidden = true;
                star2.hidden = true;
                star3.hidden = true;
                star4.hidden = true;
                star5.hidden = true;
                noRatingLabel.hidden = false;
                break;
        }
        
        
        farmerProfileImageView.layer.cornerRadius = 30.0f;
        farmerProfileImageView.layer.masksToBounds = YES;
    }
    
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.userData.favoriteFarmersData.count != 0)
    {
        self.userData.searchResultSelected = indexPath.section;
        
        [self performSegueWithIdentifier:@"farmerProfileSegue" sender:self];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString: @"farmerProfileSegue"])
    {
        FarmProfileViewController *fpvc = segue.destinationViewController;
        
        fpvc.userData = self.userData;
        fpvc.showMoreProducts = false;
        fpvc.showingFavoriteFarmer = true;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
