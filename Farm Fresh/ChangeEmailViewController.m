//
//  ChangeEmailViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/22/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "ChangeEmailViewController.h"
#import "UIView+AddOns.h"
#import "HelperMethods.h"
#import "Constants.h"

@interface ChangeEmailViewController () <UserModelDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *changeEmailButton;
@property (weak, nonatomic) IBOutlet UITextField *updatedEmailTextField;
@property (weak, nonatomic) IBOutlet UILabel *currentEmailLabel;

@end

@implementation ChangeEmailViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userData.delegate = self;
    self.updatedEmailTextField.delegate = self;
    
    self.currentEmailLabel.text = self.userData.email;
    

    
    [self.view addGestureRecognizer:[UIView setupTapGestureWithTarget:self Action:@selector(hideKeyboard) cancelsTouchesInview:NO setDelegate:YES]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Change_Email_Screen_Loaded" parameters:nil];
}

#pragma mark - IBActions

- (IBAction)changeEmailButtonPressed:(UIButton *)sender {
    
    if([HelperMethods isEmailValid:self.updatedEmailTextField.text] && ![self.currentEmailLabel.text isEqualToString:self.updatedEmailTextField.text])
    {
        sender.enabled = NO;
        
        if(self.userData.provider != PASSWORD)
        {
             [self.userData updateEmail:self.updatedEmailTextField.text withPassword:@""];
        }
        else
        {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Enter Password"
                                                  message:@"Password required to change email address."
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
             {
                 textField.placeholder = @"Password";
             }];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           UITextField *password = alertController.textFields.firstObject;
                                           
                                           [self.userData updateEmail:self.updatedEmailTextField.text withPassword:password.text];
                                          
                                       }];
            
             [alertController addAction: okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
       
    }
    else
    {
        [self presentViewController: [UIView createSimpleAlertWithMessage:@"Email address not valid." andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
    }
    
}

- (IBAction)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Methods

-(void)hideKeyboard
{
    
    [self.updatedEmailTextField resignFirstResponder];
    
}

#pragma mark - Delegate Methods

- (void)emailFailure:(int)failCode
{
    switch (failCode) {
        case 1:
            [self presentViewController: [UIView createSimpleAlertWithMessage:@"Email address already exist, please use a different email address or sign in using that email address." andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
            self.updatedEmailTextField.text = @"";
            break;
        case 2:
            [self presentViewController: [UIView createSimpleAlertWithMessage:@"Invalid Password" andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
            break;
            
        default:
            break;
    }
    
    
    self.changeEmailButton.enabled = YES;
    
}

- (void)updateStatusComplete
{
    self.changeEmailButton.enabled = YES;
    
    self.currentEmailLabel.text = self.userData.email;
    
    self.updatedEmailTextField.text = @"";
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
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
