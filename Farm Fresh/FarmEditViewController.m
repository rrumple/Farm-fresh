//
//  FarmEditViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/17/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "FarmEditViewController.h"
#import "FarmLocationsViewController.h"
#import "MainMenuViewController.h"
#import "PostProductViewController.h"
#import "EditDescriptionViewController.h"
#import "UIView+AddOns.h"
#import "EditScheduleViewController.h"
#import "SetContactInfoViewController.h"
#import "EditProfileImageViewController.h"
#import "HelperMethods.h"
#import "ImageModel.h"
#import "UIImage+Resize.h"

@interface FarmEditViewController () <UITextFieldDelegate, UserModelDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *imageUpdatedLabel;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UITextField *farmNameTextfield;

@property (weak, nonatomic) IBOutlet UIImageView *farmProfileImage;

@property (weak, nonatomic) IBOutlet UIImageView *farmDescriptionCheck;
@property (weak, nonatomic) IBOutlet UIImageView *sellingLocationsCheck;
@property (weak, nonatomic) IBOutlet UIImageView *scheduleCheck;
@property (weak, nonatomic) IBOutlet UIImageView *contactCheck;
@property (weak, nonatomic) IBOutlet UIImageView *farmNameError;
@property (weak, nonatomic) IBOutlet UIImageView *farmDescriptionError;
@property (weak, nonatomic) IBOutlet UIImageView *farmLocationsError;
@property (weak, nonatomic) IBOutlet UIImageView *farmSchduleError;
@property (weak, nonatomic) IBOutlet UIImageView *farmContactError;
@property (weak, nonatomic) IBOutlet UILabel *saveChangesLabel;

@property (weak, nonatomic) IBOutlet UIImageView *farmerSetupTitle;
@property (weak, nonatomic) IBOutlet UIButton *sellProductButton;
@property (nonatomic) BOOL hasDescription;
@property (weak, nonatomic) IBOutlet UIImageView *editFarmTitle;
@property (nonatomic) BOOL hasLocations;
@property (nonatomic) BOOL hasSchedule;
@property (nonatomic) BOOL hasContact;
@property (nonatomic, strong) NSString *originalText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewTopLayout;
@property (weak, nonatomic) IBOutlet UIImageView *menuImageView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewTopConstraint;
@property (nonatomic) int navCounter;
@end

