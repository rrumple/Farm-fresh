//
//  PostProductViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/23/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "PostProductViewController.h"
#import "HelperMethods.h"
#import "CustomPicker.h"
#import "Constants.h"
#import "UIView+AddOns.h"
#import "FarmLocationsViewController.h"
#import "MainMenuViewController.h"
#import "UIImage+Resize.h"
#import "ImageModel.h"
#import <Social/Social.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface PostProductViewController () <UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UserModelDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageModelDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *menuImageView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewTopConstraint;

@property (weak, nonatomic) IBOutlet UITextField *productHeadlineTextfield;
@property (weak, nonatomic) IBOutlet UITextView *productDescriptionTextview;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextfield;
@property (weak, nonatomic) IBOutlet UITextField *amountTextfield;
@property (weak, nonatomic) IBOutlet UITextField *amountDescriptionTextfield;
@property (weak, nonatomic) IBOutlet UISwitch *shareOnFacebookSwitch;
@property (weak, nonatomic) IBOutlet UIButton *listProductButton;

@property (weak, nonatomic) IBOutlet UIView *bigImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bigImageImageView;
@property (weak, nonatomic) IBOutlet UIButton *productImage1;
@property (weak, nonatomic) IBOutlet UIButton *productImage2;
@property (weak, nonatomic) IBOutlet UIButton *productImage3;
@property (weak, nonatomic) IBOutlet UIButton *productImage4;
@property (weak, nonatomic) IBOutlet UILabel *editProductLabel;
@property (weak, nonatomic) IBOutlet UIImageView *productPostImageView;

@property (nonatomic, strong) NSDate *expireDate;

@property (weak, nonatomic) IBOutlet UIView *spinnerView;
@property (weak, nonatomic) IBOutlet UILabel *spinnerViewLabel;

@property (nonatomic) CGFloat animatedDistance;

@property (nonatomic) NSInteger categorySelected;

@property (nonatomic, strong) NSDictionary *productData;

@property (nonatomic) NSInteger currentImage;

@property (nonatomic) BOOL image1Set;
@property (nonatomic) BOOL image2Set;
@property (nonatomic) BOOL image3Set;
@property (nonatomic) BOOL image4Set;

@property (nonatomic) BOOL image1Changed;
@property (nonatomic) BOOL image2Changed;
@property (nonatomic) BOOL image3Changed;
@property (nonatomic) BOOL image4Changed;

@property (nonatomic, strong) UIImage *image1;
@property (nonatomic, strong) UIImage *image2;
@property (nonatomic, strong) UIImage *image3;
@property (nonatomic, strong) UIImage *image4;

@property (nonatomic) int imageCount;

@property (weak, nonatomic) IBOutlet UIButton *deleteImageButton;

@property (weak, nonatomic) IBOutlet UIImageView *editModeImageView;
@property (weak, nonatomic) IBOutlet UILabel *shareOnFacebookLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shareOnFacebookLine;

@property (nonatomic) BOOL firebaseComplete;
@property (nonatomic) BOOL imagesComplete;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;


@end

