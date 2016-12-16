//
//  FarmProfileViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/23/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "FarmProfileViewController.h"
#import <Mapkit/Mapkit.h>
#import "HelperMethods.h"
#import "Constants.h"
#import "MainMenuViewController.h"
#import "ProductViewController.h"
#import "ChatMessagesViewController.h"
#import "ChatMenuViewController.h"
#import "CustomerReviewsViewController.h"
#import "UIView+Addons.h"

@interface FarmProfileViewController () <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UserModelDelegate>
@property (weak, nonatomic) IBOutlet UILabel *farmNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *row1Day;
@property (weak, nonatomic) IBOutlet UILabel *row1Open;
@property (weak, nonatomic) IBOutlet UILabel *row1Closed;
@property (weak, nonatomic) IBOutlet UILabel *row1;

@property (weak, nonatomic) IBOutlet UILabel *row2Day;
@property (weak, nonatomic) IBOutlet UILabel *row2Open;
@property (weak, nonatomic) IBOutlet UILabel *row2Closed;
@property (weak, nonatomic) IBOutlet UILabel *row2;

@property (weak, nonatomic) IBOutlet UILabel *row3Day;
@property (weak, nonatomic) IBOutlet UILabel *row3Open;
@property (weak, nonatomic) IBOutlet UILabel *row3Closed;
@property (weak, nonatomic) IBOutlet UILabel *row3;

@property (weak, nonatomic) IBOutlet UILabel *row4Day;
@property (weak, nonatomic) IBOutlet UILabel *row4Open;
@property (weak, nonatomic) IBOutlet UILabel *row4Closed;
@property (weak, nonatomic) IBOutlet UILabel *row4;

@property (weak, nonatomic) IBOutlet UILabel *row5Day;
@property (weak, nonatomic) IBOutlet UILabel *row5Open;
@property (weak, nonatomic) IBOutlet UILabel *row5Closed;
@property (weak, nonatomic) IBOutlet UILabel *row5;

@property (weak, nonatomic) IBOutlet UILabel *row6Day;
@property (weak, nonatomic) IBOutlet UILabel *row6Open;
@property (weak, nonatomic) IBOutlet UILabel *row6Closed;
@property (weak, nonatomic) IBOutlet UILabel *row6;

@property (weak, nonatomic) IBOutlet UILabel *row7Day;
@property (weak, nonatomic) IBOutlet UILabel *row7Open;
@property (weak, nonatomic) IBOutlet UILabel *row7Closed;
@property (weak, nonatomic) IBOutlet UILabel *row7;


@property (weak, nonatomic) IBOutlet MKMapView *locationMapView;
@property (weak, nonatomic) IBOutlet UIImageView *farmProfileImageView;
@property (weak, nonatomic) IBOutlet UIView *locationScheduleView;
@property (weak, nonatomic) IBOutlet UIButton *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UILabel *noRatingLabel;
@property (weak, nonatomic) IBOutlet UIButton *reviewsButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showMoreTopConstraint;
@property (nonatomic) CGPoint lastContentOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreButtonView;

@property (weak, nonatomic) IBOutlet UIButton *phoneLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *swipeGestureViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *ProductSwipeview;
@property (weak, nonatomic) IBOutlet UILabel *farmDescriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *swipeUpLabel;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (weak, nonatomic) IBOutlet UIImageView *star1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star2ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star3ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star4ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star5ImageView;
@property (weak, nonatomic) IBOutlet UITableView *produceTableView;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;

@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (nonatomic) BOOL isOpen;

@property (weak, nonatomic) IBOutlet UITextView *farmDescriptionTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewRealHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *innerTableViewHeightConstraint;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSDictionary *locationSelected;
@property (nonatomic, strong) NSDictionary *farmerSelected;

@property (weak, nonatomic) IBOutlet UIButton *moreLocationsButton;
@property (nonatomic) BOOL isFavorite;


@end

