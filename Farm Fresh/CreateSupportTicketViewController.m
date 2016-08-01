//
//  CreateSupportTicketViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 7/20/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "CreateSupportTicketViewController.h"
#import "CustomPicker.h"
#import "Constants.h"
#import "UIView+AddOns.h"
#import "ContactModel.h"
#import "HelperMethods.h"

@interface CreateSupportTicketViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, DatabaseRequestDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *problemTextfield;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UITextView *problemDescriptionTextView;
@property (nonatomic, strong) NSArray *problems;
@property (nonatomic) NSInteger problemSelected;
@property (weak, nonatomic) IBOutlet UIButton *submitTicketButton;
@property (nonatomic, strong) ContactModel *contactData;
@property (weak, nonatomic) IBOutlet UIView *problemDescriptionView;
@property (weak, nonatomic) IBOutlet UIView *spinnterView;
@property (nonatomic) CGFloat animatedDistance;
@property (nonatomic) CGFloat keyboardHeight;
@end

@implementation CreateSupportTicketViewController

- (ContactModel *)contactData
{
    if(!_contactData) _contactData = [[ContactModel alloc]init];
    return _contactData;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.problemTextfield.delegate = self;
    self.problemDescriptionTextView.delegate = self;
    
    if(self.userData.isUserLoggedIn)
    {
        self.nameTextfield.hidden = YES;
        self.emailTextField.hidden = YES;
        self.nameLabel.hidden = NO;
        self.emailLabel.hidden = NO;
    }
    else
    {
        self.nameTextfield.hidden = NO;
        self.emailTextField.hidden = NO;
        self.nameLabel.hidden = YES;
        self.emailLabel.hidden = YES;
    }
    
    self.problems = @[
                      @"User Account Issue",
                      @"Searching for Product Issue",
                      @"Farmer Profile Issue",
                      @"Posting a product Issue",
                      @"App Crash or Bug",
                      @"Other"
                      
                      ];
    
    
    [self.problemDescriptionView.layer setCornerRadius:15.0f];
    [self.problemDescriptionView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.problemDescriptionView.layer setBorderWidth:1.5f];
    //[self.problemDescriptionView.layer setShadowColor:[UIColor blackColor].CGColor];
    //[self.problemDescriptionView.layer setShadowOpacity:0.8];
    //[self.problemDescriptionView.layer setShadowRadius:3.0];
    //[self.problemDescriptionView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    self.nameLabel.text = [NSString stringWithFormat:@"Name: %@ %@", self.userData.firstName, self.userData.lastName];
    self.emailLabel.text = [NSString stringWithFormat:@"Email: %@", self.userData.email];
    
    self.problemTextfield.inputView = [CustomPicker createPickerWithTag:zPickerProblem withDelegate:self andDataSource:self target:self action:@selector(pickerViewDone) andWidth:self.view.frame.size.width];
    
    self.problemTextfield.inputAccessoryView = [CustomPicker createAccessoryViewWithTitle:@"Next" target:self action:@selector(pickerViewDone)];
    
    [self.view addGestureRecognizer:[UIView setupTapGestureWithTarget:self Action:@selector(hideKeyboard) cancelsTouchesInview:NO setDelegate:YES]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     [FIRAnalytics logEventWithName:@"Create_Ticket_Screen_Loaded" parameters:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}

#pragma mark - IBActions


- (IBAction)menuButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submitTicketButtonPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    
    if(self.userData.firstName.length > 0 || self.nameTextfield.text.length > 0)
    {
        if(self.userData.lastName.length > 0 || self.nameTextfield.text.length > 0)
        {
            if(self.problemTextfield.text.length > 0)
            {
                if(self.problemDescriptionTextView.text.length > 0)
                {
                    if(self.userData.isUserLoggedIn)
                    {
                        [self hideKeyboard];
                        self.spinnterView.hidden = NO;
                        
                        [self sendEmail];
                    }
                    else
                    {
                        if([HelperMethods isEmailValid:self.emailTextField.text])
                        {
                            [self hideKeyboard];
                            self.spinnterView.hidden = NO;
                            
                            [self sendEmail];
                        }
                        else
                        {
                            [self presentViewController: [UIView createSimpleAlertWithMessage:@"Invalid email address entered."andTitle:@"Error" withOkButton:YES] animated: YES completion: nil];
                        }
                    }
                   
                    
                }
                else
                {
                    
                    //problem description is missing
                    sender.enabled = YES;
                }
            }
            else
            {
                //problem Text is missing
                sender.enabled = YES;
            }
        }
        else
        {
            //last name missing
            sender.enabled = YES;
        }
    }
    else
    {
        //first name missing
        sender.enabled = YES;
    }
    
}

#pragma mark - Methods

- (void)sendEmail
{
    dispatch_queue_t createQueue = dispatch_queue_create("sendEmail", NULL);
    dispatch_async(createQueue, ^{
        
        if(self.userData.isUserLoggedIn)
        {
            [self.contactData sendSupportTicketFrom:[NSString stringWithFormat:@"%@ %@", self.userData.firstName, self.userData.lastName] withEmail:self.userData.email withProblem:self.problemTextfield.text andMessage:self.problemDescriptionTextView.text withDelegate:self];
        }
        else
        {
            [self.contactData sendSupportTicketFrom:self.nameTextfield.text withEmail:self.emailTextField.text withProblem:self.problemTextfield.text andMessage:self.problemDescriptionTextView.text withDelegate:self];
        }
        
    });
    
}

- (void)hideKeyboard
{
    [self.problemDescriptionTextView resignFirstResponder];
    [self.problemTextfield resignFirstResponder];
}

- (void)pickerViewDone
{
    [self.problemDescriptionTextView becomeFirstResponder];
    
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
    
    self.animatedDistance = floor(self.keyboardHeight * heightFraction);
    if(IS_IPHONE_4_OR_LESS || IS_IPHONE_5)
    {
        self.animatedDistance += 25;
    }
    
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

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    NSLog(@"%f", keyboardFrameBeginRect.size.height);
    self.keyboardHeight = keyboardFrameBeginRect.size.height;
    
    
}

#pragma mark - Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if(IS_IPHONE_5 || IS_IPHONE_4_OR_LESS)
        [self moveScreenUp:textView];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(IS_IPHONE_5 || IS_IPHONE_4_OR_LESS)
        [self moveScreenDown];
}

