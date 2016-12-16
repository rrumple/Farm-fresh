//
//  HomeViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/5/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "HomeViewController.h"
/* google
#import <GoogleSignIn/GoogleSignIn.h>
 */
#import "Firebase.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import "MainMenuviewController.h"
#import "UIView+AddOns.h"
#import "UserModel.h"
#import "FarmEditViewController.h"
#import "FilterOptionsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ProductViewController.h"
#import "HelperMethods.h"
#import "ChatMessagesViewController.h"
#import "SignUpViewController.h"
#import "CustomerReviewsViewController.h"
#import "EditProductViewController.h"


@interface HomeViewController () <CLLocationManagerDelegate,UserModelDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *produceTableView;
@property (nonatomic, strong) FIRDatabaseReference *ref;
@property (nonatomic) BOOL isLogin;
@property (nonatomic, strong) UserModel *userData;
@property (weak, nonatomic) IBOutlet UISearchBar *produceSearchBar;

@property (weak, nonatomic) IBOutlet UILabel *gpsCoordsForSearch;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSearchesPerformedLabel;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic) int searchCounter;

@property (nonatomic) BOOL runOnce;

@property (weak, nonatomic) IBOutlet UILabel *searchRadiusLabel;
@property (weak, nonatomic) IBOutlet UIView *spinnerView;
@property (weak, nonatomic) IBOutlet UILabel *spinnerViewLabel;
@property (nonatomic) BOOL successfulSearch;
@property (nonatomic, strong) NSArray *filteredSearchResults;
@property (nonatomic) BOOL useFilteredResults;

@property (nonatomic) BOOL isLocationServicesDisabled;
@property (nonatomic) BOOL isSearching;
@property (nonatomic) BOOL isFirstLoad;
@property (nonatomic, strong) NSTimer *gpsTimer;
@property (nonatomic) BOOL isGPSError;
@property (nonatomic) double radius;
@property (nonatomic) BOOL isFavorite;

@end

@implementation HomeViewController

- (UserModel *)userData
{
    if(!_userData) _userData = [[UserModel alloc]init];
    return _userData;
}

#pragma mark - View Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ref =[[FIRDatabase database] reference];
    
    self.produceTableView.delegate = self;
    self.produceTableView.dataSource = self;
    self.produceSearchBar.delegate = self;
    
    self.userData.delegate = self;
    
    
    self.successfulSearch = NO;
    self.useFilteredResults = NO;
    self.searchCounter = 0;
    self.isSearching = NO;
    self.isFirstLoad = YES;
    
  
    

    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.produceTableView addSubview:refreshControl];
    
    [self.view addGestureRecognizer:[UIView setupTapGestureWithTarget:self Action:@selector(hideKeyboard) cancelsTouchesInview:NO setDelegate:YES]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appHasGoneInBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification) name:@"ProcessNotification" object:nil];

}

- (void)appHasGoneInBackground
{
    [self.userData checkSearchTimer];
    [self.userData stopSearchingForProducts];
    self.isSearching = NO;
    
    self.successfulSearch = NO;
    self.runOnce = false;
  
    NSLog(@"APP WENT IN BACKGROUND");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
  
}

