//
//  EmailSignUpViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/14/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "EmailSignUpViewController.h"
#import "MainMenuViewController.h"
#import "Firebase.h"
#import "HelperMethods.h"
#import "UIView+AddOns.h"
#import "HomeViewController.h"

@interface EmailSignUpViewController() <UserModelDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginButtonTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpButtonTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *passwordDetailLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *spinnerView;
@property (weak, nonatomic) IBOutlet UILabel *spinnerViewLabel;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UIView *emailPasswordView;
@property (weak, nonatomic) IBOutlet UIView *spacerView;

@end

@implementation EmailSignUpViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userData.delegate = self;
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.emailTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"1"] forKey:@"isUsingGPSForSearches"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self.nameView.layer setCornerRadius:4.0f];
    [self.emailPasswordView.layer setCornerRadius:4.0f];
    
    if(self.isLogin)
    {
        [self setupForLogin];
    }
    
     [self.view addGestureRecognizer:[UIView setupTapGestureWithTarget:self Action:@selector(hideKeyboard) cancelsTouchesInview:NO setDelegate:YES]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Email_SignUp_Login_Screen_Loaded" parameters:nil];
}

#pragma mark - IBActions


- (IBAction)signUpButtonPressed:(UIButton *)sender
{
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.emailTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
    
    if(!self.isLogin)
    {
        if(self.firstNameTextField.text.length > 0)
        {
            if(self.lastNameTextField.text.length > 0)
            {
                NSString *email = [self.emailTextfield.text stringByReplacingOccurrencesOfString:@" " withString:@""];
                if([HelperMethods isEmailValid:email])
                {
                    if(self.passwordTextfield.text.length > 5)
                    {
                        self.spinnerView.hidden = NO;
                        self.spinnerViewLabel.text = @"Creating Account...";
                        sender.enabled = false;
                        self.ref = [[FIRDatabase database] reference];
                        [[FIRAuth auth] createUserWithEmail:email password:self.passwordTextfield.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                            if (error) {
                                sender.enabled = true;
                                self.spinnerView.hidden = YES;
                                // There was an error creating the account
                                [self presentViewController: [UIView createSimpleAlertWithMessage:@"There was an error creating your account." andTitle:@"Error 225" withOkButton:NO] animated: YES completion: nil];
                            } else {
                                NSString *uid = user.uid;
                                NSLog(@"Successfully created user account with uid: %@", uid);
                                
                                [[FIRAuth auth] signInWithEmail:email password:self.passwordTextfield.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                                    if (error) {
                                        sender.enabled = true;
                                        self.spinnerView.hidden = YES;
                                        // There was an error logging in to this account
                                        [self presentViewController: [UIView createSimpleAlertWithMessage:@"Account was created successfully but there was an error logging in, please close the app and relaunch" andTitle:@"Error 226" withOkButton:NO] animated: YES completion: nil];
                                    } else {
                                        // We are now logged in
                                        
                                        if (user) {
                                            self.userData.user = user;
                                            //Start Logging In spinner
                                            self.spinnerView.hidden = NO;
                                            self.spinnerViewLabel.text = @"Logging In...";
                                            
                                            
                                            [[self.userData.ref child:[NSString stringWithFormat:@"users/%@", user.uid]]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                                                
                                                
                                                if(!snapshot.hasChildren)
                                                {
                                                    id<FIRUserInfo> profile;
                                                    NSString *providerId;
                                                    NSString *uid;
                                                    
                                                    NSString *email;
                                                    
                                                    if (user != nil) {
                                                        profile = user.providerData.firstObject;
                                                        
                                                        providerId = profile.providerID;
                                                        uid = user.uid;  // Provider-specific UID
                                                        
                                                        email = user.email;
                                                        
                                                        
                                                    } else {
                                                        // No user is signed in.
                                                    }
                                                    // save the user's profile into the database so we can list users,
                                                    // use them in Security and Firebase Rules, and show profiles
                                                    NSDictionary *newUser = @{
                                                                              @"provider": providerId,
                                                                              @"firstName": self.firstNameTextField.text,
                                                                              @"lastName" : self.lastNameTextField.text,
                                                                              @"profileImage": @"",
                                                                              @"email": email,
                                                                              @"searchRadius" : @"8.046720",
                                                                              @"useCustomProfileImage" : @"1"
                                                                              };
                                                    
                                                    
                                                    [[[self.ref child:@"users"]
                                                      child:user.uid] updateChildValues:newUser withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                                                         [FIRAnalytics logEventWithName:@"Email_Sign_Up_Used" parameters:nil];
                                                    }];
                                                    
                                                    [self.userData updateUserStatus];
                                                    
                                                }
                                                else
                                                {
                                                     [FIRAnalytics logEventWithName:@"Email_Sign_Up_Used" parameters:nil];
                                                    [self.userData updateUserStatus];
                                                }
                                                
                                                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
                                                {
                                                    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
                                                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                                                }
                                                else
                                                {
                                                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                                                }
                                            }];
                                        }
                                        else
                                        {
                                            sender.enabled = true;
                                            self.spinnerView.hidden = YES;
                                            [self presentViewController: [UIView createSimpleAlertWithMessage:@"Account was created successfully but there was an error logging in, please close the app and relaunch" andTitle:@"Error 227" withOkButton:NO] animated: YES completion: nil];
                                        }
                                        
                                        
                                    }
                                }];
                                
                                
                            }
                        }];
                    }
                    else
                    {
                        [self presentViewController: [UIView createSimpleAlertWithMessage:@"Password needs to be 6 or more characters" andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
                    }
                }
                else
                {
                    [self presentViewController: [UIView createSimpleAlertWithMessage:@"Email address not valid." andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
                }

            }
            else
            {
                 [self presentViewController: [UIView createSimpleAlertWithMessage:@"Last name field is empty."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
            }
        }
        else
        {
            [self presentViewController: [UIView createSimpleAlertWithMessage:@"First name field is empty."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
        }
    }
    else
    {
        self.isLogin = NO;
        [self setupForSignUp];
    }
}

- (IBAction)loginButtonPressed:(UIButton *)sender {
    
    if(self.isLogin)
    {
         NSString *email = [self.emailTextfield.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if([HelperMethods isEmailValid:email])
        {
            sender.enabled = false;
         
            self.ref = [[FIRDatabase database] reference];
            
            [[FIRAuth auth] signInWithEmail:email password:self.passwordTextfield.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
               
          if (error) {
              self.passwordTextfield.text = @"";
              UIAlertController *alertController = [UIAlertController
                                                    alertControllerWithTitle:@"Login Error"
                                                    message:@"The Email Address or Password entered was incorrect."
                                                    preferredStyle:UIAlertControllerStyleAlert];
        
              
              UIAlertAction *forgotPassword = [UIAlertAction
                                         actionWithTitle:@"Forgot Password"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action)
                                         {
                                             [[FIRAuth auth]  sendPasswordResetWithEmail:email completion:^(NSError * _Nullable error) {
                                                 
                                                 if (error) {
                                                     // There was an error processing the request
                                                 } else {
                                                     [self presentViewController: [UIView createSimpleAlertWithMessage:@"An email has been sent with instruction on how to reset your password" andTitle:@"Password Reset" withOkButton:YES] animated: YES completion: nil];
                                                 }
                                             }];
                                         }];
              
              UIAlertAction *okAction = [UIAlertAction
                                         actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action)
                                         {
                                             
                                         }];
              
              [alertController addAction: okAction];
              [alertController addAction:forgotPassword];
              
              [self presentViewController:alertController animated:YES completion:nil];
              self.loginButton.enabled = YES;
          } else {
              self.spinnerView.hidden = NO;
              // We are now logged in
               [FIRAnalytics logEventWithName:@"Email_Login_Used" parameters:nil];
              [self.userData updateUserStatus];
              
              if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
              {
                  [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
                  [[UIApplication sharedApplication] registerForRemoteNotifications];
              }
              else
              {
                  [[UIApplication sharedApplication] registerForRemoteNotifications];
              }
              
          }
      }];
            
        }
        else
        {
            [self presentViewController: [UIView createSimpleAlertWithMessage:@"Invalid Email Address Entered" andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
        }
    }
    else
    {
        self.isLogin = YES;
        [self setupForLogin];
    }
}

- (IBAction)termsAndConditonsButtonPressed:(UIButton *)sender {
}

- (IBAction)privacyPolicyButtonPressed:(UIButton *)sender {
    
       [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.farmfresh.io/privacy-policy.html"]];
}

- (IBAction)exitButtonPressed:(UIButton *)sender {
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    BOOL matchFound = NO;
    
    for(int i = 0; i < viewControllers.count;i++)
    {
        id obj = [viewControllers objectAtIndex:i];
        if([obj isKindOfClass:[MainMenuViewController class]])
        {
            matchFound = YES;
            [self.navigationController popToViewController:obj animated:YES];
        }
        
    }
    
    if(!matchFound)
    {
        for(int i = 0; i < viewControllers.count;i++)
        {
            id obj = [viewControllers objectAtIndex:i];
            if([obj isKindOfClass:[HomeViewController class]])
            {
                matchFound = YES;
                [self.navigationController popToViewController:obj animated:YES];
            }
            
        }
    }
    
}

#pragma mark - Methods

- (void)hideKeyboard
{
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.emailTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
}

- (void)setupForLogin
{
    CGFloat height = self.nameView.frame.size.height;
    self.spacerView.hidden = YES;
    self.emailViewTopConstraint.constant = -(height);
    
    CGFloat tempConstraint =self.signUpButtonTopConstraint.constant;
    
    self.signUpButtonTopConstraint.constant = self.loginButtonTopConstraint.constant;
    self.loginButtonTopConstraint.constant = tempConstraint;
    self.titleWidthConstraint.constant = 60;
    [self.view layoutIfNeeded];
    
    [self.signUpButton setImage:nil forState:UIControlStateNormal];
    [self.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.loginButton setTitle:@"" forState:UIControlStateNormal];
    [self.loginButton setImage:[UIImage imageNamed:@"login"] forState:UIControlStateNormal];
    self.titleImage.image = [UIImage imageNamed:@"loginTitle"];
    self.passwordDetailLabel.hidden = YES;
}

- (void)setupForSignUp
{
    self.spacerView.hidden = NO;
    self.emailViewTopConstraint.constant = 0;
    CGFloat tempConstraint =self.signUpButtonTopConstraint.constant;
    
    self.signUpButtonTopConstraint.constant = self.loginButtonTopConstraint.constant;
    self.loginButtonTopConstraint.constant = tempConstraint;
    self.titleWidthConstraint.constant = 84;
    [self.view layoutIfNeeded];
    
    [self.loginButton setImage:nil forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    
    [self.signUpButton setTitle:@"" forState:UIControlStateNormal];
    [self.signUpButton setImage:[UIImage imageNamed:@"signup"] forState:UIControlStateNormal];
    
    self.titleImage.image = [UIImage imageNamed:@"loginTop"];
    
    self.passwordDetailLabel.hidden = NO;
    
}

#pragma mark - Delegate Methods

- (void)updateStatusComplete
{
    self.spinnerView.hidden = YES;
    //Stop Logging In Spinner
    [self exitButtonPressed:nil];
}

#pragma mark - TextField Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.tag) {
        case 1: [self.lastNameTextField becomeFirstResponder];
            break;
        case 2: [self.emailTextfield becomeFirstResponder];
            break;
        case 3: [self.passwordTextfield becomeFirstResponder];
            break;
        case 4: [textField resignFirstResponder];
            break;
            
            
    }
    
    return YES;
}

#pragma mark - Navigation




@end
