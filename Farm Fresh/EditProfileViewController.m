//
//  EditProfileViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/20/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "EditProfileViewController.h"
#import "FarmEditViewController.h"
#import "Constants.h"
#import "HelperMethods.h"
#import "UIView+AddOns.h"
#import "ChangeEmailViewController.h"
#import "ChangePasswordViewController.h"
#import "NotificationSettingsViewController.h"
#import "AdminTableViewController.h"
#import "EditProfileImageViewController.h"
#import "ImageModel.h"
#import "UIImage+Resize.h"

@interface EditProfileViewController () <UITextFieldDelegate, UserModelDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *imageUpdatedLabel;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (weak, nonatomic) IBOutlet UIView *farmProfileView;
@property (weak, nonatomic) IBOutlet UIView *noFarmProfileView;
@property (weak, nonatomic) IBOutlet UIView *noPasswordView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *farmProfileTopContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noFarmProfileTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *saveChangesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UIImageView *menuImageView;
@property (nonatomic, strong) NSString *originalFirstName;
@property (nonatomic, strong) NSString *originalLastName;
@property (weak, nonatomic) IBOutlet UIButton *adminButton;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewTopConstraint;
@property (nonatomic) int navCounter;


@end

@implementation EditProfileViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.firstNameTextfield.delegate = self;
    self.lastNameTextfield.delegate = self;
    self.userData.delegate = self;
    
    self.imagePicker = [[UIImagePickerController alloc]init];
    
    if(self.userData.isAdmin)
        self.adminButton.hidden = NO;
    
    if(self.userData.lastName.length > 0)
        self.originalLastName = self.userData.lastName;
    else
        self.originalLastName = @"";
    
    if(self.userData.firstName.length > 0)
        self.originalFirstName = self.userData.firstName;
    else
        self.originalFirstName= @"";
    
    self.firstNameTextfield.text = self.originalFirstName;
    self.lastNameTextfield.text = self.originalLastName;
    self.
    
    
    self.profileImageView.layer.cornerRadius = 30.0f;
    self.profileImageView.layer.masksToBounds = YES;
    
    [self.menuImageView setImage:self.menuImage];
    self.mainViewTopConstraint.constant = self.view.frame.size.height;
    
    [self.view layoutIfNeeded];
    
    if(self.userData.isFarmer)
    {
        self.farmProfileView.hidden = false;
        
        if(self.userData.provider != PASSWORD)
        {
            self.noPasswordView.hidden = NO;
            if(IS_IPHONE_4_OR_LESS || IS_IPHONE_5)
                self.farmProfileTopContraint.constant = -55;
            else
                self.farmProfileTopContraint.constant = -65;
            [self.view layoutIfNeeded];
        }
        
        
    }
    else
    {
        self.noFarmProfileView.hidden = false;
        
        if(self.userData.provider != PASSWORD)
        {
            self.noPasswordView.hidden = NO;
            if(IS_IPHONE_4_OR_LESS || IS_IPHONE_5)
                self.noFarmProfileTopConstraint.constant = -55;
            else
                self.noFarmProfileTopConstraint.constant = -65;
            [self.view layoutIfNeeded];
        }
        
        
    }
    

    
    [self.view addGestureRecognizer:[UIView setupTapGestureWithTarget:self Action:@selector(hideKeyboard) cancelsTouchesInview:NO setDelegate:YES]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     [FIRAnalytics logEventWithName:@"Edit_Profile_Screen_Loaded" parameters:nil];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloadComplete) name:HelperMethodsImageDownloadCompleted object:nil];
    
    self.mainViewTopConstraint.constant = 0;
    
    [UIView animateWithDuration:0.4f animations:^{
        
        [self.view layoutIfNeeded];
    }];
    
     [self updateImage];
}

#pragma mark - IBActions
- (IBAction)logOutButtonPressed {
    
    [HelperMethods removeUserProfileImage];
    [self.userData userSignedOut];
    
    [self exitButtonPressed];
}

- (IBAction)exitButtonPressed {
    
    self.mainViewTopConstraint.constant = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (IBAction)editPictureButtonPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Edit Profile Picture"
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    NSString *providerString = @"Error";
    if(self.userData.provider == FACEBOOK)
    {
       providerString = @"Use Facebook Profile Image";
    }
    else if(self.userData.provider == GOOGLE)
    {
        providerString = @"Use Google Profile Image";
    }
        
    
    UIAlertAction *useProviderPic = [UIAlertAction
                                  actionWithTitle:providerString
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      sender.enabled = YES;
                                      [self.userData updateUseCustomProfileImage:NO];
                                      
                                      [HelperMethods downloadSingleImageFromBaseURL:self.userData.imageURL withFilename:@"profile.png" saveToDisk:YES replaceExistingImage:YES];
                                  }];
    
    UIAlertAction *cameraPic = [UIAlertAction
                                   actionWithTitle:@"Take Photo"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                       self.imagePicker.allowsEditing = YES;
                                       
                                       self.navCounter = 0;
                                       
                                       self.imagePicker.delegate = self;
                                       
                                      self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                       self.imagePicker.modalPresentationStyle = UIModalPresentationPopover;
                                       [self presentViewController:self.imagePicker animated:YES completion:nil];
                                       sender.enabled = YES;
                                   }];
    UIAlertAction *cameraRollPic = [UIAlertAction
                                actionWithTitle:@"Photo Library"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action)
                                {
                                    
                                    self.imagePicker.allowsEditing = YES;
                                    
                                    self.navCounter = 0;
                                    
                                    self.imagePicker.delegate = self;
                                    
                                    self.imagePicker.sourceType =
                                    UIImagePickerControllerSourceTypePhotoLibrary;
                                    self.imagePicker.modalPresentationStyle = UIModalPresentationPopover;
                                    [self presentViewController:self.imagePicker animated:YES completion:nil];
                                    sender.enabled = YES;
                                }];
    
    UIAlertAction *cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       sender.enabled = YES;
                                   }];
    
    if(self.userData.provider != PASSWORD)
        [alertController addAction: useProviderPic];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        [alertController addAction:cameraRollPic];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [alertController addAction:cameraPic];
    
    [alertController addAction:cancelButton];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (IBAction)notificationButtonPressed {
    
    [self performSegueWithIdentifier:@"changeNotifcationsSegue" sender:self];
}

