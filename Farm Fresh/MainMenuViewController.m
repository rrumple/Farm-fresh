//
//  MainMenuViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/9/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "MainMenuViewController.h"
#import "Firebase.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
/*google
#import <GoogleSignIn/GoogleSignIn.h>
 */
#import "UIView+AddOns.h"
#import "HomeViewController.h"
#import "HelperMethods.h"
#import "SignUpViewController.h"
#import "FarmerSetupViewController.h"
#import "EditProfileViewController.h"
#import "InviteFriendsViewController.h"
#import "PostProductViewController.h"
#import "FavoritesViewController.h"
#import "ChatMenuViewController.h"
#import "EditProductViewController.h"
#import "NotificationsViewController.h"
#import "HelpViewController.h"
#import "FarmEditViewController.h"


@interface MainMenuViewController ()

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *chatBadgeLabel;

@property (nonatomic, strong) UIImageView *screenShotView;
@property (nonatomic, strong) UIButton *exitButton;
@property (nonatomic) BOOL isLogin;
@property (nonatomic, strong) NSArray *notificationsNew;


@end

@implementation MainMenuViewController


#pragma mark - Life Cycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.moveImage)
    {
        
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
         {
             CGPoint point = self.screenShotView.center;
             point.x += 250;
             self.screenShotView.center = point;
             
             CGPoint point2 = self.exitButton.center;
             point2.x += 250;
             self.exitButton.center = point2;
         }completion:^(BOOL finished)
         {
             self.moveImage = false;
             //NSLog(@"Animation Completed");
         }];
    }
    
    
    
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
   
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.chatBadgeLabel.hidden = YES;
    self.notificationsNew = [[NSArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Main_Menu_Screen_Loaded" parameters:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImage) name:HelperMethodsImageDownloadCompleted object:nil];
    
    [self.screenShotView setImage:self.screenShotImage];
    
    if(self.userData.isUserLoggedIn)
        [self getNewNotifications];
    
    if(self.userData.isUserLoggedIn && self.userData.firstName && self.userData.lastName)
    {
        [self dontShowSignUp];
        
        [self updateImage];
        
        self.displayNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.userData.firstName, self.userData.lastName];
        
        
    }
    else
    {
        if(!self.userData.firstName && !self.userData.lastName && self.userData.isUserLoggedIn)
           [self.userData userSignedOut];
        [self showSignUp];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //to bring invite cell back unhide and move up between notifications and profile
    
    self.chatBadgeLabel.layer.cornerRadius = self.chatBadgeLabel.bounds.size.height / 2;
    self.chatBadgeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.chatBadgeLabel.layer.borderWidth = 1.0f;
    
   
    
    self.profileImageView.layer.cornerRadius = 30.0f;
    self.profileImageView.layer.masksToBounds = YES;
    
    self.isLogin = NO;
    
    self.screenShotView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.screenShotView.userInteractionEnabled = YES;
    [self.view addSubview:self.screenShotView];
    
    self.exitButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 31, 24, 30)];
    
    [self.exitButton addTarget:self action:@selector(exitButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:self.exitButton];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(exitButtonPressed)];
    
    [swipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    
    [self.screenShotView addGestureRecognizer:swipe];
    
    
}



#pragma mark - IBActions

- (IBAction)signInButtonPressed:(UIButton *)sender {
    if([sender.titleLabel.text isEqualToString:@"or sign in"])
    {
        self.isLogin = YES;
        [self performSegueWithIdentifier:@"signUpSegue" sender:self];
    }
    else
    {
        [HelperMethods removeUserProfileImage];
        [self.userData userSignedOut];
        [self showSignUp];
    }
   
}

- (IBAction)sellButtonPressed:(UIButton *)sender {
    
    if(self.userData.isUserLoggedIn)
    {
        if(self.userData.isFarmer)
        {
            if(self.userData.farmDescription.length > 0 && self.userData.farmName.length > 0 && self.userData.farmLocations.count > 0 && self.userData.mySchedule && (self.userData.useChat || self.userData.useEmail || self.userData.useTelephone))
            {
                if ([self.userData getNumberOfProducts] > 0) {
                    UIAlertController *alertController = [UIAlertController
                                                          alertControllerWithTitle:@"Farm Fresh"
                                                          message:@"List a new Product for sell or edit a previously posted product."
                                                          preferredStyle:UIAlertControllerStyleActionSheet];
                    
                    
                    UIAlertAction *sellProduct = [UIAlertAction
                                                     actionWithTitle:@"Sell New Product"
                                                     style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
                                                     {
                                                          [self performSegueWithIdentifier:@"sellProductSegue" sender:self];
                                                     }];
                    
                    UIAlertAction *listProducts = [UIAlertAction
                                               actionWithTitle:@"View/Edit Products"
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   [self performSegueWithIdentifier:@"editProductsSegue" sender:self];
                                               }];
                    
                    UIAlertAction *cancelButton = [UIAlertAction
                                                   actionWithTitle:@"Cancel"
                                                   style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action)
                                                   {
                                                       
                                                   }];
                    
                    [alertController addAction: sellProduct];
                    [alertController addAction:listProducts];
                    [alertController addAction:cancelButton];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                else
                    [self performSegueWithIdentifier:@"sellProductSegue" sender:self];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:@"Farm Fresh"
                                                      message:@"List a new Product for sell or edit a previously posted product."
                                                      preferredStyle:UIAlertControllerStyleAlert];
                
                
                UIAlertAction *farmProfile = [UIAlertAction
                                              actionWithTitle:@"Update Farm Profile"
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action)
                                              {
                                                  [self performSegueWithIdentifier:@"MainMenuToFarmProfileSegue" sender:self];
                                              }];
                
                
                UIAlertAction *okButton = [UIAlertAction
                                               actionWithTitle:@"Cancel"
                                               style:UIAlertActionStyleCancel
                                               handler:^(UIAlertAction *action)
                                               {
                                                   
                                               }];
                
                [alertController addAction: farmProfile];
                [alertController addAction:okButton];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
        
        }
        else
        {
            [self performSegueWithIdentifier:@"farmerSetupSegue" sender:self];
        }
    }
    else
        [self displayNotLoggedInError];
}
#pragma mark - Methods

