//
//  ChangePasswordViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/22/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "UIView+AddOns.h"

@interface ChangePasswordViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *updatedPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@end

@implementation ChangePasswordViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.oldPasswordTextField.delegate = self;
    self.updatedPasswordTextField.delegate = self;
    self.confirmPasswordTextField.delegate = self;
    
    [self.view addGestureRecognizer:[UIView setupTapGestureWithTarget:self Action:@selector(hideKeyboard) cancelsTouchesInview:NO setDelegate:YES]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Change_Password_Screen_Loaded" parameters:nil];
}

#pragma mark - IBActions

- (IBAction)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changePasswordButtonPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    if(self.updatedPasswordTextField.text.length > 5)
    {
        if([self.updatedPasswordTextField.text isEqualToString:self.confirmPasswordTextField.text])
        {
            if(self.oldPasswordTextField.text.length > 0)
            {
                FIRUser *user = [FIRAuth auth].currentUser;
                FIRAuthCredential *credential = [FIREmailPasswordAuthProvider credentialWithEmail:self.userData.email password:self.oldPasswordTextField.text];
                
                [user reauthenticateWithCredential:credential completion:^(NSError * _Nullable error) {
                    if(error)
                    {
                        sender.enabled = YES;
                        self.oldPasswordTextField.text = @"";
                        [self presentViewController: [UIView createSimpleAlertWithMessage:@"Old Password Mismatch, if you have forgotten your password click Forgot Password"andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
                        
                    }
                    else
                    {
                        [user updatePassword:self.updatedPasswordTextField.text completion:^(NSError * _Nullable error) {
                            if(error)
                            {
                                NSLog(@"%@",error);
                                sender.enabled = YES;
                                [self presentViewController: [UIView createSimpleAlertWithMessage:@"There was an error Authenticating your account please contact support@farmfresh.io"andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
                                
                            }
                            else
                            {
                                [self presentViewController: [UIView createSimpleAlertWithMessage:@"Password Changed Successfully"andTitle:@"Password" withOkButton:YES]  animated: YES completion: nil];
                                self.oldPasswordTextField.text = @"";
                                self.updatedPasswordTextField.text = @"";
                                self.confirmPasswordTextField.text = @"";
                                sender.enabled = YES;
                            }
                        }];
                        
                    }
                }];
            }
            else
            {
                sender.enabled = YES;
                 [self presentViewController: [UIView createSimpleAlertWithMessage:@"Invalid Old Password."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
            }
        
            
        }
        else
        {
            sender.enabled = YES;
            self.updatedPasswordTextField.text = @"";
            self.confirmPasswordTextField.text = @"";
            [self presentViewController: [UIView createSimpleAlertWithMessage:@"New and Confirm Passwords do not Match."andTitle:@"Password" withOkButton:NO] animated: YES completion: nil];
        }
    }
    else
    {
        sender.enabled = YES;
        [self presentViewController: [UIView createSimpleAlertWithMessage:@"Password needs to be 6 or more characters" andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
    }
}

- (IBAction)forgotPasswordButtonPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    
    [[FIRAuth auth] sendPasswordResetWithEmail:self.userData.email completion:^(NSError * _Nullable error) {
        if (error) {
            // There was an error processing the request
            sender.enabled = YES;
        } else {
            sender.enabled = YES;
            [self presentViewController: [UIView createSimpleAlertWithMessage:@"An email has been sent with instruction on how to reset your password" andTitle:@"Password Reset" withOkButton:YES] animated: YES completion: nil];
        }

    }];
    
   

}

#pragma mark - Methods

-(void)hideKeyboard
{
    
    [self.oldPasswordTextField resignFirstResponder];
    [self.updatedPasswordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
    
}


#pragma mark - Delegate Methods

#pragma mark - TextField Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.tag) {
        case 1: [self.updatedPasswordTextField becomeFirstResponder];
            break;
        case 2: [self.confirmPasswordTextField becomeFirstResponder];
            break;
        case 3: [textField resignFirstResponder];
            break;
            
            
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