@implementation PostProductViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.image1Set = NO;
    self.image2Set = NO;
    self.image3Set = NO;
    self.image4Set = NO;
    self.imageCount = 0;
    self.firebaseComplete = NO;
    self.imagesComplete = NO;
    
    if(IS_IPHONE_6P)
    {
        self.leadingConstraint.constant = 29.5;
        self.trailingConstraint.constant = 29.5;
        [self.view layoutIfNeeded];
    }
    
    if(self.isInEditMode)
    {
        [self setupEditMode];
    }
    
    self.imagePicker = [[UIImagePickerController alloc]init];
   
    
    self.productImage1.layer.cornerRadius = 4.0f;
    self.productImage1.layer.masksToBounds = YES;
    self.productImage2.layer.cornerRadius = 4.0f;
    self.productImage2.layer.masksToBounds = YES;
    self.productImage3.layer.cornerRadius = 4.0f;
    self.productImage3.layer.masksToBounds = YES;
    self.productImage4.layer.cornerRadius = 4.0f;
    self.productImage4.layer.masksToBounds = YES;
    
    [self.menuImageView setImage:self.menuImage];
    self.userData.delegate = self;
    
    if(!self.isFirstTimeSetup && !self.isInEditMode)
    {
        self.mainViewTopConstraint.constant = self.view.frame.size.height;
        
        [self.view layoutIfNeeded];
    }
    
    self.productHeadlineTextfield.delegate = self;
    self.productDescriptionTextview.delegate = self;
    self.categoryTextfield.delegate = self;
    self.amountTextfield.delegate = self;
    self.amountDescriptionTextfield.delegate = self;
    
    self.categoryTextfield.inputView = [CustomPicker createPickerWithTag:zPickerCategories withDelegate:self andDataSource:self target:self action:@selector(hideKeyboard) andWidth:self.view.frame.size.width];
    self.categoryTextfield.inputAccessoryView = [CustomPicker createAccessoryViewWithTitle:@"Done" target:self action:@selector(pickerViewDone)];
    
    self.amountTextfield.inputAccessoryView = [CustomPicker createAccessoryViewWithTitle:@"Done" target:self action:@selector(amountTextFieldDone)];
    
    [self.userData updateCategories];
    
    [self.view addGestureRecognizer:[UIView setupTapGestureWithTarget:self Action:@selector(hideKeyboard) cancelsTouchesInview:NO setDelegate:YES]];


    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Post_Product_Screen_Loaded" parameters:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!self.isFirstTimeSetup && !self.isInEditMode)
    {
        self.mainViewTopConstraint.constant = 0;
        
        [UIView animateWithDuration:0.4f animations:^{
            
            [self.view layoutIfNeeded];
        }];
    }
    
}


#pragma mark - IBActions
- (IBAction)bigImageViewCloseButtonPressed {
    
    self.bigImageView.hidden = TRUE;
    
}

- (IBAction)deleteImageButtonPressed:(UIButton *)sender {
    
    switch (sender.tag) {
        case 1:
            self.image1Changed = YES;
            self.image1 = nil;
            [self.productImage1 setImage:[UIImage imageNamed:@"pictureSelected"] forState:UIControlStateNormal];
            self.image1Set = NO;
            if(!self.image2Set)
                self.productImage2.enabled = NO;
            
            break;
        case 2:
            self.image2Changed = YES;
            self.image2 = nil;
            [self.productImage2 setImage:[UIImage imageNamed:@"pictureSelected"] forState:UIControlStateNormal];
            self.image2Set = NO;
            if(!self.image3Set)
                self.productImage3.enabled = NO;
            break;
        case 3:
            self.image3Changed = YES;
            self.image3 = nil;
            [self.productImage3 setImage:[UIImage imageNamed:@"pictureSelected"] forState:UIControlStateNormal];
            self.image3Set = NO;
            if(!self.image4Set)
                self.productImage4.enabled = NO;
            break;
        case 4:
            self.image4Changed = YES;
            self.image4 = nil;
            [self.productImage4 setImage:[UIImage imageNamed:@"pictureSelected"] forState:UIControlStateNormal];
            self.image4Set = NO;
            break;
            
        default:
            break;
    }
    self.bigImageView.hidden = true;
    
    [self checkAndMoveOverImagesIfNeeded];
    
}