@implementation FarmProfileViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.farmProfileImageView.layer.cornerRadius = 30.0f;
    self.farmProfileImageView.layer.masksToBounds = YES;
    
    
    self.produceTableView.delegate = self;
    self.produceTableView.dataSource = self;
    self.userData.delegate = self;
    
    self.isOpen = NO;
    
    self.tableViewRealHeightConstraint.constant = self.view.frame.size.height - (self.farmProfileImageView.frame.origin.y + self.farmProfileImageView.frame.size.height + 3.5);
     self.innerTableViewHeightConstraint.constant = self.view.frame.size.height - (self.farmProfileImageView.frame.origin.y + self.farmProfileImageView.frame.size.height + 3.5) - 15;
    [self.view layoutIfNeeded];
    
    if(self.showMoreProducts)
    {
        self.swipeUpLabel.hidden = YES;
        
        self.tableViewHeightConstraint.constant = 3.5;
        self.swipeGestureViewTopConstraint.constant = 3.5;
        self.moreButtonView.constant = 66;
        [self.view layoutIfNeeded];
    }
    
    [self.userData getProductsOfSelectedFarmerIsFavorite:self.showingFavoriteFarmer];
    self.locationSelected = [self.userData getLocationSelectedIsFavorite:self.showingFavoriteFarmer];
    self.farmerSelected = [self.userData getFarmerSelectedIsFavorite:self.showingFavoriteFarmer];
    
    if([self.userData.favorites objectForKey:self.farmerSelected[@"farmerID"]])
    {
        if([[[self.userData.favorites objectForKey:self.farmerSelected[@"farmerID"]]objectForKey:@"farmerID"] isEqualToString:self.userData.user.uid])
        {
            self.favoriteButton.enabled = NO;
            self.followersLabel.hidden = NO;
            self.followersCountLabel.text = self.userData.numFavorites;
            self.followersCountLabel.hidden = NO;
        }
        else
        {
            self.isFavorite = YES;
            [self.favoriteButton setImage:[UIImage imageNamed:@"followCopy"] forState:UIControlStateNormal];
        }
    }
    else if([self.farmerSelected[@"farmerID"] isEqualToString:self.userData.user.uid])
    {
        self.favoriteButton.enabled = NO;
        self.followersLabel.hidden = NO;
        self.followersCountLabel.text = self.userData.numFavorites;
        self.followersCountLabel.hidden = NO;
    }
    else
        self.isFavorite = NO;
    
    [self updateMap];
    
    
    self.farmNameLabel.text = self.farmerSelected[@"farmName"];
    
    int rating = [self.farmerSelected[@"rating"]intValue];
    
    switch(rating)
    {
        case 1:
            self.star1ImageView.image = [UIImage imageNamed:@"halfStar"];
            break;
        case 2:
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            break;
        case 3:
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"halfStar"];
            break;
        case 4:
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"fullStar"];
            break;
        case 5:
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"halfStar"];
            break;
        case 6:
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"fullStar"];
            break;
        case 7:
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"halfStar"];
            break;
        case 8:
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"fullStar"];
            break;
        case 9:
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star5ImageView.image = [UIImage imageNamed:@"halfStar"];
            break;
        case 10:
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star5ImageView.image = [UIImage imageNamed:@"fullStar"];
            break;
        case 99:
            self.star1ImageView.hidden = true;
            self.star2ImageView.hidden = true;
            self.star3ImageView.hidden = true;
            self.star4ImageView.hidden = true;
            self.star5ImageView.hidden = true;
            self.noRatingLabel.hidden = false;
            break;
    }
    
    [self.reviewsButton setTitle:[NSString stringWithFormat:@"%@ Reviews", self.farmerSelected[@"numReviews"]] forState:UIControlStateNormal];
    
    //self.farmDescriptionLabel.text = self.farmerSelected[@"farmDescription"];
    
    self.farmDescriptionTextView.text = self.farmerSelected[@"farmDescription"];
    
    UILabel * textView = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width - 40, MAX_HEIGHT)];
    textView.numberOfLines = 0;
    textView.text = self.farmerSelected[@"farmDescription"];
    
    textView.font = [UIFont systemFontOfSize:13];
    [textView sizeToFit];
    NSLog(@"%f", textView.frame.size.height);
    [self.farmDescriptionLabel sizeToFit];
    if(textView.frame.size.height > 56)
    {
        self.moreButton.hidden = NO;
        [self.moreButton setTitle:@"More..." forState:UIControlStateNormal];
        self.farmDescriptionTextView.scrollEnabled = NO;
    }
    else
    {
        self.moreButton.hidden = YES;
        self.farmDescriptionTextView.scrollEnabled = NO;
    }
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeUp)];
    
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionUp];
    
    //swipeGesture.cancelsTouchesInView= YES;
    [self.ProductSwipeview addGestureRecognizer:swipeGesture];
    
    
    UISwipeGestureRecognizer *swipeGesture2 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDown)];
    
    [swipeGesture2 setDirection:UISwipeGestureRecognizerDirectionDown];
    //swipeGesture2.cancelsTouchesInView = YES;
    
    [self.ProductSwipeview addGestureRecognizer:swipeGesture2];
    
    if(![self.farmerSelected[@"useChat"] boolValue] || [self.farmerSelected[@"farmerID"] isEqualToString:self.userData.user.uid])
    {
        self.chatButton.hidden = true;
    }
    
    if(![self.farmerSelected[@"useEmail"] boolValue])
        self.emailButton.hidden = true;
    
    if([self.farmerSelected[@"useTelephone"]boolValue])
    {
        self.phoneLabel.hidden = NO;
        [self.phoneLabel setTitle:self.farmerSelected[@"contactPhone"] forState:UIControlStateNormal];
    }
    else
        self.phoneLabel.hidden = YES;
    
    [self setScheduleForLocation:self.locationSelected[@"locationID"]];
    
    NSArray *locations = self.farmerSelected[@"locations"];
    if(locations.count > 1)
        self.moreLocationsButton.hidden = NO;
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    [FIRAnalytics logEventWithName:@"Farm_Profile_Screen_Loaded" parameters:@{
                                                                              @"Farmer_Selected" : self.farmerSelected[@"farmerID"]
                                                                              }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImage) name:HelperMethodsImageDownloadCompleted object:nil];
    
    [self updateImage];
}

