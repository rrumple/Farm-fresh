//
//  SetContactInfoViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 4/7/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "SetContactInfoViewController.h"
#import "UIView+AddOns.h"
#import "HelperMethods.h"

@interface SetContactInfoViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *chatSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *emailSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *phoneSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *followerNotificationSwitch;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveChangesButton;
@property (weak, nonatomic) IBOutlet UISwitch *reviewNotificationSwitch;


@end



@implementation SetContactInfoViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.phoneTextField.delegate = self;
    
    if(self.userData.useChat)
       [self.chatSwitch setOn:YES];
    if(self.userData.useEmail)
    {
        [self.emailSwitch setOn:YES];
        self.emailTextField.enabled = YES;
        self.emailTextField.text = self.userData.contactEmail;
    }
    if(self.userData.useTelephone)
    {
        [self.phoneSwitch setOn:YES];
        self.phoneTextField.enabled = YES;
        self.phoneTextField.text = self.userData.contactPhone;
    }
    
    if(self.userData.followerNotification)
    {
        [self.followerNotificationSwitch setOn:YES];
    }
    
    if(self.userData.reviewNotification)
    {
        [self.reviewNotificationSwitch setOn:YES];
    }
    

    [self.view addGestureRecognizer:[UIView setupTapGestureWithTarget:self Action:@selector(hideKeyboard) cancelsTouchesInview:NO setDelegate:YES]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Set_Contact_Info_Screen_Loaded" parameters:nil];
}

#pragma mark - IBActions

- (IBAction)backButtonPressed {
    
    if(self.saveChangesButton.isEnabled)
       [self saveButtonPressed:self.saveChangesButton];
     [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)newFollowerNotificationSwitch:(UISwitch *)sender {
    
    [self.userData updateFollowerNotificationStatus:sender.isOn];
    
}
- (IBAction)reviewNotificationSwitchChanged:(UISwitch *)sender {
    
    [self.userData updateReviewNotifcationStatus:sender.isOn];
}

- (IBAction)chatSwitchChanged:(UISwitch *)sender {
    
    self.saveChangesButton.enabled = YES;
    
    [self.userData updateUseChatStatus:sender.isOn];
}

- (IBAction)emailSwitchChanged:(UISwitch *)sender {
    
     self.saveChangesButton.enabled = YES;
    
    if(sender.isOn)
    {
        self.emailTextField.enabled = YES;
        self.emailTextField.text = self.userData.email;
    }
    else
    {
        self.emailTextField.enabled = NO;
        self.emailTextField.text = @"";
        [self.userData updateContactEmail:@""];
    }
    
    [self.userData updateUseEmailStatus:sender.isOn];
}

- (IBAction)phoneSwitchChanged:(UISwitch *)sender {
    
    self.saveChangesButton.enabled = YES;
    
    if(sender.isOn)
    {
        self.phoneTextField.enabled = YES;
        self.phoneTextField.text = self.userData.mainPhone;
    }
    else
    {
        self.phoneTextField.enabled = NO;
        self.phoneTextField.text = @"";
        [self.userData updateContactPhone:@""];
    }
    
    [self.userData updateUsePhoneStatus:sender.isOn];
}

- (IBAction)saveButtonPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    BOOL saveChangeSuccessful = NO;
    
    if(self.emailSwitch.isOn)
    {
        if([HelperMethods isEmailValid:self.emailTextField.text])
        {
            [self.userData updateContactEmail:self.emailTextField.text];
            saveChangeSuccessful = YES;
        }
        else
        {
            sender.enabled = YES;
            [self presentViewController: [UIView createSimpleAlertWithMessage:@"Invalid Email address entered."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
        }
    }
    else
        saveChangeSuccessful = YES;
    
    if(self.phoneSwitch.isOn)
    {
        if(self.phoneTextField.text.length > 0)
        {
            [self.userData updateContactPhone:self.phoneTextField.text];
            saveChangeSuccessful = YES;
        }
        else
        {
            sender.enabled = YES;
            [self presentViewController: [UIView createSimpleAlertWithMessage:@"Invalid Phone number entered."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
        }
    }
    else
        saveChangeSuccessful = YES;
    
    if(saveChangeSuccessful)
       [self.navigationController popViewControllerAnimated:YES];
    else
        sender.enabled = YES;
    
    
    
    
    
}

#pragma mark - Methods

-(void)hideKeyboard
{
    [self.emailTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    
}

#pragma mark - Delegate Methods

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
    
   
    
    return YES;
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