- (IBAction)imageButtonPressed:(UIButton *)sender {
    
    BOOL isImageSet;
    switch (sender.tag) {
        case 1:
            isImageSet = self.image1Set;
            break;
        case 2:
            isImageSet = self.image2Set;
            break;
        case 3:
            isImageSet = self.image3Set;
            break;
        case 4:
            isImageSet = self.image4Set;
            break;
            
        default:
            break;
    }
    
    if(!isImageSet)
    {
    
        self.imagePicker.allowsEditing = YES;
        self.currentImage = sender.tag;
        
        self.imagePicker.delegate = self;
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Select Picture Source"
                                              message:@""
                                              preferredStyle:UIAlertControllerStyleActionSheet];
        
        
        UIAlertAction *pictureRoll = [UIAlertAction
                                      actionWithTitle:@"Picture Roll"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action)
                                      {
                                          self.imagePicker.sourceType =
                                          UIImagePickerControllerSourceTypePhotoLibrary;
                                          self.imagePicker.modalPresentationStyle = UIModalPresentationPopover;
                                          [self presentViewController:self.imagePicker animated:YES completion:nil];
                                          
                                        
                                      }];
        
        UIAlertAction *camera = [UIAlertAction
                                       actionWithTitle:@"Camera"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                           self.imagePicker.modalPresentationStyle = UIModalPresentationPopover;
                                           [self presentViewController:self.imagePicker animated:YES completion:nil];
                                       }];
        
        UIAlertAction *cancelButton = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           self.userData.delegate = self;
                                       }];
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            [alertController addAction: pictureRoll];
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            [alertController addAction:camera];
        
        [alertController addAction:cancelButton];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else
    {
        BOOL doHide = NO;
        if(self.deleteImageButton.tag == sender.tag)
           doHide = YES;
            
        if(self.bigImageView.hidden == YES || self.deleteImageButton.tag != sender.tag)
        {
            self.deleteImageButton.tag = sender.tag;
            switch (sender.tag) {
                case 1:
                    self.bigImageImageView.image = self.image1;
                    break;
                case 2:
                    self.bigImageImageView.image = self.image2;
                    break;
                case 3:
                    self.bigImageImageView.image = self.image3;
                    break;
                case 4:
                    self.bigImageImageView.image = self.image4;
                    break;
                    
                default:
                    break;
            }
            self.bigImageView.hidden = NO;
        }
        else
        {
            if(doHide)
                self.bigImageView.hidden = YES;
        }
        
        
        
    }

    
}