#pragma mark - IBActions

- (IBAction)phoneButtonPressed:(UIButton *)sender {
    
    
    NSString *phoneString = [[[self.farmerSelected[@"contactPhone"] stringByReplacingOccurrencesOfString:@"(" withString:@"-"] stringByReplacingOccurrencesOfString:@")" withString:@"-"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *phoneURLString = [NSString stringWithFormat:@"tel:%@", phoneString];
    NSURL *phoneURL = [NSURL URLWithString:phoneURLString];
    
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    } else
    {
        [self presentViewController: [UIView createSimpleAlertWithMessage:@"Call facility is not available!!!"andTitle:@"Alert" withOkButton:YES] animated: YES completion: nil];
        
    }
    
}


- (IBAction)pickupTimesButtonPressed:(UIButton *)sender {
    
    self.locationScheduleView.hidden = !self.locationScheduleView.hidden;
}

- (IBAction)closeScheduleButtonPressed:(UIButton *)sender {
    
    self.locationScheduleView.hidden = YES;
}

- (IBAction)moreLocationsButtonPressed:(UIButton *)sender {
    
    self.locationSelected = [self.userData getNextInLineLocation:self.locationSelected[@"locationID"] isFavorite:self.showingFavoriteFarmer];
   
    [self updateMap];
    
    [self setScheduleForLocation:self.locationSelected[@"locationID"]];
}

- (IBAction)addressButtonPressed:(UIButton *)sender {
    
    NSString *address = self.locationSelected[@"fullAddress"];
    
    address = [address stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    address = [address stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString* url = [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@&dirflg=d&t=h",address];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (IBAction)emailButtonPressed:(UIButton *)sender {
    
    /* create mail subject */
    NSString *subject = [NSString stringWithFormat:@"Farm Fresh App"];
    
    /* define email address */
    NSString *mail = self.farmerSelected[@"contactEmail"];
    
    /* create the URL */
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"mailto:?to=%@&subject=%@",
                                                [mail stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
                                                [subject stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    
    /* load the URL */
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)moreLessButtonPressed:(UIButton *)sender {
    
    if([sender.titleLabel.text isEqualToString:@"Show Less..."])
    {
        self.farmDescriptionTextView.scrollEnabled = NO;
        self.tableViewHeightConstraint.constant = 200;
        self.swipeGestureViewTopConstraint.constant = 200;
        self.moreButtonView.constant = 66;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [sender setTitle:@"More..." forState:UIControlStateNormal];
        }];
    }
    else
    {
        self.farmDescriptionTextView.scrollEnabled = YES;
        self.tableViewHeightConstraint.constant = 320;
        self.swipeGestureViewTopConstraint.constant = 320;
        self.moreButtonView.constant = 176;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }completion:^(BOOL finished) {
             [sender setTitle:@"Show Less..." forState:UIControlStateNormal];
        }];
    }
}

- (IBAction)backButtonPressed
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    BOOL mainMenuFound = false;
    for(int i = 0; i < viewControllers.count;i++)
    {
        id obj = [viewControllers objectAtIndex:i];
        if([obj isKindOfClass:[MainMenuViewController class]])
        {
            mainMenuFound = true;
            [self.navigationController popToViewController:obj animated:YES];
        }
    }
    
    if(!mainMenuFound)
       [self.navigationController popToRootViewControllerAnimated:YES];
    
}
- (IBAction)chatButtonPressed {

    
    if([self.farmerSelected[@"farmerID"] isEqualToString:self.userData.user.uid])
    {
        [self performSegueWithIdentifier:@"profileToChatMenuSegue" sender:self];
    }
    else
    {
        [self.userData addUserToFarmersChatList:self.farmerSelected[@"farmerID"] isFavoriting:NO];

        [self performSegueWithIdentifier:@"profileToChatSegue" sender:self];
    }
    
}

- (IBAction)favoriteButtonPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    
    
    
    if(self.isFavorite)
    {
        [self.userData removeFarmer:self.farmerSelected[@"farmerID"] AsFavorite:[[self.userData.favorites objectForKey:self.farmerSelected[@"farmerID"]]objectForKey:@"favoriteID"]];
        
        [self.favoriteButton setImage:[UIImage imageNamed:@"favoriteButton"] forState:UIControlStateNormal];
        self.isFavorite = NO;
    }
    else
    {
        NSDictionary *farmerData = @{
                                     @"farmerID" : self.farmerSelected[@"farmerID"],
                                     @"getNotifications" : @"1"
                                     };
        
        [self.userData addFarmerAsAFavorite:farmerData];
        
        if([self.farmerSelected[@"useChat"] boolValue])
            [self.userData addUserToFarmersChatList:self.farmerSelected[@"farmerID"] isFavoriting:YES];
        
        [self.favoriteButton setImage:[UIImage imageNamed:@"followCopy"] forState:UIControlStateNormal];
        
        self.isFavorite = YES;
    }
    
    sender.enabled = YES;

}

