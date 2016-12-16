//
//  ProductViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/22/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "ProductViewController.h"
#import "HelperMethods.h"
#import <Mapkit/Mapkit.h>
#import "FarmProfileViewController.h"
#import "constants.h"
#import "MainMenuViewController.h"
#import "ChatMessagesViewController.h"
#import "CustomerReviewsViewController.h"
#import "UIView+Addons.h"

@interface ProductViewController ()<MKMapViewDelegate, UserModelDelegate, UIScrollViewDelegate>

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
@property (weak, nonatomic) IBOutlet UIView *locationScheduleView;
@property (weak, nonatomic) IBOutlet UIButton *moreLocationsButton;

@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (nonatomic) BOOL isOpen;
@property (nonatomic) int timerCount;

@property (weak, nonatomic) IBOutlet UIPageControl *productImagePageControl;
@property (weak, nonatomic) IBOutlet UILabel *swipeUpLabel;

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *productHeadlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *productScrollView;
@property (weak, nonatomic) IBOutlet UIButton *locationAddressLabel;
@property (weak, nonatomic) IBOutlet MKMapView *locationMapView;
@property (weak, nonatomic) IBOutlet UIImageView *farmerProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *farmNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreProductsButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *reviewsButton;
@property (weak, nonatomic) IBOutlet UIImageView *star1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star2ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star3ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star4ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star5ImageView;
@property (weak, nonatomic) IBOutlet UILabel *noRatingLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageSelectorImageView4;
@property (weak, nonatomic) IBOutlet UIImageView *imageSelectorImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageSelectorImageView3;
@property (weak, nonatomic) IBOutlet UIButton *phoneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backButtonBackDrop;





@property (nonatomic, strong) NSDictionary *locationSelected;
@property (nonatomic, strong) NSDictionary *farmerSelected;
@property (nonatomic, strong) NSDictionary * productSelected;
@property (nonatomic) BOOL showMoreProducts;
@property (nonatomic) BOOL isFavorite;

@property (nonatomic, strong) UIImage *image1;
@property (nonatomic, strong) UIImage *image2;
@property (nonatomic, strong) UIImage *image3;
@property (nonatomic, strong) UIImage *image4;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (nonatomic) int imageCounter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageSelectorViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeightconstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *swipeUpLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *farmerProfileVerticalConstraint;

@end

@implementation ProductViewController

#pragma mark - Life Cycle

-(void)viewDidLayoutSubviews
{
    if(IS_IPHONE_4_OR_LESS)
    {
        self.productScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 855);
        self.swipeUpLabel.hidden = NO;
    }
    else if(IS_IPHONE_5)
    {
        self.productScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 775);
        self.swipeUpLabel.hidden = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.userData.delegate = self;
    [self setupSwipeGestures];
    
    self.productScrollView.delegate = self;
    
    self.farmerProfileImageView.layer.cornerRadius = 30.0f;
    self.farmerProfileImageView.layer.masksToBounds = YES;
    
    [self.imageSelectorImageView2.layer setCornerRadius:4.0f];
    [self.imageSelectorImageView3.layer setCornerRadius:4.0f];
    [self.imageSelectorImageView4.layer setCornerRadius:4.0f];
    self.imageSelectorImageView2.layer.masksToBounds = YES;
    self.imageSelectorImageView3.layer.masksToBounds = YES;
    self.imageSelectorImageView4.layer.masksToBounds = YES;
    [self.backButtonBackDrop.layer setCornerRadius:4.0f];
    self.backButtonBackDrop.layer.masksToBounds = YES;
    
   // [self.ImageSelecterImageView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    //[self.ImageSelecterImageView.layer setBorderWidth:1.5f];


    if(IS_IPHONE_6P)
    {
        self.scrollViewHeightconstraint.constant = 725;
        [self.view layoutIfNeeded];
    }
    else if(IS_IPHONE_4_OR_LESS)
    {
        self.swipeUpLabelTopConstraint.constant = -65;
        self.farmerProfileVerticalConstraint.constant = -18;
        [self.view layoutIfNeeded];
    }
    
    
    
    self.imageCounter = 0;
    self.timerCount = 0;
   
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:ALERT_RECIEVED]boolValue])
    {
        self.showingFavoriteFarmer = YES;
        self.mainView.hidden = NO;
        self.loadingView.hidden = NO;
        switch ([[[NSUserDefaults standardUserDefaults] objectForKey:SCREEN_TO_LOAD]intValue]) {
            case 1:
                
                [self.userData updateFavoriteFarmersData];
                break;
                
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:ALERT_RECIEVED];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SCREEN_TO_LOAD];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }
    else
    {
        self.productSelected = [self.userData getProductSelectedIsFavorite:self.showingFavoriteFarmer];
        self.locationSelected = [self.userData getLocationSelectedIsFavorite:self.showingFavoriteFarmer ];
        self.farmerSelected = [self.userData getFarmerSelectedIsFavorite:self.showingFavoriteFarmer ];
        
        [self setupScreen];
    }
    
    
   
    


    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     [FIRAnalytics logEventWithName:@"Product_View_Screen_Loaded" parameters:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImage) name:HelperMethodsImageDownloadCompleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productImageDownloadComplete:) name:@"HelperMethodsProductImageDownloadComplete" object:nil];
    
    
    
    [self updateImage];
    
    self.profileButton.enabled = YES;
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