@implementation FarmEditViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagePicker = [[UIImagePickerController alloc]init];
    
     [self.menuImageView setImage:self.menuImage];
    
    if(self.isFirstTimeSetup)
    {
        self.farmerSetupTitle.hidden = NO;
        self.editFarmTitle.hidden = YES;
    }
    else
    {
        self.farmerSetupTitle.hidden = YES;
        self.editFarmTitle.hidden = NO;
        self.mainViewTopLayout.constant = 64;
        
        [self.view layoutIfNeeded];
    }
        //self.sellAProductView.hidden = NO;
    
    self.farmProfileImage.layer.cornerRadius = 30.0f;
    self.farmProfileImage.layer.masksToBounds = YES;
    
    self.farmNameTextfield.delegate = self;
    self.userData.delegate = self;
    
  
    
    /*
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    // Construct the NSURL for the download location.
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"downloaded-myImage.jpg"];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    
    // Construct the download request.
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    
    downloadRequest.bucket = @"farmfresh";
    downloadRequest.key = @"testImage.jpg";
    downloadRequest.downloadingFileURL = downloadingFileURL;
    
    // Download the file.
    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
       if (task.error){
           if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
               switch (task.error.code) {
                   case AWSS3TransferManagerErrorCancelled:
                   case AWSS3TransferManagerErrorPaused:
                       break;
                       
                   default:
                       NSLog(@"Error: %@", task.error);
                       break;
               }
           } else {
               // Unknown error.
               NSLog(@"Error: %@", task.error);
           }
       }
       
       if (task.result) {
           AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
           NSLog(@"%@", downloadOutput);
           self.farmProfileImage.image = [UIImage imageWithContentsOfFile:downloadingFilePath];
       }
       return nil;
    }];

    */
    
    if(self.userData.farmName.length > 0)
    {
        self.farmNameTextfield.text= self.userData.farmName;
        self.originalText = self.userData.farmName;
        
    }
    else
    {
        self.farmNameError.hidden = NO;
        self.originalText = @"";
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
    [self.userData updateMySchedule];

     [FIRAnalytics logEventWithName:@"Farm_Edit_Screen_Loaded" parameters:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloadComplete) name:HelperMethodsImageDownloadCompleted object:nil];
    
    [self updateImage];
    
    if(self.userData.farmDescription.length > 0)
    {
        //self.farmDescriptionCheck.image = [UIImage imageNamed:@"checkMark"];
        //self.farmDescriptionCheck.hidden = false;
        self.farmDescriptionError.hidden = true;
        self.hasDescription = YES;
    }
    else
    {
        self.hasDescription = NO;
        self.farmDescriptionCheck.hidden = true;
        self.farmDescriptionError.hidden = false;
    }
    
    if(self.userData.farmLocations.count > 0)
    {
        //self.sellingLocationsCheck.image = [UIImage imageNamed:@"checkMark"];
        //self.sellingLocationsCheck.hidden = false;
        self.farmLocationsError.hidden = true;
        self.hasLocations = YES;
    }
    else
    {
        self.hasLocations = NO;
        //self.sellingLocationsCheck.hidden = true;
        self.farmLocationsError.hidden = false;
    }
    
    //check for Schedule
    if(self.userData.mySchedule)
    {
        //self.scheduleCheck.image = [UIImage imageNamed:@"checkMark"];
        //self.scheduleCheck.hidden = false;
        self.farmSchduleError.hidden = true;
        self.hasSchedule = YES;
    }
    else
    {
        //self.scheduleCheck.hidden = true;
        self.farmSchduleError.hidden = false;
        self.hasSchedule = NO;
    }
    
    //check For Contact
    if(self.userData.useChat || self.userData.useEmail || self.userData.useTelephone)
    {
        //self.contactCheck.image = [UIImage imageNamed:@"checkMark"];
        //self.contactCheck.hidden = false;
        self.farmContactError.hidden = true;
        self.hasContact = YES;
    }
    else
    {
        //self.contactCheck.hidden = true;
        self.farmContactError.hidden = false;
        self.hasContact = NO;
    }
    
    [self checkToEnableSellButton];
}

#pragma mark - IBActions
- (IBAction)editProfileImageButtonPressed:(UIButton *)sender {
    
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
                                         [HelperMethods downloadSingleImageFromBaseURL:self.userData.imageURL withFilename:@"farmProfile.png" saveToDisk:YES replaceExistingImage:YES];
                                         sender.enabled = YES;
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

- (IBAction)exitButtonPressed {
    
    if(!self.isFirstTimeSetup)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        self.mainViewTopConstraint.constant = self.view.frame.size.height;
        
        [UIView animateWithDuration:0.4f animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
            if(self.isFirstTimeSetup)
            {
                NSArray *viewControllers = self.navigationController.viewControllers;
                
                for(int i = 0; i < viewControllers.count;i++)
                {
                    id obj = [viewControllers objectAtIndex:i];
                    if([obj isKindOfClass:[MainMenuViewController class]])
                    {
                        [self.navigationController popToViewController:obj animated:NO];
                    }
                }
            }
            else
                [self.navigationController popViewControllerAnimated:NO];
        }];
    }

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

- (void)updateImage
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/farmProfile.png",docDir];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
        [self.farmProfileImage setImage:image];
        
    }
    else
    {
       
        [HelperMethods downloadFarmProfileImageFromFirebase:self.userData];
       
    }
    
}