#pragma mark - Methods

- (void)loadProductImageAtIndex:(NSIndexPath *)path forImage:(UIImageView *)imageView withActivityIndicator:(UIActivityIndicatorView *)spinner
{
    NSDictionary *tempDic;
    
    //if(self.showingFavoriteFarmer)
        tempDic = [self.products objectAtIndex:path.section];
    //else
      //  tempDic = [self.userData.searchResults objectAtIndex:path.section];
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

- (void)updateImage
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@_farmProfile.png",docDir, self.farmerSelected[@"farmerID"]];
    
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
        [self.farmProfileImageView setImage:image];
        
    }
    else
    {
        
        [HelperMethods downloadOtherUsersFarmProfileImageFromFirebase:self.farmerSelected[@"farmerID"]];
        
    }
    
}

- (void)updateMap
{
    [self.addressLabel setTitle:self.locationSelected[@"fullAddress"] forState:UIControlStateNormal];
    
    self.locationMapView.delegate = self;
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
    annotation.coordinate= CLLocationCoordinate2DMake([self.locationSelected[@"latitude"]floatValue], [self.locationSelected[@"longitude"]floatValue]);
    
    MKCoordinateRegion mapRegion;
    mapRegion.center = annotation.coordinate;
    mapRegion.span.latitudeDelta = 0.008;
    mapRegion.span.longitudeDelta = 0.008;
    
    [self.locationMapView setRegion:mapRegion animated: YES];
    
    [self.locationMapView addAnnotation:annotation];
}