- (IBAction)backButtonPressed {
    
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

- (IBAction)moreProductsButtonPressed:(UIButton *)sender {
    
    sender.enabled = false;
    
    self.showMoreProducts = true;
    
    [self performSegueWithIdentifier:@"productFarmerProfileSegue" sender:self];
}

- (IBAction)followButtonPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    
    
    
    if(self.isFavorite)
    {
        [self.userData removeFarmer:self.farmerSelected[@"farmerID"] AsFavorite:[[self.userData.favorites objectForKey:self.farmerSelected[@"farmerID"]]objectForKey:@"favoriteID"]];
        
        [self.followButton setImage:[UIImage imageNamed:@"favoriteButton"] forState:UIControlStateNormal];
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
        
        [self.followButton setImage:[UIImage imageNamed:@"followCopy"] forState:UIControlStateNormal];
        
        self.isFavorite = YES;
        
    }
    
    sender.enabled = YES;
    
    
}

- (IBAction)pickUpButtonPressed:(UIButton *)sender {
    
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

- (IBAction)profileButtonPressed:(UIButton *)sender {
    
    sender.enabled = false;
    
    self.showMoreProducts = false;
    
    [self performSegueWithIdentifier:@"productFarmerProfileSegue" sender:self];
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

- (IBAction)chatButtonPressed:(UIButton *)sender {
    
    [self.userData addUserToFarmersChatList:self.farmerSelected[@"farmerID"] isFavoriting:NO];
    
    [self performSegueWithIdentifier:@"productToChatSegue" sender:self];
}

- (IBAction)addressButtonPressed:(UIButton *)sender {
    
    NSString *address = self.locationSelected[@"fullAddress"];
    
    address = [address stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    address = [address stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString* url = [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@&dirflg=d&t=h",address];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

#pragma mark - Methods

- (void)productImageDownloadComplete:(NSNotification *)notification
{
    int index = [notification.object intValue];
    
    [self setProductImage:index];
    
}

- (void)setupScreen
{
    if([self.userData.favorites objectForKey:self.farmerSelected[@"farmerID"]])
    {
        if([[[self.userData.favorites objectForKey:self.farmerSelected[@"farmerID"]]objectForKey:@"farmerID"] isEqualToString:self.userData.user.uid])
        {
            self.followButton.enabled = NO;
            self.followersLabel.hidden = NO;
            self.followersCountLabel.text = self.userData.numFavorites;
            self.followersCountLabel.hidden = NO;
        }
        else
        {
            self.isFavorite = YES;
            [self.followButton setImage:[UIImage imageNamed:@"followCopy"] forState:UIControlStateNormal];
        }
    }
    else if([self.farmerSelected[@"farmerID"] isEqualToString:self.userData.user.uid])
    {
        self.followButton.enabled = NO;
        self.followersLabel.hidden = NO;
        self.followersCountLabel.text = self.userData.numFavorites;
        self.followersCountLabel.hidden = NO;
    }
    else
        self.isFavorite = NO;
    
    self.priceLabel.text = [NSString stringWithFormat:@"$%@", self.productSelected[@"amount"]];
    self.priceDescriptionLabel.text = self.productSelected[@"amountDescription"];
    
    self.productHeadlineLabel.text = self.productSelected[@"productHeadline"];
    self.productDescriptionLabel.text = self.productSelected[@"productDescription"];
    self.timeLabel.text = [NSString stringWithFormat:@"Posted - %@", [HelperMethods getTimeSinceDate:self.productSelected[@"datePosted"]]];
    
    [self updateMap];
    
    [self setupProductImages];
    
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

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    
    if(self.imageCounter != 0)
    {
        NSInteger currentPage = self.productImagePageControl.currentPage;
        
        
        if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
            NSLog(@"Left Swipe");
            
            currentPage++;
            if(currentPage == self.imageCounter)
                currentPage = self.imageCounter-1;
            
        }
        
        if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
            NSLog(@"Right Swipe");
            currentPage--;
            if(currentPage < 0)
                currentPage = 0;
        }
        
        switch (currentPage) {
            case 0:
                self.productImageView.image = self.image1;
                break;
            case 1:
                self.productImageView.image = self.image2;
                break;
            case 2:
                self.productImageView.image = self.image3;
                break;
            case 3:
                self.productImageView.image = self.image4;
                break;
                
        
        }
        
        self.productImagePageControl.currentPage = currentPage;
        
    }
}

- (void)setupSwipeGestures
{
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [self.productImageView addGestureRecognizer:swipeLeft];
    [self.productImageView addGestureRecognizer:swipeRight];
}

-(void)setProductImage:(long)index
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@_%ld.png",docDir, self.productSelected[@"productID"], index];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        self.imageCounter++;
        switch (index) {
            case 1:
                self.image1 = [UIImage imageWithContentsOfFile:pngFilePath];
                [self.productImageView setImage:self.image1];
                break;
            case 2:
                self.image2 = [UIImage imageWithContentsOfFile:pngFilePath];
                break;
            case 3:
                self.image3 = [UIImage imageWithContentsOfFile:pngFilePath];
                break;
            case 4:
                self.image4 = [UIImage imageWithContentsOfFile:pngFilePath];
                break;
                
        }
        
         [self.productImagePageControl setNumberOfPages:self.imageCounter];
        
        switch (self.imageCounter) {
            case 0:
                self.imageSelectorImageView2.hidden = YES;
                self.imageSelectorImageView3.hidden = YES;
                self.imageSelectorImageView4.hidden = YES;
                self.productImagePageControl.hidden = YES;
                break;
            case 1:
                self.imageSelectorImageView2.hidden = YES;
                self.imageSelectorImageView3.hidden = YES;
                self.imageSelectorImageView4.hidden = YES;
                self.productImagePageControl.hidden = YES;
                break;
            case 2:
                self.imageSelectorImageView2.hidden = YES;
                self.imageSelectorImageView3.hidden = NO;
                self.imageSelectorImageView4.hidden = NO;
                self.imageSelectorViewWidthConstraint.constant = 70;
                self.productImagePageControl.hidden = NO;
                break;
            case 3:
                self.imageSelectorImageView2.hidden = NO;
                self.imageSelectorImageView3.hidden = YES;
                self.imageSelectorImageView4.hidden = NO;
                self.imageSelectorViewWidthConstraint.constant = 70;
                self.productImagePageControl.hidden = NO;
                break;
            case 4:
                self.imageSelectorImageView2.hidden = NO;
                self.imageSelectorImageView3.hidden = NO;
                self.imageSelectorImageView4.hidden = YES;
                self.imageSelectorViewWidthConstraint.constant = 70;
                self.productImagePageControl.hidden = NO;
                break;
                
                
            default:
                break;
        }
        
        /*
        [UIView animateWithDuration:.5 animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
         */
        
    }


}

- (void)setupProductImages
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *pngFilePath;
    for(int i = 1; i < 5; i++)
    {
        switch (i) {
            case 1:
                pngFilePath = [NSString stringWithFormat:@"%@/%@_1.png",docDir, self.productSelected[@"productID"]];
                break;
            case 2:
                pngFilePath = [NSString stringWithFormat:@"%@/%@_2.png",docDir, self.productSelected[@"productID"]];
                break;
            case 3:
                pngFilePath = [NSString stringWithFormat:@"%@/%@_3.png",docDir, self.productSelected[@"productID"]];
                break;
            case 4:
                pngFilePath = [NSString stringWithFormat:@"%@/%@_4.png",docDir, self.productSelected[@"productID"]];
                break;
                
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
        {
            self.imageCounter++;
            switch (i) {
                case 1:
                    self.image1 = [UIImage imageWithContentsOfFile:pngFilePath];
                    [self.productImageView setImage:self.image1];
                    break;
                case 2:
                    self.image2 = [UIImage imageWithContentsOfFile:pngFilePath];
                    break;
                case 3:
                    self.image3 = [UIImage imageWithContentsOfFile:pngFilePath];
                    break;
                case 4:
                    self.image4 = [UIImage imageWithContentsOfFile:pngFilePath];
                    break;
                    
            }
            
        }
        else
        {
            [HelperMethods downloadProductImageFromFirebase:self.productSelected[@"farmerID"] forProductID:self.productSelected[@"productID"] imageNumber:i];
            
            /* if(i == 1)
            {
                [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkTimer) userInfo:nil repeats:NO];
            }*/
        }
        
    }
    
    [self.productImagePageControl setNumberOfPages:self.imageCounter];
    
    switch (self.imageCounter) {
        case 0:
            self.imageSelectorImageView2.hidden = YES;
            self.imageSelectorImageView3.hidden = YES;
            self.imageSelectorImageView4.hidden = YES;
            self.productImagePageControl.hidden = YES;
            break;
        case 1:
            self.imageSelectorImageView2.hidden = YES;
            self.imageSelectorImageView3.hidden = YES;
            self.imageSelectorImageView4.hidden = YES;
            self.productImagePageControl.hidden = YES;
            break;
        case 2:
            self.imageSelectorImageView2.hidden = NO;
            self.imageSelectorImageView3.hidden = YES;
            self.imageSelectorImageView4.hidden = YES;
            self.imageSelectorViewWidthConstraint.constant = 70;
            self.productImagePageControl.hidden = NO;
            break;
        case 3:
            self.imageSelectorImageView2.hidden = YES;
            self.imageSelectorImageView3.hidden = NO;
            self.imageSelectorImageView4.hidden = YES;
            self.imageSelectorViewWidthConstraint.constant = 70;
            self.productImagePageControl.hidden = NO;
            break;
        case 4:
            self.imageSelectorImageView2.hidden = YES;
            self.imageSelectorImageView3.hidden = YES;
            self.imageSelectorImageView4.hidden = NO;
            self.imageSelectorViewWidthConstraint.constant = 70;
            self.productImagePageControl.hidden = NO;
            break;
            
            
        default:
            break;
    }
    
    /*
    [UIView animateWithDuration:.5 animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
    */
    
    
}

- (void)checkTimer
{
    self.timerCount++;
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@_1.png",docDir, self.productSelected[@"productID"]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        self.image1 = [UIImage imageWithContentsOfFile:pngFilePath];
        [self.productImageView setImage:self.image1];
    }
    else
    {
        if(self.timerCount < 5)
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkTimer) userInfo:nil repeats:NO];
        else
            self.timerCount = 0;
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
        [self.farmerProfileImageView setImage:image];
        
    }
    else
    {
        
        [HelperMethods downloadOtherUsersFarmProfileImageFromFirebase:self.farmerSelected[@"farmerID"]];
        
    }
    
}