- (void)textFieldDidBeginEditing:(UITextView *)textView
{
    if([self.problemTextfield isFirstResponder])
    {
        if(self.problemTextfield.text.length == 0)
            self.problemTextfield.text = self.problems[0];
    }
}

- (void)httpRequestCompleteWithData:(NSArray *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", data);
        
        if(data.count == 1)
        {
            self.spinnterView.hidden = YES;
            NSDictionary *tempdic = data[0];
            
            if(![tempdic[@"error"]boolValue])
            {
                if(self.userData.isUserLoggedIn)
                {
                    self.nameTextfield.text = @"";
                    self.emailTextField.text = @"";
                }
                self.problemDescriptionTextView.text = @"";
                self.problemTextfield.text = @"";
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:@"Create Support Ticket"
                                                      message:@"Ticket created succesfully, we will get back to you as soon as possible to assist you."
                                                      preferredStyle:UIAlertControllerStyleAlert];
                
               
                
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               [self.navigationController popViewControllerAnimated:YES];
                                               
                                           }];
                
                [alertController addAction: okAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
                
                    
                    
        
            }
            else
            {
                [self presentViewController: [UIView createSimpleAlertWithMessage:@"Create Support Ticket Error"andTitle:@"Unable to submit at this time please try again later." withOkButton:NO] animated: YES completion: nil];
                
               
            }
        }
    });
}

#pragma mark - PickerView Delegate

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerProblem)
        return [self.problems count];
    else
        return 0;
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerProblem)
        return [self.problems objectAtIndex:row];
    else
        return @"";
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerProblem)
    {
        self.problemTextfield.text = [self.problems objectAtIndex:row];
        self.problemSelected = row;
    }
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(touch.view == self.submitTicketButton)
    {
        return NO;
    }
    else
        return YES;
    
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
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