- (void)setScheduleForLocation:(NSString *)locationID
{
    [self hideAllScheduleLabels];
    
    NSMutableArray *days = [[NSMutableArray alloc]init];
    self.isOpen = NO;
    
    for(int i = 0; i < 7; i++)
    {
        NSMutableDictionary *day = [[self.farmerSelected[@"schedule"] objectForKey:[NSString stringWithFormat:@"%d", i]]mutableCopy];
        
        if([day[@"locationID"] isEqualToString:locationID])
        {
            if(!self.isOpen)
            {
                if([self.farmerSelected[@"activeLocation"] isEqualToString:locationID] && [HelperMethods isLocationOpen:day[@"openTime"] closed:day[@"closeTime"]])
                {
                    if([HelperMethods getWeekday] == i)
                    {
                        NSString *locationName = day[@"locationName"];
                        NSString *string = [NSString stringWithFormat:@"%@ - Open Now",locationName];
                        
                        NSMutableAttributedString *openNow = [[NSMutableAttributedString alloc] initWithString:string];
                        [openNow addAttribute:NSFontAttributeName
                                      value:[UIFont systemFontOfSize:9.0]
                                      range:NSMakeRange(locationName.length + 1, 10)];
                        self.locationNameLabel.attributedText = openNow;
                        self.isOpen = YES;
                    }
                }
                else
                {
                    NSString *locationName = day[@"locationName"];
                    NSString *string = [NSString stringWithFormat:@"%@",locationName];
                    
                   /* NSMutableAttributedString *closed = [[NSMutableAttributedString alloc] initWithString:string];
                    [closed addAttribute:NSFontAttributeName
                                    value:[UIFont systemFontOfSize:11.0]
                                    range:NSMakeRange(locationName.length + 1, 8)];*/
                    self.locationNameLabel.text = string;
                }
            }
            
            [day setObject:[NSString stringWithFormat:@"%d", i] forKey:@"day"];
            [days addObject:day];
        }
    }
    
    for(int i = 0; i < days.count; i++)
    {
        NSDictionary *day = [days objectAtIndex:i];
        
        switch (i) {
            case 0:
                self.row1.hidden = NO;
                self.row1Day.hidden = NO;
                self.row1Open.hidden = NO;
                self.row1Closed.hidden = NO;
                self.row1Day.text = [HelperMethods getWeekdayNameAbbr:[day[@"day"]integerValue]];
                self.row1Open.text = day[@"openTime"];
                self.row1Closed.text = day[@"closeTime"];
                break;
            case 1:
                self.row2.hidden = NO;
                self.row2Day.hidden = NO;
                self.row2Open.hidden = NO;
                self.row2Closed.hidden = NO;
                self.row2Day.text = [HelperMethods getWeekdayNameAbbr:[day[@"day"]integerValue]];
                self.row2Open.text = day[@"openTime"];
                self.row2Closed.text = day[@"closeTime"];
                break;
            case 2:
                self.row3.hidden = NO;
                self.row3Day.hidden = NO;
                self.row3Open.hidden = NO;
                self.row3Closed.hidden = NO;
                self.row3Day.text = [HelperMethods getWeekdayNameAbbr:[day[@"day"]integerValue]];
                self.row3Open.text = day[@"openTime"];
                self.row3Closed.text = day[@"closeTime"];
                break;
            case 3:
                self.row4.hidden = NO;
                self.row4Day.hidden = NO;
                self.row4Open.hidden = NO;
                self.row4Closed.hidden = NO;
                self.row4Day.text = [HelperMethods getWeekdayNameAbbr:[day[@"day"]integerValue]];
                self.row4Open.text = day[@"openTime"];
                self.row4Closed.text = day[@"closeTime"];
                break;
            case 4:
                self.row5.hidden = NO;
                self.row5Day.hidden = NO;
                self.row5Open.hidden = NO;
                self.row5Closed.hidden = NO;
                self.row5Day.text = [HelperMethods getWeekdayNameAbbr:[day[@"day"]integerValue]];
                self.row5Open.text = day[@"openTime"];
                self.row5Closed.text = day[@"closeTime"];
                break;
            case 5:
                self.row6.hidden = NO;
                self.row6Day.hidden = NO;
                self.row6Open.hidden = NO;
                self.row6Closed.hidden = NO;
                self.row6Day.text = [HelperMethods getWeekdayNameAbbr:[day[@"day"]integerValue]];
                self.row6Open.text = day[@"openTime"];
                self.row6Closed.text = day[@"closeTime"];
                break;
            case 6:
                self.row7.hidden = NO;
                self.row7Day.hidden = NO;
                self.row7Open.hidden = NO;
                self.row7Closed.hidden = NO;
                self.row7Day.text = [HelperMethods getWeekdayNameAbbr:[day[@"day"]integerValue]];
                self.row7Open.text = day[@"openTime"];
                self.row7Closed.text = day[@"closeTime"];
                break;
            
        }
    }
}

