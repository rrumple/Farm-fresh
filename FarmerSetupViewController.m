//
//  FarmerSetupViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/16/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "FarmerSetupViewController.h"
#import "HelperMethods.h"
#import "CustomPicker.h"
#import "Constants.h"
#import "UIView+AddOns.h"
#import "FarmEditViewController.h"
#import "ContactModel.h"

@interface FarmerSetupViewController() <UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, DatabaseRequestDelegate>

@property (weak, nonatomic) IBOutlet UITextField *farmNameTextfield;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *addressTextfield;
@property (weak, nonatomic) IBOutlet UITextField *cityTextfield;
@property (weak, nonatomic) IBOutlet UITextField *stateTextfield;
@property (weak, nonatomic) IBOutlet UITextField *zipTextfield;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextfield;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *menuImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *farmSetupScrollView;

/* Save THIS FOR THE CONTACT EDIT SCREEN
@property (nonatomic) BOOL isChatChecked;
@property (nonatomic) BOOL isEmailChecked;
*/
@property (nonatomic) NSInteger stateSelected;
@property (nonatomic) CGFloat animatedDistance;

@property (nonatomic, strong) NSDictionary *states;

@property (nonatomic, strong) ContactModel *contactData;

@end

@implementation FarmerSetupViewController

- (ContactModel *)contactData
{
    if(!_contactData) _contactData = [[ContactModel alloc]init];
    return _contactData;
}

#pragma mark - Life Cycle

