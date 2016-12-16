//
//  EditProductViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 6/10/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "EditProductViewController.h"
#import "PostProductViewController.h"
#import "HelperMethods.h"
#import "SwipeableTableViewCell.h"
#import "UIView+AddOns.h"
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface EditProductViewController ()<UITableViewDelegate, UITableViewDataSource, SwipeableTableViewCellDelegate, UserModelDelegate, FBSDKSharingDelegate>

@property (nonatomic, strong) NSArray *products;
@property (weak, nonatomic) IBOutlet UITableView *productsTableView;
@property (nonatomic, strong) NSDictionary *productSelected;
@property (nonatomic, strong) NSDate *expireDate;
@property (nonatomic) BOOL waitToRefreshTableview;
@property (nonatomic) BOOL image1Set;
@property (nonatomic, strong) UIImage *image1;

@end

@implementation EditProductViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.productsTableView.delegate = self;
    self.productsTableView.dataSource = self;
    self.waitToRefreshTableview = NO;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Edit_Product_Screen_Loaded" parameters:nil];
    
    self.userData.delegate = self;
    [self farmProductUpdated];
    
}

#pragma mark - IBActions

- (IBAction)exitButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Methods

- (void)loadProductImageAtIndex:(NSIndexPath *)path forImage:(UIImageView *)imageView withActivityIndicator:(UIActivityIndicatorView *)spinner
{
    NSDictionary *tempDic = [self.products objectAtIndex:path.row];
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
                imageView.image = [UIImage imageNamed:@"noImageAvailable"];
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

- (void)startFacebookSharing:(NSURL *)url isUserGenerated:(BOOL)userGenerated
{
    FBSDKSharePhoto *photo;
    if(userGenerated)
        photo = [FBSDKSharePhoto photoWithImage:self.image1 userGenerated:YES];
    else
        photo = [FBSDKSharePhoto photoWithImageURL:url userGenerated:NO];
    
    NSDictionary *properties = @{
                                 @"og:type": @"farmfreshns:farm_product",
                                 @"og:title": [NSString stringWithFormat:@"%@ - %@", self.productSelected[@"productHeadline"], self.userData.farmName],
                                 @"og:description": self.productSelected[@"productDescription"],
                                 @"og:image": @[photo],
                                 @"og:url": @"https://fb.me/1169058139821564",
                                 @"farmfreshns:name": self.productSelected[@"productHeadline"]
                                 };
    FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
    
    
    
    FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
    action.actionType = @"farmfreshns:product_posted";
    [action setObject:object forKey:@"farm_product"];
    [action setString:@"true" forKey:@"fb:explicitly_shared"];
    [action setString:self.productSelected[@"productHeadline"] forKey:@"title"];
    //[action setObject: @"true" forKey: @"fb:explicitly_shared"];
    
    FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
    content.action = action;
    content.previewPropertyName = @"farm_product";
    
    FBSDKShareAPI *shareAPI = [[FBSDKShareAPI alloc] init];
    
    shareAPI.delegate = self;
    shareAPI.shareContent = content;
    
    [shareAPI share];
}

- (void)loadImagesForFacebookPost
{
    NSString *productID = self.productSelected[@"productID"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.png", productID, 1]];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        // Create a reference to the file you want to download
        FIRStorageReference *fileRef = [[[FIRStorage storage] reference] child:[NSString stringWithFormat:@"%@/farm/products/%@/images/%@_%d.png", self.userData.user.uid, productID, productID, 1]];
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        [fileRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
            if (error != nil) {
                
                [self setPreviewImageToDefault:1];
            } else {
                
                [data writeToFile:filePath atomically:YES];
                
                [self setPreviewImage:1 fromPath:filePath];
                
            }
        }];
    }
    else
    {
        [self setPreviewImage:1 fromPath:filePath];
    }
        
    
}

- (void)setPreviewImageToDefault:(int)imageNum
{
    switch (imageNum) {
        case 1:
            self.image1Set = NO;
            break;
            
    }
    
    [self postFacebookMessage:nil];
}

