//
//  SignUpViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/11/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "SignUpViewController.h"
#import "Firebase.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
/* google
#import <GoogleSignIn/GoogleSignIn.h>
 */
#import "EmailSignUpViewController.h"

@interface SignUpViewController () <FBSDKLoginButtonDelegate, UserModelDelegate>//, GIDSignInUIDelegate, GIDSignInDelegate>
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *loginButton;
/* google
@property (weak, nonatomic) IBOutlet GIDSignInButton *googleLoginButton;
 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *spinnerView;


@end

@implementation SignUpViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.isLogin)
        self.titleLabel.text = @"Login";

    self.loginButton.readPermissions =  @[@"public_profile", @"email"];
    self.loginButton.delegate = self;
    
    self.userData.delegate = self;
    
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"1"] forKey:@"isUsingGPSForSearches"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    // Setup delegates
    /*google
    GIDSignIn *googleSignIn = [GIDSignIn sharedInstance];
    googleSignIn.delegate = self;
    googleSignIn.uiDelegate = self;
     */
    // Attempt to sign in silently, this will succeed if
    // the user has recently been authenticated
    //[googleSignIn signInSilently];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Sign_Up_Screen_Loaded" parameters:nil];
}

#pragma mark - IBActions
- (IBAction)privacyPolicyButtonPressed {
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.farmfresh.io/privacy-policy.html"]];
}

- (IBAction)exitButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signUpButtonPressed {
    
    self.isLogin = NO;
    
    [self performSegueWithIdentifier:@"emailSignUpSegue" sender:self];
    
}

- (IBAction)loginButtonPressed {
    
    self.isLogin = YES;
    
     [self performSegueWithIdentifier:@"emailSignUpSegue" sender:self];
}

#pragma mark - Methods

-(void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{

    [[FIRAuth auth] signOut:nil];
    
}


#pragma mark - Delegate Methods

- (void)updateStatusComplete
{
    //Stop Logging In Spinner
    self.spinnerView.hidden = YES;
    [self exitButton];
}
/*google
// Implement the required GIDSignInDelegate methods
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if (error == nil) {
        
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
         {
            if (error) {
                // Error authenticating with Firebase with OAuth token
            } else {
                // User is now logged in!
                NSLog(@"Successfully logged in! %@", user);
                
                if (user) {
                     //Start Logging In Spinner
                    self.spinnerView.hidden = NO;
                    
                    // save the user's profile into the database so we can list users,
                    // use them in Security and Firebase Rules, and show profiles
                    id<FIRUserInfo> profile;
                    NSString *providerId;
                    NSString *uid;
                    NSString *name;
                    NSString *email;
                    NSURL *photoUrl;
                    if (user != nil) {
                        profile = user.providerData.firstObject;
                        
                        providerId = profile.providerID;
                        uid = profile.uid;  // Provider-specific UID
                        name = profile.displayName;
                        email = profile.email;
                        photoUrl = profile.photoURL;
                        
                    } else {
                        // No user is signed in.
                    }
                     NSArray *nameArray = [name componentsSeparatedByString:@" "];
                    
                    [[self.userData.ref child:[NSString stringWithFormat:@"users/%@", user.uid]]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                        
                        if(!snapshot.hasChildren)
                        {
                    
                            NSDictionary *newUser = @{
                                              @"provider": providerId,
                                              @"firstName": [nameArray objectAtIndex:0],
                                              @"lastName" : [nameArray objectAtIndex:1],
                                              @"profileImage": photoUrl,
                                              @"email": email,
                                              @"searchRadius" : @"8.046720",
                                              @"useCustomProfileImage" : @"0"
                                              };
                    
                    
                            [[[self.userData.ref child:@"users"]
                              child:user.uid] updateChildValues:newUser];
                            [self.userData updateUserStatus];
                        }
                        else
                             [self.userData updateUserStatus];
                        
                    }];
                }
            }

            }
        }];
    }
}
// Implement the required GIDSignInDelegate methods
// Unauth when disconnected from Google
- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    [[FIRAuth auth] signOut:nil];
}
*/
-(void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    if (error) {
        NSLog(@"Facebook login failed. Error: %@", error);
    } else if (result.isCancelled) {
        NSLog(@"Facebook login got cancelled.");
    } else {
        self.spinnerView.hidden = NO;
        FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                         credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                         .tokenString];
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
          
                        if (error) {
                            NSLog(@"Login failed. %@", error);
                        } else {
                            NSLog(@"Logged in! %@", user);
                            
                            //Start Logging In Spinner
                            
                            
                            if (user) {
                                id<FIRUserInfo> profile;
                                NSString *providerId;
                                NSString *uid;
                                NSString *name;
                                NSString *email;
                                NSString *photoUrl;
                                if (user != nil) {
                                    profile = user.providerData.firstObject;
                                    
                                    providerId = profile.providerID;
                                    uid = profile.uid;  // Provider-specific UID
                                    name = profile.displayName;
                                    email = profile.email;
                                    photoUrl = [profile.photoURL absoluteString];
                                    
                                    
                                } else {
                                    // No user is signed in.
                                }
                                // save the user's profile into the database so we can list users,
                                // use them in Security and Firebase Rules, and show profiles
                                NSArray *nameArray = [name componentsSeparatedByString:@" "];
                                [[self.userData.ref child:[NSString stringWithFormat:@"users/%@", user.uid]]  observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                                    
                                    if(!snapshot.hasChildren)
                                    {
                                        NSMutableDictionary *newUser = [[NSMutableDictionary alloc]init];
                                        
                                        if(providerId)
                                           [newUser setObject:providerId forKey:@"provider"];
                                        if([nameArray objectAtIndex:0])
                                            [newUser setObject:[nameArray objectAtIndex:0] forKey:@"firstName"];
                                        if([nameArray objectAtIndex:1])
                                            [newUser setObject:[nameArray objectAtIndex:1] forKey:@"lastName"];
                                        if(photoUrl)
                                            [newUser setObject:photoUrl forKey:@"profileImage"];
                                        if(email)
                                            [newUser setObject:email forKey:@"email"];
                                        [newUser setObject:@"8.046720" forKey:@"searchRadius"];
                                        
                                        [newUser setObject:@"0" forKey:@"useCustomProfileImage"];
                                        
                                        [[[self.userData.ref child:@"users"]
                                          child:user.uid] updateChildValues:newUser withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                                            [FIRAnalytics logEventWithName:@"Facebook_Sign_Up_Used" parameters:nil];
                                        }];
                                        [self.userData updateUserStatus];
                                        
                                        
                                    }
                                    else
                                    {
                                        [FIRAnalytics logEventWithName:@"Facebook_Login_Used" parameters:nil];
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
                            
                            
                        }
                    }];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"emailSignUpSegue"])
    {
        EmailSignUpViewController *esuvc = segue.destinationViewController;
        
        esuvc.userData = self.userData;
        esuvc.isLogin = self.isLogin;
        
        self.isLogin = NO;
        
        
    }
}


@end