- (void)updateMap
{
    [self.locationAddressLabel setTitle:self.locationSelected[@"fullAddress"] forState:UIControlStateNormal];
    
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
                    
                  /*  NSMutableAttributedString *closed = [[NSMutableAttributedString alloc] initWithString:string];
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

#pragma mark - Delegate Methods

- (void)favoriteFarmersUpdateFailed
{
    [self.navigationController popViewControllerAnimated:YES];
    [self presentViewController: [UIView createSimpleAlertWithMessage:@"There was a problem loading the product, try again later"andTitle:@"Error!" withOkButton:NO] animated: YES completion:^{
        
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(IS_IPHONE_4_OR_LESS || IS_IPHONE_5)
        self.swipeUpLabel.hidden = YES;
}


- (void)farmerProductsLoadComplete
{
    NSLog(@"Farmer Products Load Complete");
    [self.userData setSelectedFromFavoritesProductByProductID:[[NSUserDefaults standardUserDefaults] objectForKey:@"productID"]];
    self.productSelected = [self.userData getProductSelectedIsFavorite:YES];
    self.locationSelected = [self.userData getLocationSelectedIsFavorite:YES ];
    self.farmerSelected = [self.userData getFarmerSelectedIsFavorite:YES ];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"productID"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"fromUserID"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self setupScreen];
    self.mainView.hidden = NO;
    self.loadingView.hidden = YES;
}

- (void)favoriteFarmersUpdated
{
    
    NSLog(@"FROM USERID: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"fromUserID"]);
    
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"fromUserID"] isEqualToString:@""] && [[NSUserDefaults standardUserDefaults] objectForKey:@"fromUserID"] != nil && [[NSUserDefaults standardUserDefaults] objectForKey:@"fromUserID"] != (id)[NSNull null])
    {
        for(int i = 0; i < self.userData.favoriteFarmersData.count; i++)
        {
            if([self.userData.favoriteFarmersData[i][@"farmerID"] isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"fromUserID"]])
            {
                self.userData.searchResultSelected = i;
                break;
            }
        }
        
        [self.userData getProductsOfSelectedFarmerIsFavorite:YES];
    
    }
    

    
    
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
   if([segue.identifier isEqualToString: @"productFarmerProfileSegue"])
   {
       FarmProfileViewController *fpvc = segue.destinationViewController;
       fpvc.showingFavoriteFarmer = self.showingFavoriteFarmer;
       fpvc.userData = self.userData;
       fpvc.showMoreProducts = self.showMoreProducts;
       
   }
   else if([segue.identifier isEqualToString:@"productToChatSegue"])
   {
       ChatMessagesViewController *vc = segue.destinationViewController;
       
       vc.userData = self.userData;
       vc.userSelected = @{
                           @"name" : self.farmerSelected[@"farmName"],
                           @"userID" : self.farmerSelected[@"farmerID"]
                           };
   }
   else if([segue.identifier isEqualToString:@"productCustomerReviewsSegue"])
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



@end