- (void)appWillEnterForeground
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appHasGoneInBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification) name:@"ProcessNotification" object:nil];
    
    self.isFavorite = NO;
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        {
            self.isLocationServicesDisabled = YES;
            self.spinnerView.hidden = YES;
            [self.produceTableView reloadData];
        }
        else
        {
            self.isLocationServicesDisabled = NO;
            self.locationManager.delegate = self;
            
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            
            // Set a movement threshold for new events.
            self.locationManager.distanceFilter = 500; // meters
           //[self startASearch];
            
            //self.spinnerView.hidden = NO;
            self.runOnce = false;
        }
        
    } else {
        NSLog(@"Location services are not enabled");
        self.isLocationServicesDisabled = YES;
        [self.produceTableView reloadData];
    }
    
    [self.userData updateUserStatus];
    
    
    
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Home_Screen_Loaded" parameters:nil];
    
    self.userData.delegate = self;
    self.isSearching = NO;
    self.isFavorite = NO;
    self.isGPSError = NO;
   
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:ALERT_RECIEVED]boolValue])
    {
        self.isSearching = NO;
        switch ([[[NSUserDefaults standardUserDefaults] objectForKey:SCREEN_TO_LOAD]intValue]) {
            case 1:
                [self.userData updateFavoriteFarmersData];
                [self performSegueWithIdentifier:@"showProductSegue" sender:self];
                self.isFavorite = YES;
                break;
            case 2:
                
                [self performSegueWithIdentifier:@"chatNotificationSegue" sender:self];
                break;
            case 3:
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:ALERT_RECIEVED];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SCREEN_TO_LOAD];
                [[NSUserDefaults standardUserDefaults]synchronize];

                [self performSegueWithIdentifier:@"HomeToReviewsSegue" sender:self];
                break;
            case 4:
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:ALERT_RECIEVED];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SCREEN_TO_LOAD];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                [self performSegueWithIdentifier:@"HomeToEditProductsSegue" sender:self];
                break;
            default:
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:ALERT_RECIEVED];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SCREEN_TO_LOAD];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                break;
                
        }
    }
    else
    {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestWhenInUseAuthorization];
        
        if ([CLLocationManager locationServicesEnabled]) {
            
            if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied)
            {
                self.isLocationServicesDisabled = YES;
                self.spinnerView.hidden = YES;
            }
            else
            {
                self.isLocationServicesDisabled = NO;
                self.locationManager.delegate = self;
                
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                
                // Set a movement threshold for new events.
                self.locationManager.distanceFilter = 500; // meters
                
                 //self.spinnerView.hidden = NO;
                self.runOnce = false;
            }
            
        } else {
            NSLog(@"Location services are not enabled");
            self.isLocationServicesDisabled = YES;
        }
    
        
    }
    
    [self.userData updateUserStatus];
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.userData stopSearchingForProducts];
    self.isSearching = NO;
     
    
    
}

#pragma mark - IBActions

#pragma mark - Methods

- (void)processNotification
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:ALERT_RECIEVED]boolValue])
    {
        self.isSearching = NO;
        switch ([[[NSUserDefaults standardUserDefaults] objectForKey:SCREEN_TO_LOAD]intValue]) {
            case 1:
                [self.userData updateFavoriteFarmersData];
                [self performSegueWithIdentifier:@"showProductSegue" sender:self];
                self.isFavorite = YES;
                break;
            case 2:
                [self performSegueWithIdentifier:@"chatNotificationSegue" sender:self];
                break;
            case 3:
                [self performSegueWithIdentifier:@"HomeToReviewsSegue" sender:self];
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:ALERT_RECIEVED];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SCREEN_TO_LOAD];
                [[NSUserDefaults standardUserDefaults]synchronize];
                break;
            case 4:
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:ALERT_RECIEVED];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SCREEN_TO_LOAD];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                [self performSegueWithIdentifier:@"HomeToEditProductsSegue" sender:self];
                break;
            default:
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:ALERT_RECIEVED];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SCREEN_TO_LOAD];
                [[NSUserDefaults standardUserDefaults]synchronize];

                break;
            
                
        }
    }

}

- (void)searchForWordInSearchResults:(NSString *)wordToSearch
{
    if([wordToSearch isEqualToString:@""])
    {
        self.useFilteredResults = NO;
        [self.produceTableView reloadData];
    }
    else
    {
        NSMutableArray *newResults = [[NSMutableArray alloc] init];
        
        
        for(NSDictionary *tempDic in self.userData.searchResults)
        {
            /*if(wordToSearch.length > 2 && [[tempDic[@"category"] uppercaseString] containsString:wordToSearch])
            {
                [newResults addObject:tempDic];
                
            }
            else*/ if([[tempDic[@"productHeadline"] uppercaseString] containsString:wordToSearch])
            {
                [newResults addObject:tempDic];
            
            }
        }
        
        self.filteredSearchResults = newResults;
        
        self.useFilteredResults = YES;
        [self.produceTableView reloadData];
    }
    
    
}