- (void)hideAllScheduleLabels
{
    self.row1.hidden = YES;
    self.row2.hidden = YES;
    self.row3.hidden = YES;
    self.row4.hidden = YES;
    self.row5.hidden = YES;
    self.row6.hidden = YES;
    self.row7.hidden = YES;
    
    self.row1Open.hidden = YES;
    self.row2Open.hidden = YES;
    self.row3Open.hidden = YES;
    self.row4Open.hidden = YES;
    self.row5Open.hidden = YES;
    self.row6Open.hidden = YES;
    self.row7Open.hidden = YES;
    
    self.row1Closed.hidden = YES;
    self.row2Closed.hidden = YES;
    self.row3Closed.hidden = YES;
    self.row4Closed.hidden = YES;
    self.row5Closed.hidden = YES;
    self.row6Closed.hidden = YES;
    self.row7Closed.hidden = YES;
    
    self.row1Day.hidden = YES;
    self.row2Day.hidden = YES;
    self.row3Day.hidden = YES;
    self.row4Day.hidden = YES;
    self.row5Day.hidden = YES;
    self.row6Day.hidden = YES;
    self.row7Day.hidden = YES;
    
}

- (void)swipeUp
{
    NSLog(@"swipe up detected");
    self.swipeUpLabel.hidden = YES;
    if(self.tableViewHeightConstraint.constant != 3.5)
    {
        self.tableViewHeightConstraint.constant = 3.5;
        self.swipeGestureViewTopConstraint.constant = 3.5;
        self.moreButtonView.constant = 66;
        [self.moreButton setTitle:@"More..." forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        
    }
}

- (void)swipeDown
{
    NSLog(@"swipe down detected");
    if(self.tableViewHeightConstraint.constant != 210)
    {
        self.tableViewHeightConstraint.constant = 210;
        self.swipeGestureViewTopConstraint.constant = 210;
        
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.swipeUpLabel.hidden = NO;
        }];
        
    }
    
}