- (void)setPreviewImage:(int)imageNum fromPath:(NSString *)filePath
{
    
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    switch (imageNum) {
        case 1:
            self.image1 = image;
            self.image1Set = YES;
            break;
            
    }
    
    [self postFacebookMessage:nil];
}

- (void)postFacebookMessage:(NSURL *)url
{
    
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        // TODO: publish content.
        
        // Create a reference to the file you want to download
        
        NSString * link;
        
        
        if(self.image1Set)
        {
            [self startFacebookSharing: url isUserGenerated:NO];
        }
        else
        {
            link = @"appImages/farmFresh.png";
        }
        
        FIRStorageReference *storageLinkRef = [[[FIRStorage storage] reference] child:link];
        // Fetch the download URL
        [storageLinkRef downloadURLWithCompletion:^(NSURL *URL, NSError *error){
            if (error != nil) {
                // Handle any errors
            } else {
                // Get the download URL for 'images/stars.jpg'
                
                [self startFacebookSharing:URL isUserGenerated:NO];
                
                
            }
        }];
        
        
        
    } else {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithPublishPermissions:@[@"publish_actions"]
                               fromViewController:self
                                          handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                              //TODO: process error or result.
                                              
                                              if(!error)
                                              {
                                                  if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
                                                      
                                                      [self postFacebookMessage:url];
                                                  }
                                                  else
                                                  {
                                                      //self.isFacebookPostComplete = YES;
                                                      //[self notifyUser];
                                                  }
                                              }
                                              else
                                              {
                                                  //self.isFacebookPostComplete = YES;
                                                  //[self notifyUser];
                                              }
                                              
                                          }];
    }
    
    
}

#pragma mark - Delegate Methods

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"%@", results);
    [self.userData addFacebookPostIDToProduct:self.productSelected[@"productID"] withPostID:results[@"postId"]];
    //[self imageUploadUpdate];
    //self.isFacebookPostComplete = YES;
    //[self notifyUser];
}

-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    //[self imageUploadUpdate];
    NSLog(@"%@", error);
    //self.isFacebookPostComplete = YES;
    //[self notifyUser];
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    //[self imageUploadUpdate];
    NSLog(@"Share Cancel");
    //self.isFacebookPostComplete = YES;
    //[self notifyUser];
}

- (void)newProductAdded:(NSError *)error
{
    if(!error)
    {
        [FIRAnalytics logEventWithName:@"Relist_Product" parameters:@{
                                                                      @"productID" :self.productSelected[@"productID"]
                                                                      
                                                                      }];
        
        NSString *title = @"Re-List Product";
        NSString *message = [NSString stringWithFormat:@"%@ relisted successfully and will expire on %@ - Would you like to publish this on Facebook?", self.productSelected[@"productHeadline"], [HelperMethods formatExpireDate: self.expireDate]];
        
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:title
                                              message:message
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *facebookAction = [UIAlertAction actionWithTitle:@"Publish to Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            //publish to facebook
            
            [self loadImagesForFacebookPost];
            
            self.waitToRefreshTableview = NO;
            [self farmProductUpdated];
            
        }];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       self.waitToRefreshTableview = NO;
                                       [self farmProductUpdated];
                                       
                                   }];
        
        [alertController addAction:facebookAction];
        [alertController addAction: okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        [self presentViewController: [UIView createSimpleAlertWithMessage:@"There was an error processing this request please try again later"andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
        
        self.waitToRefreshTableview = NO;
        [self farmProductUpdated];
    }
}

- (void)farmProductUpdated
{
    if(!self.waitToRefreshTableview)
    {
        self.products = [self.userData getProductsArray];
        
        if(self.products.count == 0)
           [self.navigationController popViewControllerAnimated:YES];
        else
            [self.productsTableView reloadData];
        
        
    }
}

- (void)deleteButtonPressedAtIndex:(NSIndexPath *)indexPath
{
    NSString *title = @"Delete Product?";
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete %@?", [[self.products objectAtIndex:indexPath.row] objectForKey:@"productHeadline"]];
    
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Delete"
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction *action)
                               {
                                   [self.userData deleteProductFromFirebase:[[self.products objectAtIndex:indexPath.row] objectForKey:@"productID"]];
                                   
                               }];
    UIAlertAction *cancelAction = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction *action)
                               {
                                
                                   
                               }];
    
    [alertController addAction: okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (void)editButtonPressedAtIndex:(NSIndexPath *)indexPath
{
    self.productSelected = [self.products objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"editProductSegue" sender:self];
}

- (void)makeInactiveButtonPressedAtIndex:(NSIndexPath *)indexPath
{
    
    [self.userData makeProductInactive:[[self.products objectAtIndex:indexPath.row] objectForKey:@"productID"] withUserID:nil forProductNamed:nil];
    
    [FIRAnalytics logEventWithName:@"Make_Product_Inactive" parameters:@{
                                                                         @"productID" :[[self.products objectAtIndex:indexPath.row] objectForKey:@"productID"]
                                                                         
                                                                         }];
}

- (void)reListButtonPressedAtIndex:(NSIndexPath *)indexPath
{
    self.waitToRefreshTableview = YES;
    
    NSDate *now = [NSDate date];
    
    int daysToAdd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"productExpireDays"]intValue];
    self.expireDate = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
    
    NSDictionary *productData = @{
                        
                         @"isActive" : @"1",
                         @"datePosted" : [NSString stringWithFormat:@"%@", now],
                         @"expireDate" : [NSString stringWithFormat:@"%@", self.expireDate]
                         
                         };
    
    self.productSelected = [self.products objectAtIndex:indexPath.row];
    
    
    [self.userData updateProduct:self.productSelected[@"productID"] withData:productData];
}