- (void)getNewNotifications
{
    FIRDatabaseReference *userNotificationRef = [self.userData.ref child:[NSString stringWithFormat:@"/notification/%@", self.userData.user.uid]];
    
    [userNotificationRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot2) {
        
        if(snapshot2.value == [NSNull null]) {
            
            self.notificationsNew = [[NSArray alloc]init];
            
        } else {
            NSDictionary *value1 = snapshot2.value;
            NSArray *keys = value1.allKeys;
            
            self.notificationsNew = keys;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                if(self.notificationsNew.count > 9)
                {
                    self.chatBadgeLabel.text = @"9+";
                }
                else
                    self.chatBadgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.notificationsNew.count];
                
                
                if(self.notificationsNew.count > 0)
                    self.chatBadgeLabel.hidden = NO;
                else
                    self.chatBadgeLabel.hidden = YES;

                
            
            });
            
        }
        
    }];
    
}


- (void)displayNotLoggedInError
{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Account Error"
                                          message:@"Please Create or Login to an account."
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *signUpAction = [UIAlertAction
                                     actionWithTitle:@"Sign Up"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         self.isLogin = NO;
                                         [self performSegueWithIdentifier:@"signUpSegue" sender:self];
                                     }];
    UIAlertAction *signInAction = [UIAlertAction
                                   actionWithTitle:@"Sign In"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       self.isLogin = YES;
                                       [self performSegueWithIdentifier:@"signUpSegue" sender:self];
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction *action)
                               {
                                   
                               }];
    
    
    [alertController addAction:signUpAction];
    [alertController addAction:signInAction];
    [alertController addAction: okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)exitButtonPressed
{
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         CGPoint point = self.screenShotView.center;
         point.x -= 250;
         self.screenShotView.center = point;
         
         CGPoint point2 = self.exitButton.center;
         point2.x -= 250;
         self.exitButton.center = point2;
     }completion:^(BOOL finished)
     {
         [self.navigationController popViewControllerAnimated:NO];
     }];
}

- (void)showSignUp
{
    self.signInButton.hidden = false;
    self.signUpButton.hidden = false;
    self.profileImageView.image = [UIImage imageNamed:@"profile"];
    self.displayNameLabel.hidden = true;
}

- (void)dontShowSignUp
{
    self.signInButton.hidden = true;
    //[self.signInButton setTitle:@"sign out" forState:UIControlStateNormal];
    self.signUpButton.hidden = true;
    self.displayNameLabel.hidden = false;
}

- (void)updateImage
{
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/profile.png",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
        [self.profileImageView setImage:image];
        
    
        
    }
    else
    {
        if(self.userData.useCustomProfileImage)
        {
            [HelperMethods downloadUserProfileImageFromFirebase:self.userData];
        }
        else
            [HelperMethods downloadSingleImageFromBaseURL:self.userData.imageURL withFilename:@"profile.png" saveToDisk:YES replaceExistingImage:NO];
    }
    
}


#pragma mark - Navigation
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if(self.userData.isUserLoggedIn)
        return YES;
    else
    {
        if([identifier isEqualToString:@"signUpSegue"] || [identifier isEqualToString:@"helpSegue"] || [identifier isEqualToString:@"inviteSegue"])
        {
            return YES;
        }
        else
        {
            [self displayNotLoggedInError];
            return NO;
        }
    }
    
    return NO;
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"signUpSegue"])
    {
        SignUpViewController *suvc = segue.destinationViewController;
        
        suvc.isLogin = self.isLogin;
        suvc.userData = self.userData;
        
        self.isLogin = NO;
    }
    else if([segue.identifier isEqualToString:@"farmerSetupSegue"])
    {
        FarmerSetupViewController *fsvc = segue.destinationViewController;
        
        fsvc.userData = self.userData;
        fsvc.menuImage = [UIView captureView:self.view];
    }
    else if([segue.identifier isEqualToString:@"editProfileSegue"])
    {
        EditProfileViewController *epvc = segue.destinationViewController;
        
        epvc.userData = self.userData;
        epvc.menuImage = [UIView captureView:self.view];
        
    }
    else if([segue.identifier isEqualToString:@"inviteSegue"])
    {
        InviteFriendsViewController *ifvc = segue.destinationViewController;
        
        ifvc.menuImage = [UIView captureView:self.view];
    }
    else if([segue.identifier isEqualToString:@"sellProductSegue"])
    {
        PostProductViewController *ppvc = segue.destinationViewController;
        
        ppvc.userData = self.userData;
        ppvc.menuImage = [UIView captureView:self.view];
    }
    else if([segue.identifier isEqualToString:@"favoritesSegue"])
    {
         FavoritesViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }
    else if([segue.identifier isEqualToString:@"chatSegue"])
    {
        ChatMenuViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }
    else if([segue.identifier isEqualToString:@"editProductsSegue"])
    {
        EditProductViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }
    else if([segue.identifier isEqualToString:@"notificationsSegue"])
    {
        NotificationsViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }
    else if([segue.identifier isEqualToString:@"helpSegue"])
    {
        HelpViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }
    else if([segue.identifier isEqualToString:@"MainMenuToFarmProfileSegue"])
    {
        FarmEditViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
        vc.menuImage = [UIView captureView:self.view];
    }
}







@end