#pragma mark - Methods

- (void)imageDownloadComplete
{
    [self updateImage];
    [self imageUpdated];
}

- (void)imageUpdated
{
    [UIView animateWithDuration:1.0 animations:^{
        self.imageUpdatedLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imageUpdatedLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

-(void)hideKeyboard
{
    
    [self.firstNameTextfield resignFirstResponder];
    [self.lastNameTextfield resignFirstResponder];
    
}

- (void)updateImage
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/profile.png",docDir];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
        [self.profileImageView setImage:image];
    }
    else
    {
        [HelperMethods downloadSingleImageFromBaseURL:self.userData.imageURL withFilename:@"profile.png" saveToDisk:YES replaceExistingImage:NO];
    }
    
}

- (void)nameUpdated:(int) nameType
{
    if(nameType == 1)
    {
        self.originalFirstName = self.userData.firstName;
        self.saveChangesLabel.text = @"First name updated";
    }
    else if(nameType == 2)
    {
        self.originalLastName = self.userData.lastName;
        self.saveChangesLabel.text = @"Last name updated";
    }
    
    
    [UIView animateWithDuration:1.0 animations:^{
        self.saveChangesLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.saveChangesLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)saveFirstNameToFirebase:(NSString *)string
{
    if(![self.originalFirstName isEqualToString:string])
        [self.userData updateFirstName:string];
}

- (void)saveLastNameToFirebase:(NSString *)string
{
    if(![self.originalLastName isEqualToString:string])
        [self.userData updateLastName:string];
}

#pragma mark - Delegate Methods

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:  (UIViewController *)viewController animated:(BOOL)animated{
    /*
    self.navCounter++;
    if (self.navCounter == 3 || (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera && self.navCounter == 1))
    {
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        
        UIView *plCropOverlay = [[[viewController.view.subviews objectAtIndex:1]subviews] objectAtIndex:0];
        
        plCropOverlay.hidden = YES;
        
        int position = 0;
        
        if (screenHeight == 568)
        {
            position = 124;
        }
        else
        {
            position = 80;
        }
        
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        
        UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:
                               CGRectMake(screenWidth/2 - 100, screenHeight/2 - 100, 200.0f, 200.0f)];
        [path2 setUsesEvenOddFillRule:YES];
        
        [circleLayer setPath:[path2 CGPath]];
        
        [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, screenWidth, screenHeight-72) cornerRadius:0];
        
        [path appendPath:path2];
        [path setUsesEvenOddFillRule:YES];
        
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.path = path.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = [UIColor blackColor].CGColor;
        fillLayer.opacity = 0.8;
        [viewController.view.layer addSublayer:fillLayer];
     
     
        
    }*/
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *imagePicked = [UIImage cropImageWithInfo:info];
    
    UIImage *newImage = [UIImage imageWithImage:imagePicked
                                   scaledToSize:CGSizeMake(60, 60)];
    
    self.profileImageView.image = newImage;
    [self imageUpdated];
    
    [self.userData updateUseCustomProfileImage:YES];
    
    
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath;
    
    
        filePath= [[paths objectAtIndex:0] stringByAppendingPathComponent:@"profile.png"];
    
    NSData *imageData = UIImagePNGRepresentation(newImage);
    // Save image.
    [imageData writeToFile:filePath atomically:YES];
    
    
        [ImageModel saveUserProfileImage:imageData forUser:self.userData];
    
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 1 && textField.text.length > 0)
        [self saveFirstNameToFirebase:textField.text];
    else if (textField.tag == 2 && textField.text.length > 0)
        [self saveLastNameToFirebase:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text.length > 0)
    {
        if(textField.tag == 1)
            [self saveFirstNameToFirebase:textField.text];
        else if (textField.tag == 2)
            [self saveLastNameToFirebase:textField.text];
    }
    
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"editFarmSegue"])
    {
        FarmEditViewController *fevc = segue.destinationViewController;
        
        fevc.userData = self.userData;
        fevc.menuImage = self.menuImage;
    }
    else if([segue.identifier isEqualToString:@"changeEmailSegue"])
    {
        ChangeEmailViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }
    else if([segue.identifier isEqualToString:@"changePasswordSegue"])
    {
        ChangePasswordViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }
    else if([segue.identifier isEqualToString:@"changeNotifcationsSegue"])
    {
        NotificationSettingsViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }
    else if([segue.identifier isEqualToString:@"adminSegue"])
    {
        AdminTableViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }
    /*else if([segue.identifier isEqualToString:@"editProfileImageSegue"])
    {
        EditProfileImageViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
        vc.mode = editMainProfileImageMode;
    }*/
}


@end