#pragma mark - Table view data source
/*
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.layer.cornerRadius = 10;
    cell.layer.masksToBounds = YES;
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"produceCell";
    
    SwipeableTableViewCell *cell;
    
        NSDictionary *tempDic = [self.products objectAtIndex:indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UIImageView *produceImageView = (UIImageView *)[cell viewWithTag:5];
        UILabel *headlineLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *postedOnTimeLabel = (UILabel *)[cell viewWithTag:4];
        UILabel *expiresOnTimeLabel = (UILabel *)[cell viewWithTag:3];
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell.contentView viewWithTag:13];
        UIView *backgroundView = (UIView *)[cell viewWithTag:2];
    
        if([tempDic[@"isActive"]boolValue])
        {
            backgroundView.alpha = .85f;
            [cell showMakeInactiveButton];
            postedOnTimeLabel.text =[NSString stringWithFormat:@"Posted: %@", [HelperMethods formatPostedAndExpireDate:tempDic[@"datePosted"] isPostedDate:YES]];
            expiresOnTimeLabel.text = [NSString stringWithFormat:@"Expires: %@", [HelperMethods formatPostedAndExpireDate:tempDic[@"expireDate"] isPostedDate:NO]];
        }
        else
        {
            backgroundView.alpha = .55f;
            [cell showRelistButton];
            postedOnTimeLabel.text = @"";
            expiresOnTimeLabel.text = @"Item is not currently active";
        }
    
        cell.indexPath = indexPath;
    
    produceImageView.image = [UIImage imageNamed:@"noImageAvailable"];
        [self loadProductImageAtIndex:indexPath forImage:produceImageView withActivityIndicator:spinner];
        
        for(int i = 2; i < 5; i++)
        {
            [HelperMethods downloadProductImageFromFirebase:tempDic[@"farmerID"] forProductID:tempDic[@"productID"] imageNumber:i];
        }

        
        headlineLabel.text = tempDic[@"productHeadline"];
    
        
        
        produceImageView.layer.cornerRadius = 10;
        produceImageView.layer.masksToBounds = YES;
    
    
    cell.delegate = self;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SwipeableTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(cell.isOpen)
       [cell resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
    else
        [cell setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"editProductSegue"])
    {
        PostProductViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
        vc.isInEditMode = YES;
        vc.productToEdit = self.productSelected;
        
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