-(void)viewDidLayoutSubviews
{
    if(IS_IPHONE_4_OR_LESS)
    {
        self.farmSetupScrollView.contentSize = CGSizeMake(self.view.frame.size.width - 20, 575);
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.descriptionTextView.delegate = self;
    self.addressTextfield.delegate = self;
    self.cityTextfield.delegate = self;
    self.stateTextfield.delegate = self;
    self.zipTextfield.delegate = self;
    self.phoneTextfield.delegate = self;
    self.farmNameTextfield.delegate = self;
    
    
    /* Save THIS FOR THE CONTACT EDIT SCREEN
    self.isChatChecked = NO;
    self.isEmailChecked = NO;
     */
    

    
    [self.menuImageView setImage:self.menuImage];
    self.mainViewTopConstraint.constant = self.view.frame.size.height;
    
    [self.view layoutIfNeeded];
    
    self.stateTextfield.inputView = [CustomPicker createPickerWithTag:zPickerState withDelegate:self andDataSource:self target:self action:@selector(pickerViewDone) andWidth:self.view.frame.size.width];
    self.stateTextfield.inputAccessoryView = [CustomPicker createAccessoryViewWithTitle:@"Next" target:self action:@selector(pickerViewDone)];
    
    self.zipTextfield.inputAccessoryView = [CustomPicker createAccessoryViewWithTitle:@"Next" target:self action:@selector(doneClicked:)];

    self.phoneTextfield.inputAccessoryView = [CustomPicker createAccessoryViewWithTitle:@"Done" target:self action:@selector(doneClicked:)];
    
    self.states = [HelperMethods getStateNamesAndAbbreviations];
    
    [self.view addGestureRecognizer:[UIView setupTapGestureWithTarget:self Action:@selector(hideKeyboard) cancelsTouchesInview:NO setDelegate:YES]];
    
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Farmer_Setup_Screen_Loaded" parameters:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    self.mainViewTopConstraint.constant = 0;
    
    [UIView animateWithDuration:0.4f animations:^{
        
        [self.view layoutIfNeeded];
    }];
    
}

#pragma mark - IBActions
/* Save THIS FOR THE CONTACT EDIT SCREEN
- (IBAction)chatCheckBoxPressed:(UIButton *)sender {
    if(self.isChatChecked)
        [self setCheckBoxImage:sender withImageName:@"unCheckedBox"];
    else
       [self setCheckBoxImage:sender withImageName:@"checkedBox"];
    
    self.isChatChecked = !self.isChatChecked;
    
}

- (IBAction)emailCheckBoxPressed:(UIButton *)sender  {
    if(self.isEmailChecked)
        [self setCheckBoxImage:sender withImageName:@"unCheckedBox"];
    else
         [self setCheckBoxImage:sender withImageName:@"checkedBox"];
    
    self.isEmailChecked = !self.isEmailChecked;
}
 */

- (IBAction)createButtonPressed:(UIButton *)sender {
    
    sender.enabled = false;
    
    //validate entries
    if(self.farmNameTextfield.text.length > 0)
    {
        if(self.descriptionTextView.text.length > 0 && ![self.descriptionTextView.text isEqualToString:@"Farm descriptions should include your growing practices, chemical usage, etc.  Are you an organic farmer?  Be as descriptive as possible to your potential customers."])
        {
            if(self.addressTextfield.text.length > 0)
            {
               if(self.cityTextfield.text.length > 0)
               {
                   if(self.stateTextfield.text.length > 0)
                   {
                       if(self.zipTextfield.text.length > 0)
                       {
                           if(self.phoneTextfield.text.length > 0)
                           {
                               NSDictionary *farmData = @{
                                                          @"farmName" : self.farmNameTextfield.text,
                                                          @"farmDescription" : self.descriptionTextView.text,
                                                          @"address" : self.addressTextfield.text,
                                                          @"city" : self.cityTextfield.text,
                                                          @"state" : self.stateTextfield.text,
                                                          @"zip" : self.zipTextfield.text,
                                                          @"mainPhone" : self.phoneTextfield.text,
                                                          @"rating" : @"99",
                                                          @"ratingDouble" : @"0.0",
                                                          @"numReviews" : @"0",
                                                          @"contactPhone" : @"",
                                                          @"contactEmail" : @"",
                                                          @"useChat" : @"0",
                                                          @"useEmail" : @"0",
                                                          @"useTelephone" : @"0",
                                                          @"numFavorites" : @"0",
                                                          @"followerNotification" : @"1",
                                                          @"reviewNotification" : @"1",
                                                          @"pictureUpdated" : @"0"
                                                          };
                               [self sendPDFEmailToFarmer];
                               
                               [self.userData saveFarmData:farmData];
                               
                               [self.userData updateFarmerStatus:YES];
                           }
                           else
                           {
                               sender.enabled = YES;
                               [self presentViewController: [UIView createSimpleAlertWithMessage:@"Phone number is missing."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
                           }
                       }
                       else
                       {
                           sender.enabled = YES;
                           [self presentViewController: [UIView createSimpleAlertWithMessage:@"Zip Code is missing."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
                       }
                   }
                   else
                   {
                       sender.enabled = YES;
                       [self presentViewController: [UIView createSimpleAlertWithMessage:@"State is missing."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
                   }
               }
                else
                {
                    sender.enabled = YES;
                    [self presentViewController: [UIView createSimpleAlertWithMessage:@"City is missing."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
                }
            }
            else
            {
                sender.enabled = YES;
                 [self presentViewController: [UIView createSimpleAlertWithMessage:@"Invalid Address entered."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
            }
        }
        else
        {
            sender.enabled = YES;
            [self presentViewController: [UIView createSimpleAlertWithMessage:@"Invalid Farm description entered."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
        }
    }
    else
    {
        sender.enabled = YES;
        [self presentViewController: [UIView createSimpleAlertWithMessage:@"Invalid Farm Name entered."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
    }
    
  
    
}

- (IBAction)exitButtonPressed {
    
    self.mainViewTopConstraint.constant = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
                    [self.navigationController popViewControllerAnimated:NO];
    }];

    
}

#pragma mark - Methods

- (void)sendPDFEmailToFarmer
{
    dispatch_queue_t createQueue = dispatch_queue_create("sendPDFEmail", NULL);
    dispatch_async(createQueue, ^{
        
        [self.contactData sendPDFToFarmer:[NSString stringWithFormat:@"%@ %@", self.userData.firstName, self.userData.lastName] withEmail:self.userData.email withFarmName:self.farmNameTextfield.text withDelegate:self];

        
    });
    
}

- (void)doneClicked:(id)sender
{
    NSLog(@"Done Clicked.");
    if(self.zipTextfield.isFirstResponder)
    {
        [self.phoneTextfield becomeFirstResponder];
    }
    else
    {
        [self hideKeyboard];
    }
}

- (void)pickerViewDone
{
    [self.zipTextfield becomeFirstResponder];

}

-(void)hideKeyboard
{
    [self.addressTextfield resignFirstResponder];
    [self.stateTextfield resignFirstResponder];
    [self.cityTextfield resignFirstResponder];
    [self.zipTextfield resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
    [self.farmNameTextfield resignFirstResponder];
    [self.phoneTextfield resignFirstResponder];

}
/* Save THIS FOR THE CONTACT EDIT SCREEN
- (void)setCheckBoxImage:(UIButton *)button withImageName:(NSString *)name
{
    [button setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
}
*/

#pragma mark - Delegate Methods

- (void)httpRequestCompleteWithData:(NSArray *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", data);
        
    });
    
}

#pragma mark - Textfield Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.tag) {
        case 8: [self.descriptionTextView becomeFirstResponder];
            return NO;
            break;
        case 10: [self.cityTextfield becomeFirstResponder];
            break;
        case 11: [self.stateTextfield becomeFirstResponder];
            break;
        case 12: [self.zipTextfield becomeFirstResponder];
            break;
        case 13: [self.phoneTextfield becomeFirstResponder];
            break;
        case 14: [textField resignFirstResponder];
            break;
    
    }
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"%@ --- %@", textField.text, string);
    if(textField.tag == 14)
    {
        switch (textField.text.length) {
            case 0:
                if(![string isEqualToString:@""])
                {
                    textField.text = [NSString stringWithFormat:@"(%@", string];
                    return NO;
                }
            case 3:
                if(![string isEqualToString:@""])
                {
                    textField.text = [NSString stringWithFormat:@"%@%@) ", textField.text, string];
                    return NO;
                }
                break;
            case 8:
                if(![string isEqualToString:@""])
                {
                    textField.text = [NSString stringWithFormat:@"%@%@-", textField.text, string];
                    return NO;
                }
                break;
            case 14:
                if(![string isEqualToString:@""])
                    return NO;
                break;
                
            default:
                break;
        }
    }
    else if(textField.tag == 13)
    {
        switch (textField.text.length) {
            case 5:
                if(![string isEqualToString:@""])
                    return NO;
                break;
                
            default:
                break;
        }
    }
    
    return YES;
}
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.stateTextfield.isFirstResponder)
    {
        if([self.stateTextfield.text isEqualToString:@""])
        {
            self.stateTextfield.text = [self.states[@"stateAbbreviations"] objectAtIndex:0];
            self.stateSelected = 0;
        }
    }
    
    if(textField.tag >= 10)
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
        
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag >= 10)
    {
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y += self.animatedDistance;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        [UIView commitAnimations];
    }
}

#pragma mark TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Farm descriptions should include your growing practices, chemical usage, etc.  Are you an organic farmer?  Be as descriptive as possible to your potential customers."]) {
        textView.text = nil;
        textView.textColor = [UIColor blackColor]; //optional
        
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Farm descriptions should include your growing practices, chemical usage, etc.  Are you an organic farmer?  Be as descriptive as possible to your potential customers.";
        textView.textColor = [UIColor colorWithRed:199.0 /255.0 green:199.0 / 255.0 blue:205.0 / 255.0 alpha:1.0]; //optional
        
    }

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"%@", textView.text);
     if ([text isEqualToString:@"\n"])
     {
         [self.addressTextfield becomeFirstResponder];
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
    if(pickerView.tag == zPickerState)
        return [self.states[@"stateNames"] count];
    else
        return 0;
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerState)
        return [self.states[@"stateNames"] objectAtIndex:row];
    else
        return @"";
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerState)
    {
        self.stateTextfield.text = [self.states[@"stateAbbreviations"] objectAtIndex:row];
        self.stateSelected = row;
    }
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(touch.view == self.createButton)
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"farmerSetupStep2Segue"])
    {
        FarmEditViewController *fevc = segue.destinationViewController;
        
        fevc.userData = self.userData;
        fevc.isFirstTimeSetup = YES;
        fevc.menuImage = self.menuImage;
    }
  
}



@end