- (void)loadProductImageAtIndex:(NSIndexPath *)path forImage:(UIImageView *)imageView withActivityIndicator:(UIActivityIndicatorView *)spinner
{
    NSDictionary *tempDic;
    
    if(self.useFilteredResults)
        tempDic = [self.filteredSearchResults objectAtIndex:path.section];
    else
        tempDic = [self.userData.searchResults objectAtIndex:path.section];
    NSString *fileName = [NSString stringWithFormat:@"%@_1.png",[tempDic objectForKey:@"productID"]];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir,fileName];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* attrs = [fm attributesOfItemAtPath:pngFilePath error:nil];
    
    if (attrs != nil) {
        NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
        NSLog(@"Date Created: %@", [date description]);
        if([HelperMethods getTimeSinceFileCreated:[date description]])
        {
            NSLog(@"Removing Photo and redownloading");
            [[NSFileManager defaultManager] removeItemAtPath:pngFilePath error:nil];
        }
        
        
    }
    else {
        NSLog(@"Not found");
    }
    
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
        [spinner startAnimating];
        spinner.hidden = NO;
        imageView.image = [UIImage imageNamed:@"noImageAvailable"];
        
        // Create a reference to the file you want to download
        FIRStorageReference *fileRef = [[[FIRStorage storage] reference] child:[NSString stringWithFormat:@"%@/farm/products/%@/images/%@", tempDic[@"farmerID"], tempDic[@"productID"], fileName]];
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        [fileRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
            if (error != nil) {
                // Uh-oh, an error occurred!
                spinner.hidden = YES;
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

-(void)hideKeyboard
{
    
    if(self.produceSearchBar.text.length > 0)
        [FIRAnalytics logEventWithName:@"Home_Screen_Search_Term" parameters:@{
                                                                          @"searchTerm" : [self.produceSearchBar.text lowercaseString]
                                                                          }];
    
    [self.produceSearchBar resignFirstResponder];
    
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    if(self.isLocationServicesDisabled)
    {
        if(!self.userData.isUserLoggedIn && [[NSUserDefaults standardUserDefaults] objectForKey:@"manualLat"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"manualLong"])
        {
            self.userData.searchResults = [[NSArray alloc]init];
            self.produceSearchBar.text = @"";
            [self.userData checkSearchTimer];
            //self.spinnerView.hidden = NO;
            [self startASearch];
            
        }
        else
            [self.produceTableView reloadData];
    }
    else
    {
        self.userData.searchResults = [[NSArray alloc]init];
        self.produceSearchBar.text = @"";
        //self.spinnerView.hidden = NO;
        [self.userData checkSearchTimer];
        [self startASearch];
        
        
        
    }
    
    [refreshControl endRefreshing];
   
}

- (void)checkTimer
{
    [self.gpsTimer invalidate];
    
    self.isGPSError = YES;
    
    [self.produceTableView reloadData];
}

- (void)startGPSTimer
{
    if(!self.gpsTimer.isValid)
    {
        self.gpsTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(checkTimer) userInfo:nil repeats:NO];
    }
}


- (void)startASearch
{
    if(!self.isSearching && !self.userData.isSearchTimerRunning)
    {
        self.spinnerView.hidden = NO;
        if([[[NSUserDefaults standardUserDefaults]objectForKey:@"isUsingGPSForSearches"]boolValue])
        {
            [self startGPSTimer];
            [self.locationManager startUpdatingLocation];
        }
        else
        {
            if(!self.runOnce)
            {
                self.filteredSearchResults = [[NSArray alloc]init];
                self.userData.searchResults = [[NSArray alloc]init];
                self.userData.searchResultsAllLocations = [[NSMutableDictionary alloc]init];
                self.userData.searchResultsFarmers = [[NSMutableDictionary alloc]init];
                self.userData.searchResultsLocations = [[NSMutableDictionary alloc]init];
                
                
                
                self.gpsCoordsForSearch.text = [NSString stringWithFormat:@"%@,%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"manualLat"], [[NSUserDefaults standardUserDefaults]objectForKey:@"manualLong"]];
                    
                [FIRAnalytics logEventWithName:@"Manual_Location_Search" parameters:nil];
                    
                CLLocation *manualLocation = [[CLLocation alloc]initWithLatitude:[[[NSUserDefaults standardUserDefaults] objectForKey:@"manualLat"]floatValue] longitude:[[[NSUserDefaults standardUserDefaults]objectForKey:@"manualLong"]floatValue]];
                    
                    
                self.isSearching = YES;
                self.radius = [self.userData geoQueryforProducts:manualLocation];
                
                
                
                
                self.runOnce = YES;
            }

        }
    }
}

#pragma mark - Delegates

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([CLLocationManager locationServicesEnabled]) {
        
        if(status == kCLAuthorizationStatusDenied)
        {
            self.isLocationServicesDisabled = YES;
            self.spinnerView.hidden = YES;
            [self.produceTableView reloadData];
        }
        else
        {
            self.isLocationServicesDisabled = NO;
            self.locationManager.delegate = self;
            
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            
            // Set a movement threshold for new events.
            self.locationManager.distanceFilter = 500; // meters
            
                       
        }
        
    } else {
        NSLog(@"Location services are not enabled");
        self.isLocationServicesDisabled = YES;
    }
}

- (void)geoSearchCompleted
{
    
    
    self.searchRadiusLabel.hidden = NO;
    self.runOnce = NO;
    self.successfulSearch = YES;
    self.useFilteredResults = NO;
    [self.produceTableView reloadData];
    
}

- (void)searchCompleted
{
    self.isSearching = NO;
    self.searchCounter++;
    self.numberOfSearchesPerformedLabel.text = [NSString stringWithFormat:@"%i", self.searchCounter];
     self.searchRadiusLabel.text = [NSString stringWithFormat:@"Search Radius %0.2f Miles", self.radius];
}

- (void)productAdded
{
    
    self.runOnce = NO;
    self.useFilteredResults = NO;
    [self.produceTableView reloadData];
}

- (void)updateStatusUpdate:(int)statusCode
{
   
   /* if(statusCode == 1)
    {
        self.spinnerView.hidden = TRUE;
    }
    else if(statusCode == 2)
    {
        self.spinnerView.hidden = FALSE;
    } */
}

- (void)updateStatusComplete
{
    
    if(self.userData.isUserLoggedIn)
    {
        self.searchRadiusLabel.text = [NSString stringWithFormat:@"Search Radius %0.2f Miles", [self.userData getCurrentSearchRadius]];
        
        if(self.userData.isAdmin)
        {
            self.gpsCoordsForSearch.hidden = NO;
            self.numberOfSearchesPerformedLabel.hidden = NO;
        }
    }
    else
    {
        if(![[NSUserDefaults standardUserDefaults]objectForKey:@"isUsingGPSForSearches"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isUsingGPSForSearches"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        
    }
    
    if(self.isLocationServicesDisabled)
    {
        if(!self.userData.isUserLoggedIn && [[NSUserDefaults standardUserDefaults] objectForKey:@"manualLat"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"manualLong"])
        {
            self.runOnce = NO;
            [self startASearch];
            
            
        }
        else
            self.spinnerView.hidden = YES;
    }
    else
    {
        self.runOnce = NO;
        [self startASearch];
        
        
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    [self.gpsTimer invalidate];
    self.isGPSError = NO;
    
    [self.locationManager stopUpdatingLocation];
    CLLocation *location = [locations lastObject];
    
    NSLog(@"USER LOCATION: %@", location.description);
    
    if(self.userData.isUserLoggedIn)
    {
    
         CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if(!error)
            {
                for (CLPlacemark * placemark in placemarks)
                {
                    NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
                    NSLog(@"placemark.country %@",placemark.country);
                    NSLog(@"placemark.postalCode %@",placemark.postalCode);
                    NSLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
                    NSLog(@"placemark.locality %@",placemark.locality);
                    NSLog(@"placemark.subLocality %@",placemark.subLocality);
                    NSLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);
                    
                    [geoCoder geocodeAddressString:placemark.locality completionHandler:^(NSArray* placemarks, NSError* error){
                        if(!error)
                        {
                            for (CLPlacemark* aPlacemark in placemarks)
                            {
                                // Process the placemark.
                                NSString *latDest1 = [NSString stringWithFormat:@"%.4f",aPlacemark.location.coordinate.latitude];
                                NSString *lngDest1 = [NSString stringWithFormat:@"%.4f",aPlacemark.location.coordinate.longitude];
                                
                                NSLog(@"%@,%@", latDest1, lngDest1);
                                CLLocation *cityLoc = [[CLLocation alloc]initWithLatitude:aPlacemark.location.coordinate.latitude longitude:aPlacemark.location.coordinate.longitude];
                                
                                
                                
                                [self.userData updateCityForUser:cityLoc withCityName:[NSString stringWithFormat:@"%@, %@",placemark.locality, placemark.administrativeArea]];
                                
                                
                            }
                        }
                        else
                        {
                            NSLog(@"Unable to get user's City Coordniates");
                        }
                        
                    }];
                    
                }
                
            }
            else
            {
                NSLog(@"failed getting city: %@", [error description]);
            }
        }];
        
    }
    
    if(!self.runOnce)
    {
        self.filteredSearchResults = [[NSArray alloc]init];
        self.userData.searchResults = [[NSArray alloc]init];
        self.userData.searchResultsAllLocations = [[NSMutableDictionary alloc]init];
        self.userData.searchResultsFarmers = [[NSMutableDictionary alloc]init];
        self.userData.searchResultsLocations = [[NSMutableDictionary alloc]init];
        
        
    
            self.gpsCoordsForSearch.text = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
            
            [FIRAnalytics logEventWithName:@"GPS_Search" parameters:nil];
        
            self.isSearching = YES;
            //self.spinnerView.hidden = NO;
            self.radius = [self.userData geoQueryforProducts:location];
        

        
        
        self.runOnce = YES;
    }
    
   
}

#pragma mark - Search Bar Delegate Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    //[searchBar setShowsCancelButton:YES animated:NO];
   
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [FIRAnalytics logEventWithName:@"Home_Screen_Search_Term" parameters:@{
                                                                @"searchTerm" : [searchBar.text lowercaseString]
                                                                }];
    
    [searchBar resignFirstResponder];
    

   
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTex
{
    [self searchForWordInSearchResults:[searchTex uppercaseString]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"menuSegue"])
    {
        MainMenuViewController *mmvc = segue.destinationViewController;
        
        mmvc.screenShotImage = [UIView captureView:self.view];
        mmvc.moveImage = YES;
        mmvc.userData = self.userData;
        
        //self.userData.searchResults = [[NSArray alloc]init];
        //[self.produceTableView reloadData];
        
        
    }
    else if([segue.identifier isEqualToString:@"filterSegue"])
    {
        FilterOptionsViewController *fovc = segue.destinationViewController;
        
        fovc.userData = self.userData;
        
        self.userData.searchResults = [[NSArray alloc]init];
        [self.produceTableView reloadData];
    }
    else if([segue.identifier isEqualToString:@"showProductSegue"])
    {
        ProductViewController *pvc = segue.destinationViewController;
        
        pvc.userData = self.userData;
        pvc.showingFavoriteFarmer = self.isFavorite;
    }
    else if([segue.identifier isEqualToString:@"chatNotificationSegue"])
    {
        ChatMessagesViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
        vc.userSelected = @{
                            @"name" : [[NSUserDefaults standardUserDefaults]objectForKey:@"fromUserIDName"],
                            @"userID" : [[NSUserDefaults standardUserDefaults]objectForKey:@"fromUserID"]
                            };
        vc.userType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userType"]intValue];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:ALERT_RECIEVED];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SCREEN_TO_LOAD];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"fromUserIDName"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"fromUserID"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"userType"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else if([segue.identifier isEqualToString:@"homeToSignUpSegue"])
    {
        SignUpViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
        vc.isLogin = self.isLogin;
    }
    else if([segue.identifier isEqualToString:@"HomeToReviewsSegue"])
    {
        CustomerReviewsViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
        vc.farmerSelected = @{
                              @"farmerID" : self.userData.user.uid
                              };
        vc.isViewingAlert = YES;
    }
    else if([segue.identifier isEqualToString:@"HomeToEditProductsSegue"])
    {
        EditProductViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }

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
    if(self.isGPSError)
    {
        self.spinnerView.hidden = YES;
        return 1;
    }
    
    if(self.isLocationServicesDisabled)
    {
        if(!self.userData.isUserLoggedIn && [[NSUserDefaults standardUserDefaults] objectForKey:@"manualLat"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"manualLong"])
        {
            if(!self.isSearching && self.successfulSearch)
            {
                if(self.useFilteredResults)
                {
                    if(self.filteredSearchResults.count == 0)
                    {
                        
                        if(self.userData.searchStarted)
                        {
                            return 0;
                        }
                        else
                        {
                            [FIRAnalytics logEventWithName:@"Filterd_Results_0" parameters:nil];
                            self.spinnerView.hidden = YES;
                            return 1;
                        }
                    }
                    else
                    {
                        self.spinnerView.hidden = YES;
                        return self.filteredSearchResults.count;
                    }
                }
                else
                {
                    if(self.userData.searchResults.count == 0)
                    {
                        
                        if(self.userData.searchStarted)
                        {
                            return 0;
                        }
                        else
                        {
                            [FIRAnalytics logEventWithName:@"Un_Filtered_Results_0" parameters:nil];
                            
                            self.spinnerView.hidden = YES;
                            
                            return 1;
                        }
                    }
                    else
                    {
                        self.spinnerView.hidden = YES;
                        
                        return self.userData.searchResults.count;
                    }
                }
                
            }
            else
                return 0;

        }
        else
        {
            self.spinnerView.hidden = YES;
            return 1;
        }
    }
    
    
    if(!self.isSearching && self.successfulSearch)
    {
        if(self.useFilteredResults)
        {
            if(self.filteredSearchResults.count == 0)
            {
                
                if(self.userData.searchStarted)
                {
                    return 0;
                }
                else
                {
                    [FIRAnalytics logEventWithName:@"Filterd_Results_0" parameters:nil];
                     self.spinnerView.hidden = YES;
                     return 1;
                    
                }
                
            }
            else
            {
                self.spinnerView.hidden = YES;
                return self.filteredSearchResults.count;
            }
        }
        else
        {
            if(self.userData.searchResults.count == 0)
            {
                
                if(self.userData.searchStarted)
                {
                    return 0;
                }
                else
                {
                    [FIRAnalytics logEventWithName:@"Un_Filtered_Results_0" parameters:nil];
                    self.spinnerView.hidden = YES;
                    return 1;
                }
            }
            else
            {
                self.spinnerView.hidden = YES;
                
                return self.userData.searchResults.count;
            }
        }
        
    }
    else
        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"produceCell";
    static NSString *noResultsCellIdentifier = @"noResultsCell";
    static NSString *locationCellIdentifier = @"noLocationCell";
    static NSString *noGPSCellIdentifier = @"noGPScell";
    
    UITableViewCell *cell;
    
    if(self.isGPSError)
        cell = [tableView dequeueReusableCellWithIdentifier:noGPSCellIdentifier forIndexPath:indexPath];
    else if(self.isLocationServicesDisabled && !self.successfulSearch)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:locationCellIdentifier forIndexPath:indexPath];
    }
    else if((!self.useFilteredResults && self.userData.searchResults.count == 0) || (self.useFilteredResults && self.filteredSearchResults.count == 0))
    {
        
        cell = [tableView dequeueReusableCellWithIdentifier:noResultsCellIdentifier forIndexPath:indexPath];
        
    }
    else
    {
        NSDictionary *tempDic;
        if(self.useFilteredResults)
            tempDic = [self.filteredSearchResults objectAtIndex:indexPath.section];
        else
            tempDic = [self.userData.searchResults objectAtIndex:indexPath.section];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIImageView *openNowImageView = (UIImageView *)[cell viewWithTag:12];
        UIImageView *produceImageView = (UIImageView *)[cell.contentView viewWithTag:5];
        UILabel *headlineLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *produceDescriptionLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *distanceToFarmLabel = (UILabel *)[cell viewWithTag:3];
        UILabel *activeTimeLabel = (UILabel *)[cell viewWithTag:4];
        
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell.contentView viewWithTag:13];
        
        [self loadProductImageAtIndex:indexPath forImage:produceImageView withActivityIndicator:spinner];
        
        for(int i = 2; i < 5; i++)
        {
            [HelperMethods downloadProductImageFromFirebase:tempDic[@"farmerID"] forProductID:tempDic[@"productID"] imageNumber:i];
        }
        
        BOOL isOpen = NO;
        
        NSDictionary *farmerSelected = [self.userData.searchResultsFarmers objectForKey:tempDic[@"farmerID"]];
        openNowImageView.hidden = YES;
        
        for(int i = 0; i < 7; i++)
        {

            NSMutableDictionary *day = [[farmerSelected[@"schedule"] objectForKey:[NSString stringWithFormat:@"%d", i]]mutableCopy];
            
                if(!isOpen)
                {
                    if([farmerSelected[@"activeLocation"] isEqualToString:day[@"locationID"]] && [HelperMethods isLocationOpen:day[@"openTime"] closed:day[@"closeTime"]])
                    {
                        if([HelperMethods getWeekday] == i)
                        {
                            openNowImageView.hidden = NO;
                            isOpen = YES;
                            break;
                            
                        }
                    }
                   
                }
            
        }
        
        activeTimeLabel.text = [HelperMethods getTimeSinceDate:tempDic[@"datePosted"]];
        
        
        headlineLabel.text = tempDic[@"productHeadline"];
        produceDescriptionLabel.text = tempDic[@"productDescription"];
        
        distanceToFarmLabel.text = tempDic[@"distanceToFarmString"];
        
        int rating = [self.userData getFarmerRating:tempDic[@"farmerID"]];
        
        
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
                star2.image = [UIImage imageNamed:@"emptyStar"];
                star3.image = [UIImage imageNamed:@"emptyStar"];
                star4.image = [UIImage imageNamed:@"emptyStar"];
                star5.image = [UIImage imageNamed:@"emptyStar"];
                break;
            case 2:
                star1.image = [UIImage imageNamed:@"fullStar"];
                star2.image = [UIImage imageNamed:@"emptyStar"];
                star3.image = [UIImage imageNamed:@"emptyStar"];
                star4.image = [UIImage imageNamed:@"emptyStar"];
                star5.image = [UIImage imageNamed:@"emptyStar"];
                break;
            case 3:
                star1.image = [UIImage imageNamed:@"fullStar"];
                star2.image = [UIImage imageNamed:@"halfStar"];
                star3.image = [UIImage imageNamed:@"emptyStar"];
                star4.image = [UIImage imageNamed:@"emptyStar"];
                star5.image = [UIImage imageNamed:@"emptyStar"];
                break;
            case 4:
                star1.image = [UIImage imageNamed:@"fullStar"];
                star2.image = [UIImage imageNamed:@"fullStar"];
                star3.image = [UIImage imageNamed:@"emptyStar"];
                star4.image = [UIImage imageNamed:@"emptyStar"];
                star5.image = [UIImage imageNamed:@"emptyStar"];
                break;
            case 5:
                star1.image = [UIImage imageNamed:@"fullStar"];
                star2.image = [UIImage imageNamed:@"fullStar"];
                star3.image = [UIImage imageNamed:@"halfStar"];
                star4.image = [UIImage imageNamed:@"emptyStar"];
                star5.image = [UIImage imageNamed:@"emptyStar"];
                break;
            case 6:
                star1.image = [UIImage imageNamed:@"fullStar"];
                star2.image = [UIImage imageNamed:@"fullStar"];
                star3.image = [UIImage imageNamed:@"fullStar"];
                star4.image = [UIImage imageNamed:@"emptyStar"];
                star5.image = [UIImage imageNamed:@"emptyStar"];
                break;
            case 7:
                star1.image = [UIImage imageNamed:@"fullStar"];
                star2.image = [UIImage imageNamed:@"fullStar"];
                star3.image = [UIImage imageNamed:@"fullStar"];
                star4.image = [UIImage imageNamed:@"halfStar"];
                star5.image = [UIImage imageNamed:@"emptyStar"];
                break;
            case 8:
                star1.image = [UIImage imageNamed:@"fullStar"];
                star2.image = [UIImage imageNamed:@"fullStar"];
                star3.image = [UIImage imageNamed:@"fullStar"];
                star4.image = [UIImage imageNamed:@"fullStar"];
                star5.image = [UIImage imageNamed:@"emptyStar"];
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
        
        
        produceImageView.layer.cornerRadius = 10;
        produceImageView.layer.masksToBounds = YES;
    }
    
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((self.userData.isUserLoggedIn && !self.useFilteredResults && self.userData.searchResults.count > 0) || (self.userData.isUserLoggedIn && self.useFilteredResults && self.filteredSearchResults.count > 0))
    {
        if(self.useFilteredResults)
        {
            [self.userData setSelectedProductByProductID:[[self.filteredSearchResults objectAtIndex:indexPath.section]objectForKey:@"productID"]];
        }
        else
            self.userData.searchResultSelected = indexPath.section;
        [self performSegueWithIdentifier:@"showProductSegue" sender:self];
    }
    else if(!self.userData.isUserLoggedIn)
    {
    
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Information"
                                              message:@"You must have an account to view products."
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *signUp = [UIAlertAction
                                      actionWithTitle:@"Sign Up"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action)
                                      {
                                          self.isLogin = NO;
                                          [self performSegueWithIdentifier:@"homeToSignUpSegue" sender:self];
                                      }];
        
        UIAlertAction *login = [UIAlertAction
                                       actionWithTitle:@"Log In"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           self.isLogin = YES;
                                           [self performSegueWithIdentifier:@"homeToSignUpSegue" sender:self];
                                       }];
        
        UIAlertAction *cancelButton = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
        
        [alertController addAction: signUp];
        [alertController addAction:login];
        [alertController addAction:cancelButton];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