-(void)checkToEnableSellButton
{
    if(self.farmNameTextfield.text.length > 0 && self.hasSchedule && self.hasDescription && self.hasLocations && self.hasContact)
    {
        self.sellProductButton.enabled = YES;
    }
    else
    {
        self.sellProductButton.enabled = NO;
    }
}

-(void)hideKeyboard
{
    
    [self.farmNameTextfield resignFirstResponder];
    
}

- (void)farmerProfileUpdated
{
    self.originalText = self.userData.farmName;
    if(self.farmNameTextfield.text.length == 0)
        self.farmNameError.hidden = false;
    else
        self.farmNameError.hidden = true;
    
    [self checkToEnableSellButton];
    [UIView animateWithDuration:1.0 animations:^{
        self.saveChangesLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.saveChangesLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)saveFarmNameToFirebase:(NSString *)string
{
    if(![self.originalText isEqualToString:string])
        [self.userData updateFarmName:string];
}

#pragma mark - Delegate Methods

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:  (UIViewController *)viewController animated:(BOOL)animated{
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
        
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *imagePicked = [UIImage cropImageWithInfo:info];
    
    UIImage *newImage = [UIImage imageWithImage:imagePicked
                                   scaledToSize:CGSizeMake(60, 60)];
    
    self.farmProfileImage.image = newImage;
    [self imageUpdated];
    
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath;
    
    
    filePath= [[paths objectAtIndex:0] stringByAppendingPathComponent:@"farmProfile.png"];
   
    
    NSData *imageData = UIImagePNGRepresentation(newImage);
    // Save image.
    [imageData writeToFile:filePath atomically:YES];
    
   
    [ImageModel saveFarmProfileImage:imageData forUser:self.userData];
   
    
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)updateMyScheduleComplete
{
    //check for Schedule
    if(self.userData.mySchedule)
    {
        //self.scheduleCheck.image = [UIImage imageNamed:@"checkMark"];
        //self.scheduleCheck.hidden = false;
        self.farmSchduleError.hidden = true;
        self.hasSchedule = YES;
    }
    else
    {
        //self.scheduleCheck.hidden = true;
        self.farmSchduleError.hidden = false;
        self.hasSchedule = NO;
    }
}

#pragma mark TextView Delegate

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.text.length > 0)
        [self saveFarmNameToFirebase:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text.length > 0)
        [self saveFarmNameToFirebase:textField.text];
    
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:@"editScheduleSegue"] && self.userData.farmLocations.count == 0)
    {
        [self presentViewController: [UIView createSimpleAlertWithMessage:@"You need to add at least one selling location to be able to set the schedule."andTitle:@"Error" withOkButton:YES] animated: YES completion: nil];
        
        return NO;
        
        
    }
    else
        return YES;
    
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"editSellingLocationsSegue"])
    {
        FarmLocationsViewController *flvc = segue.destinationViewController;
        
        flvc.userData = self.userData;
    }
    else if([segue.identifier isEqualToString:@"signUpPostProductSegue"])
    {
        PostProductViewController *ppvc = segue.destinationViewController;
        
        ppvc.userData = self.userData;
        ppvc.isFirstTimeSetup = YES;
        ppvc.menuImage = self.menuImage;
    }
    else if([segue.identifier isEqualToString:@"descriptionEditSegue"])
    {
        EditDescriptionViewController *edvc = segue.destinationViewController;
        
        edvc.userData = self.userData;
    }
    else if([segue.identifier isEqualToString:@"editScheduleSegue"])
    {
        
    
            EditScheduleViewController *vc = segue.destinationViewController;
            
            vc.userData = self.userData;
        
    }
    else if([segue.identifier isEqualToString:@"editContactInfoSegue"])
    {
        SetContactInfoViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }
    /*else if([segue.identifier isEqualToString:@"editFarmProfileImageSegue"])
    {
        EditProfileImageViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
        vc.mode = editFarmProfileImageMode;
    }*/
}

@end