- (IBAction)exitButtonPressed {
    
    
    if(self.isInEditMode)
       [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)listProductButtonPressed:(UIButton *)sender {
    
    [self hideKeyboard];
    sender.enabled = false;
    NSString *productID;
    
    if(self.isInEditMode)
    {
        self.spinnerViewLabel.text = @"Updating...";
        
        productID = self.productToEdit[@"productID"];
        
        self.productData = @{
                             @"productHeadline" : self.productHeadlineTextfield.text,
                             @"productDescription" : self.productDescriptionTextview.text,
                             //@"category" : self.categoryTextfield.text,
                             @"amount" : [self.amountTextfield.text substringFromIndex:1],
                             @"amountDescription" : self.amountDescriptionTextfield.text
                             };
        [self.userData updateProduct:self.productToEdit[@"productID"] withData:self.productData];
    }
    else
    {
        if(self.productHeadlineTextfield.text.length > 0)
        {
            if(self.productDescriptionTextview.text.length > 0)
            {
                if(self.amountTextfield.text.length > 1)
                {
                    if(self.amountDescriptionTextfield.text.length > 0)
                    {
                        self.spinnerViewLabel.text = @"Adding Product...";
                        NSDate *now = [NSDate date];
                        
                        
                        int daysToAdd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"productExpireDays"]intValue];
                        self.expireDate = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
                        
                        self.productData = @{
                                             @"productHeadline" : self.productHeadlineTextfield.text,
                                             @"productDescription" : self.productDescriptionTextview.text,
                                             //@"category" : self.categoryTextfield.text,
                                             @"amount" : [self.amountTextfield.text substringFromIndex:1],
                                             @"amountDescription" : self.amountDescriptionTextfield.text,
                                             @"farmerID" : self.userData.user.uid,
                                             @"isActive" : @"1",
                                             @"datePosted" : [NSString stringWithFormat:@"%@", now],
                                             @"expireDate" : [NSString stringWithFormat:@"%@", self.expireDate]
                                             
                                             };
                        
                        productID = [self.userData addProductToFarm:self.productData];
                        
                        if(self.shareOnFacebookSwitch.isOn)
                            [self postFacebookMessage:productID];
                    }
                    else
                    {
                        sender.enabled = true;
                        [self presentViewController: [UIView createSimpleAlertWithMessage:@"Amount description is blank, please list how this item is sold ex.(each, per Lb., etc..)"andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
                    }
                }
                else
                {
                    sender.enabled = true;
                    [self presentViewController: [UIView createSimpleAlertWithMessage:@"Product amount is blank."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
                }
            }
            else
            {
                sender.enabled = true;
                [self presentViewController: [UIView createSimpleAlertWithMessage:@"Product description is blank."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
            }
        }
        else
        {
            sender.enabled = true;
            [self presentViewController: [UIView createSimpleAlertWithMessage:@"Product title is blank."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
        }
      
        
        
    }
    self.spinnerView.hidden = NO;
    
    ImageModel *imageModel = [[ImageModel alloc]init];
    imageModel.delegate = self;
    
    if(self.image1Set || self.image1Changed)
        imageModel.imageCount++;
    if(self.image2Set || self.image2Changed)
        imageModel.imageCount++;
    if(self.image3Set || self.image3Changed)
        imageModel.imageCount++;
    if(self.image4Set || self.image4Changed)
        imageModel.imageCount++;
    
    for(int i = 1; i < 5; i++)
    {
        
        NSString *fileName = [NSString stringWithFormat:@"%@_%i.png",productID,i];
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir,fileName];
        
                switch (i) {
            case 1:
                if(self.image1Set)
                {
                    if(self.image1Changed)
                    {
                        if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
                        {
                            
                            [[NSFileManager defaultManager] removeItemAtPath:pngFilePath error:nil];
                            
                            
                        }

                        NSData *data = UIImagePNGRepresentation(self.image1);
                        
                        [imageModel saveproductImage:data forUser:self.userData.storageRef withName:[NSString stringWithFormat:@"%@_1", productID] forProduct:productID atIndex:1];
                    }
                    else
                        imageModel.imageCount--;
                }
                else
                {
                    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
                    {
                        
                        [[NSFileManager defaultManager] removeItemAtPath:pngFilePath error:nil];
                        
                        
                    }

                    
                    [imageModel deleteProductImage:[NSString stringWithFormat:@"%@_1", productID] forProductID:productID forUser:self.userData.storageRef];
                }
                break;
            case 2:
                if(self.image2Set)
                {
                    if(self.image2Changed)
                    {
                        if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
                        {
                            
                            [[NSFileManager defaultManager] removeItemAtPath:pngFilePath error:nil];
                            
                            
                        }

                        
                        NSData *data = UIImagePNGRepresentation(self.image2);
                        
                       [imageModel saveproductImage:data forUser:self.userData.storageRef withName:[NSString stringWithFormat:@"%@_2", productID] forProduct:productID atIndex:2];
                    }
                    else
                        imageModel.imageCount--;
                }
                else
                {
                    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
                    {
                        
                        [[NSFileManager defaultManager] removeItemAtPath:pngFilePath error:nil];
                        
                        
                    }

                    [imageModel deleteProductImage:[NSString stringWithFormat:@"%@_2", productID] forProductID:productID forUser:self.userData.storageRef];
                }
                break;
            case 3:
                if(self.image3Set)
                {
                    if(self.image3Changed)
                    {
                        if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
                        {
                            
                            [[NSFileManager defaultManager] removeItemAtPath:pngFilePath error:nil];
                            
                            
                        }

                        
                        NSData *data = UIImagePNGRepresentation(self.image3);
                        
                        [imageModel saveproductImage:data forUser:self.userData.storageRef withName:[NSString stringWithFormat:@"%@_3", productID] forProduct:productID atIndex:3];
                    }
                    else
                        imageModel.imageCount--;
                }
                else
                {
                    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
                    {
                        
                        [[NSFileManager defaultManager] removeItemAtPath:pngFilePath error:nil];
                        
                        
                    }

                    [imageModel deleteProductImage:[NSString stringWithFormat:@"%@_3", productID] forProductID:productID forUser:self.userData.storageRef];
                }
                break;
            case 4:
                if(self.image4Set)
                {
                    if(self.image4Changed)
                    {
                        if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
                        {
                            
                            [[NSFileManager defaultManager] removeItemAtPath:pngFilePath error:nil];
                            
                            
                        }

                        NSData *data = UIImagePNGRepresentation(self.image4);
                        
                       [imageModel saveproductImage:data forUser:self.userData.storageRef withName:[NSString stringWithFormat:@"%@_4", productID] forProduct:productID atIndex:4];
                    }
                    else
                        imageModel.imageCount--;
                }
                else
                {
                    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
                    {
                        
                        [[NSFileManager defaultManager] removeItemAtPath:pngFilePath error:nil];
                        
                        
                    }

                    [imageModel deleteProductImage:[NSString stringWithFormat:@"%@_4", productID] forProductID:productID forUser:self.userData.storageRef];
                }
                break;
                
        }
        
    }
    if(imageModel.imageCount == 0)
    {
        self.imagesComplete = YES;
        [self notifyUser];
    }

    
    
    
    
}

#pragma mark - Methods

- (void)checkAndMoveOverImagesIfNeeded
{
    
    //check for gap
    for(int i = 1; i < 5; i++)
    {
        switch (i) {
            case 1:
                if(!self.image1Set)
                {
                    for(int x = 2; x < 5; x++)
                    {
                        switch (x) {
                            case 2:
                                if(self.image2Set)
                                {
                                    self.image1Set = YES;
                                    self.image1 = self.image2;
                                    self.image2 = nil;
                                    self.image2Set = NO;
                                    [self.productImage1 setImage:self.productImage2.imageView.image forState:UIControlStateNormal];
                                    [self.productImage2 setImage:[UIImage imageNamed:@"pictureSelected"] forState:UIControlStateNormal];
                                    if(!self.image3Set)
                                        self.productImage3.enabled = NO;
                                    if(!self.image4Set)
                                        self.productImage4.enabled = NO;
                                    x = 5;
                                }
                                break;
                            case 3:
                                if(self.image3Set)
                                {
                                    self.image1Set = YES;
                                    self.image1 = self.image3;
                                    self.image3 = nil;
                                    self.image3Set = NO;
                                    [self.productImage1 setImage:self.productImage3.imageView.image forState:UIControlStateNormal];
                                    [self.productImage3 setImage:[UIImage imageNamed:@"pictureSelected"] forState:UIControlStateNormal];
                                    if(!self.image4Set)
                                        self.productImage4.enabled = NO;
                                    x = 5;
                                }
                                break;
                            case 4:
                                if(self.image4Set)
                                {
                                    self.image1Set = YES;
                                    self.image1 = self.image4;
                                    self.image4 = nil;
                                    self.image4Set = NO;
                                    [self.productImage1 setImage:self.productImage4.imageView.image forState:UIControlStateNormal];
                                    [self.productImage4 setImage:[UIImage imageNamed:@"pictureSelected"] forState:UIControlStateNormal];
                                    x = 5;
                                }
                                break;

                            
                        }
                    }
                }
                break;
            case 2:
                if(!self.image2Set)
                {
                    for(int x = 3; x < 5; x++)
                    {
                        switch (x) {
                            case 3:
                                if(self.image3Set)
                                {
                                    self.image2Set = YES;
                                    self.image2 = self.image3;
                                    self.image3 = nil;
                                    self.image3Set = NO;
                                    [self.productImage2 setImage:self.productImage3.imageView.image forState:UIControlStateNormal];
                                    [self.productImage3 setImage:[UIImage imageNamed:@"pictureSelected"] forState:UIControlStateNormal];
                                    if(!self.image4Set)
                                        self.productImage4.enabled = NO;
                                    x = 5;
                                }
                                break;
                            case 4:
                                if(self.image4Set)
                                {
                                    self.image2Set = YES;
                                    self.image2 = self.image4;
                                    self.image4 = nil;
                                    self.image4Set = NO;
                                    [self.productImage2 setImage:self.productImage4.imageView.image forState:UIControlStateNormal];
                                    [self.productImage4 setImage:[UIImage imageNamed:@"pictureSelected"] forState:UIControlStateNormal];
                                    x = 5;
                                }
                                break;
                                
                                
                        }
                    }
                }
                break;
            case 3:
                if(!self.image3Set)
                {
                    for(int x = 4; x < 5; x++)
                    {
                        switch (x) {
                            case 4:
                                if(self.image4Set)
                                {
                                    self.image3Set = YES;
                                    self.image3 = self.image4;
                                    self.image4 = nil;
                                    self.image4Set = NO;
                                    [self.productImage3 setImage:self.productImage4.imageView.image forState:UIControlStateNormal];
                                    [self.productImage4 setImage:[UIImage imageNamed:@"pictureSelected"] forState:UIControlStateNormal];
                                    x = 5;
                                }
                                break;
                                
                                
                        }
                    }
                }
                break;
            case 4:
                break;
            
        }
    }
}

- (void)notifyUser
{
    if(self.firebaseComplete && self.imagesComplete)
    {
        self.spinnerView.hidden = YES;
        NSString *title;
        NSString *message;
        if(self.isInEditMode)
        {
            title = @"Product Updated";
            message = @"Product updated Successfully.";
        }
        else
        {
            title = @"Product Posted";
            message = [NSString stringWithFormat:@"%@ posted successfully and will expire on %@", self.productHeadlineTextfield.text, [HelperMethods formatExpireDate: self.expireDate]];
        }
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:title
                                              message:message
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       if(self.isInEditMode)
                                           [self.navigationController popViewControllerAnimated:YES];
                                       else
                                       {
                                           NSArray *viewControllers = self.navigationController.viewControllers;
                                           
                                           for(int i = 0; i < viewControllers.count;i++)
                                           {
                                               id obj = [viewControllers objectAtIndex:i];
                                               if([obj isKindOfClass:[MainMenuViewController class]])
                                               {
                                                   [self.navigationController popToViewController:obj animated:YES];
                                               }
                                           }
                                       }
                                       
                                   }];
        
        [alertController addAction: okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)setupEditMode
{
    self.editProductLabel.hidden = NO;
    self.productPostImageView.hidden = YES;
    [self.listProductButton setImage:[UIImage imageNamed:@"saveProduct"] forState:UIControlStateNormal];
    
    self.image1Changed = NO;
    self.image2Changed = NO;
    self.image3Changed = NO;
    self.image4Changed = NO;
    self.editModeImageView.image = [UIImage imageNamed:@"bgGreen"];
    self.editModeImageView.alpha = 1.0;
    self.productHeadlineTextfield.text = self.productToEdit[@"productHeadline"];
    
    self.productDescriptionTextview.text = self.productToEdit[@"productDescription"];
    self.productDescriptionTextview.textColor = [UIColor blackColor];
    //self.categoryTextfield.text = self.productToEdit[@"category"];
    
    self.amountTextfield.text = [NSString stringWithFormat:@"$%@", self.productToEdit[@"amount"]];
    
    self.amountDescriptionTextfield.text = self.productToEdit[@"amountDescription"];
    
    //need image for header "Edit Product"
    //need image for List Product button that says "Update Listing"
    
    self.shareOnFacebookLine.hidden = YES;
    self.shareOnFacebookLabel.hidden = YES;
    self.shareOnFacebookSwitch.hidden = YES;
    
    
    
    NSString *productID = self.productToEdit[@"productID"];
    
    for(int i = 1; i < 5; i++)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.png", productID, i]];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            // Create a reference to the file you want to download
            FIRStorageReference *fileRef = [[[FIRStorage storage] reference] child:[NSString stringWithFormat:@"%@/farm/products/%@/images/%@_%d.png", self.userData.user.uid, productID, productID, i]];
            
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            [fileRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
                if (error != nil) {
                    
                    [self setPreviewImageToDefault:i];
                } else {
                    
                    [data writeToFile:filePath atomically:YES];
                    
                    [self setPreviewImage:i fromPath:filePath];
                    
                }
            }];
        }
        else
        {
            [self setPreviewImage:i fromPath:filePath];
        }
        
    }
    
    
}

- (void)setPreviewImageToDefault:(int)imageNum
{
    switch (imageNum) {
        case 1:
            self.image1Set = NO;
            [self.productImage1 setImage:[UIImage imageNamed:@"pictureSelected"] forState:UIControlStateNormal];
            break;
        case 2:
            self.image2Set = NO;
            [self.productImage2 setImage:[UIImage imageNamed:@"pictureSelected"] forState:UIControlStateNormal];
            break;
        case 3:
            self.image3Set = NO;
            [self.productImage3 setImage:[UIImage imageNamed:@"pictureSelected"] forState:UIControlStateNormal];
            break;
        case 4:
            self.image4Set = NO;
            [self.productImage4 setImage:[UIImage imageNamed:@"pictureSelected"] forState:UIControlStateNormal];
            break;
            
    }
}

- (void)setPreviewImage:(int)imageNum fromPath:(NSString *)filePath
{
    
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    UIImage *newImage = [UIImage imageWithImage:image
                                   scaledToSize:CGSizeMake(60, 60)];
    
    switch (imageNum) {
        case 1:
            self.image1 = image;
            self.image1Set = YES;
            [self.productImage1 setImage:newImage forState:UIControlStateNormal];
            self.productImage2.enabled = YES;
            break;
        case 2:
            self.image2 = image;
            self.image2Set = YES;
            [self.productImage2 setImage:newImage forState:UIControlStateNormal];
            self.productImage3.enabled = YES;
            break;
        case 3:
            self.image3 = image;
            self.image3Set = YES;
            [self.productImage3 setImage:newImage forState:UIControlStateNormal];
            self.productImage4.enabled = YES;
            break;
        case 4:
            self.image4 = image;
            self.image4Set = YES;
            [self.productImage4 setImage:newImage forState:UIControlStateNormal];
            break;
       
    }
}

- (void)amountTextFieldDone
{
    [self.amountDescriptionTextfield becomeFirstResponder];
}

- (void)pickerViewDone
{
    [self.amountTextfield becomeFirstResponder];
    
}

-(void)hideKeyboard
{
    
    [self.productHeadlineTextfield resignFirstResponder];
    [self.productDescriptionTextview resignFirstResponder];
    [self.categoryTextfield resignFirstResponder];
    [self.amountTextfield resignFirstResponder];
    [self.amountDescriptionTextfield resignFirstResponder];
  
    
}

- (void)moveScreenUp:(UIView *)textField
{
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if(heightFraction < 0.0){
        
        heightFraction = 0.0;
        
    }else if(heightFraction > 1.0){
        
        heightFraction = 1.0;
    }
    
    self.animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= self.animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];

}

- (void)moveScreenDown
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += self.animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}

- (void)postFacebookMessage:(NSString *)productID
{
    
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        // TODO: publish content.
        
        [[[FBSDKGraphRequest alloc]
          initWithGraphPath:@"me/feed"
          parameters: @{ @"message" : @"hello world"}
          HTTPMethod:@"POST"]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"Post id:%@", result[@"id"]);
             }
         }];
        /*
        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        photo.image = self.image1; // photo.image = self.shareImage;
        photo.userGenerated = YES;
        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        content.photos = @[photo];
        FBSDKShareAPI * shareApi = [[FBSDKShareAPI alloc]init];
        shareApi.message = [NSString stringWithFormat:@"%@ just added %@. Find it on the Farm Fresh App!", self.userData.farmName, self.productHeadlineTextfield.text]; // shareApi.message = self.tf.text;
        shareApi.shareContent = content;
        [shareApi share];
        */
    } else {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithPublishPermissions:@[@"publish_actions"]
                               fromViewController:self
                                          handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                              //TODO: process error or result.
                                              
                                              if(!error)
                                              {
                                                  [[[FBSDKGraphRequest alloc]
                                                    initWithGraphPath:@"me/feed"
                                                    parameters: @{ @"message" : @"hello world"}
                                                    HTTPMethod:@"POST"]
                                                   startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                                       if (!error) {
                                                           NSLog(@"Post id:%@", result[@"id"]);
                                                       }
                                                   }];
                                              }
                                              
                                          }];
    }
    
    
}