#pragma mark - Delegate Methods

- (void)farmerProductsLoadComplete
{
    //self.products = self.userData.selectedFarmersProducts;
    
    NSMutableArray *products = [[NSMutableArray alloc]init];
    
    for(NSDictionary *dic in self.userData.selectedFarmersProducts)
    {
        if([dic[@"isActive"]boolValue])
           [products addObject:dic];
    }
    
    self.products = products;
    
    
    [self.produceTableView reloadData];
}

- (void)favoriteAdded:(int)numFavorites
{
    if([self.farmerSelected[@"followerNotification"]boolValue])
    {
        NSString *name = [NSString stringWithFormat:@"%@ %@", self.userData.firstName, self.userData.lastName];
        
        NSDictionary *notificaiton = @{
                                       @"userID" : self.farmerSelected[@"farmerID"],
                                       @"alertText" : [NSString stringWithFormat:@"%@ has favorited your farm, you now have %i followers!", name, numFavorites],
                                       @"fromUserID" : self.userData.user.uid,
                                       @"alertExpireDate" : @"",
                                       @"alertTimeSent" : @"",
                                       @"alertType" : @"3"
                                       
                                       };
        
        [[[self.userData.ref child:@"alert_queue"]childByAutoId]setValue:notificaiton];
    }
}

#pragma mark - MapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id<MKAnnotation>)annotation {
    
    MKAnnotationView *pinView = nil;
    static NSString *defaultPinID = @"pin";
    pinView = (MKAnnotationView *)
    [mV dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    
    pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    pinView.canShowCallout = NO;
    if(self.isOpen)
        pinView.image = [UIImage imageNamed:@"farmHouseGreen.png"];
    else
        pinView.image = [UIImage imageNamed:@"farmHouse.png"];
    return pinView;
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
  
    if(self.products.count == 0)
        return 1;
    else
        return self.products.count;
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"produceCell";
    static NSString *noResultsCellIdentifier = @"noResultsCell";
    
    UITableViewCell *cell;
    
    
    if(self.products.count == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:noResultsCellIdentifier forIndexPath:indexPath];
    }
    else
    {
        NSDictionary *tempDic = [self.products objectAtIndex:indexPath.section];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIImageView *produceImageView = (UIImageView *)[cell viewWithTag:5];
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
        
        
        produceImageView.layer.cornerRadius = 10;
        produceImageView.layer.masksToBounds = YES;
    }
    
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.products.count > 0)
    {
        if(self.showingFavoriteFarmer)
        {
            if([self.userData setSelectedFromFavoritesProductByProductID:[[self.products objectAtIndex:indexPath.section] objectForKey:@"productID"]])
                [self performSegueWithIdentifier:@"profileShowProductSegue" sender:self];
        }
        else if([self.userData setSelectedProductByProductID:[[self.products objectAtIndex:indexPath.section] objectForKey:@"productID"]])
            [self performSegueWithIdentifier:@"profileShowProductSegue" sender:self];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"profileShowProductSegue"])
    {
        ProductViewController *pvc = segue.destinationViewController;
        pvc.showingFavoriteFarmer = self.showingFavoriteFarmer;
        pvc.userData = self.userData;
    }
    else if([segue.identifier isEqualToString:@"profileToChatSegue"])
    {
        ChatMessagesViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
        vc.userSelected = @{
                            @"name" : self.farmerSelected[@"farmName"],
                            @"userID" : self.farmerSelected[@"farmerID"]
                            };
    }
    else if([segue.identifier isEqualToString:@"profileToChatMenuSegue"])
    {
        ChatMenuViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }
    else if([segue.identifier isEqualToString:@"customerReviewsSegue"])
    {
        CustomerReviewsViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
        vc.farmerSelected = self.farmerSelected;
    }
    
}

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
