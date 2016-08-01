//
//  EditProfileImageViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 5/15/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "EditProfileImageViewController.h"
#import "UIImage+Resize.h"
#import "ImageModel.h"

#import "HelperMethods.h"


@interface EditProfileImageViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *currentImageView;
@property (nonatomic) int navCounter;
@property (weak, nonatomic) IBOutlet UIButton *defaultProfileImageButton;
@property (weak, nonatomic) IBOutlet UILabel *imageUpdatedLabel;

@end

@implementation EditProfileImageViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.imagePicker = [[UIImagePickerController alloc]init];
    
    
    self.currentImageView.layer.cornerRadius = 30.0f;
    self.currentImageView.layer.masksToBounds = YES;
    self.navCounter = 0;
    [self updateImage];
    
    if(self.mode == editFarmProfileImageMode)
        self.defaultProfileImageButton.hidden = YES;
    else
    {
        if(self.userData.provider == FACEBOOK)
        {
            [self.defaultProfileImageButton setTitle:@"Use Facebook Profile Image" forState:UIControlStateNormal];
            self.defaultProfileImageButton.hidden = NO;
        }
        else if (self.userData.provider == GOOGLE)
        {
            [self.defaultProfileImageButton setTitle:@"Use Google Profile Image" forState:UIControlStateNormal];
            self.defaultProfileImageButton.hidden = NO;
        }
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloadComplete) name:HelperMethodsImageDownloadCompleted object:nil];
}

#pragma mark - IBActions
- (IBAction)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)useProviderImageButtonPressed:(UIButton *)sender {
    
    [HelperMethods downloadSingleImageFromBaseURL:self.userData.imageURL withFilename:@"profile.png" saveToDisk:YES replaceExistingImage:YES];
}

- (IBAction)takePhotoButtonPressed:(UIButton *)sender {
    
    self.imagePicker.allowsEditing = YES;
    
    if(sender.tag == 1 && [UIImagePickerController isSourceTypeAvailable:
                           UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        self.imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    //CGRect sourceRect = CGRectMake(self.view.frame.size.width/2-200, self.view.frame.size.height/2 - 300, 400, 400);
    self.imagePicker.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    //self.imagePicker.popoverPresentationController.sourceRect = sourceRect;
    //self.imagePicker.popoverPresentationController.sourceView = self.view;
    self.navCounter = 0;

    self.imagePicker.delegate = self;
    
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
    NSString *pngFilePath;
    
    if(self.mode == editFarmProfileImageMode)
        pngFilePath = [NSString stringWithFormat:@"%@/farmProfile.png",docDir];
    else
        pngFilePath = [NSString stringWithFormat:@"%@/profile.png",docDir];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
        self.currentImageView.image = image;
        
    }
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
    
    self.currentImageView.image = newImage;
    [self imageUpdated];
    
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
    
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Navigation



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