#pragma mark - Delegate Methods

- (void)imageUploadtCompleteForIndex:(int)index
{
    self.imagesComplete = YES;
    [self notifyUser];
}

- (void)newProductAdded:(NSError *)error
{
    
    if(!error)
    {
        self.firebaseComplete = YES;
        [self notifyUser];
    }
    else
    {
        [self presentViewController: [UIView createSimpleAlertWithMessage:@"There was an error processing this request please try again later"andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.userData.delegate = self;
    UIImage *imagePicked = [UIImage cropImageWithInfo:info];
    
    UIImage *newImage = [UIImage imageWithImage:imagePicked
                                   scaledToSize:CGSizeMake(60, 60)];
    
    
    switch (self.currentImage) {
        case 1:
            self.image1Set = YES;
            self.image1Changed = YES;
            [self.productImage1 setImage:newImage forState:UIControlStateNormal];
            self.productImage2.enabled = YES;
            self.image1 = [UIImage imageWithImage:imagePicked scaledToSize:CGSizeMake(375, 242)];
            break;
        case 2:
            self.image2Set = YES;
            self.image2Changed = YES;
            [self.productImage2 setImage:newImage forState:UIControlStateNormal];
            self.productImage3.enabled = YES;
            self.image2 = [UIImage imageWithImage:imagePicked scaledToSize:CGSizeMake(375, 242)];
            break;
        case 3:
            self.image3Set = YES;
            self.image3Changed = YES;
            [self.productImage3 setImage:newImage forState:UIControlStateNormal];
            self.productImage4.enabled = YES;
            self.image3 = [UIImage imageWithImage:imagePicked scaledToSize:CGSizeMake(375, 242)];
            break;
        case 4:
            self.image4Set = YES;
            self.image4Changed = YES;
            [self.productImage4 setImage:newImage forState:UIControlStateNormal];
            self.image4 = [UIImage imageWithImage:imagePicked scaledToSize:CGSizeMake(375, 242)];
            break;
            
        default:
            break;
    }
    
    /*
    
    // Create path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath;
    
    if(self.mode == editFarmProfileImageMode)
        filePath= [[paths objectAtIndex:0] stringByAppendingPathComponent:@"farmProfile.png"];
    else
        filePath= [[paths objectAtIndex:0] stringByAppendingPathComponent:@"profile.png"];
    
    NSData *imageData = UIImagePNGRepresentation(newImage);
    // Save image.
    [imageData writeToFile:filePath atomically:YES];
    
    if(self.mode == editFarmProfileImageMode)
        [ImageModel saveFarmProfileImage:imageData forUser:self.userData];
    else
        [ImageModel saveUserProfileImage:imageData forUser:self.userData];
    
    */
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.userData.delegate = self;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)categoriesUpdated
{
    [self.categoryTextfield.inputView reloadInputViews];
}

#pragma mark - Textfield Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.tag) {
        case 9: [self.productDescriptionTextview becomeFirstResponder];
            return NO;
            break;
        case 13: [textField resignFirstResponder];
            break;
        
            
    }
    
    return YES;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.categoryTextfield.isFirstResponder)
    {
        if([self.categoryTextfield.text isEqualToString:@""])
        {
            self.categoryTextfield.text = [self.userData.categories objectAtIndex:0];
            self.categorySelected = 0;
        }
    }
    
    if(textField.tag >= 10)
    {
        [self moveScreenUp:textField];
    }
    
    if(textField.tag == 12 && [textField.text isEqualToString:@""])
        textField.text = @"$";
        
        
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag >= 10)
    {
        [self moveScreenDown];
    }
    
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.tag == 12 && [textField.text isEqualToString:@""])
        textField.text = @"$";
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self moveScreenUp:textView];
    if ([textView.text isEqualToString:@"Write a short description"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
        
    }
    //[textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self moveScreenDown];
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Write a short description";
        textView.textColor = [UIColor colorWithRed:199.0 /255.0 green:199.0 / 255.0 blue:205.0 / 255.0 alpha:1.0]; //optional
        
    }
    //[textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"%@", textView.text);
    if ([text isEqualToString:@"\n"])
    {
        //[self.categoryTextfield becomeFirstResponder];
        [textView resignFirstResponder];
        return NO;
    }
    else
    {
        return YES;
    }
}


#pragma mark - PickerView Delegate

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerCategories)
        return [self.userData.categories count];
    else
        return 0;
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerCategories)
        return [self.userData.categories objectAtIndex:row];
    else
        return @"";
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerCategories)
    {
        self.categoryTextfield.text = [self.userData.categories objectAtIndex:row];
        self.categorySelected = row;
    }
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(touch.view == self.listProductButton)
    {
        return NO;
    }
    else
        return YES;
    
}

#pragma mark - Other Delegates

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end