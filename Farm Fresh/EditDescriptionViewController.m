//
//  EditDescriptionViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/20/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "EditDescriptionViewController.h"
#import "UIView+AddOns.h"
#import "Constants.h"


@interface EditDescriptionViewController () <UITextViewDelegate, UserModelDelegate>
@property (weak, nonatomic) IBOutlet UITextView *farmDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) NSString *originalText;
@property (weak, nonatomic) IBOutlet UIView *farmDescriptionView;

@property (nonatomic) CGFloat animatedDistance;

@property (nonatomic) BOOL saveChanges;

@end

@implementation EditDescriptionViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.farmDescriptionTextView.delegate = self;
    self.userData.delegate = self;
    
    self.saveChanges = NO;
    
    if(self.userData.farmDescription.length > 0)
    {
        self.originalText = self.userData.farmDescription;
        self.farmDescriptionTextView.text = self.userData.farmDescription;
        self.farmDescriptionTextView.textColor = [UIColor blackColor];
    }
    else
        self.originalText = @"";
    
    [self.farmDescriptionView.layer setCornerRadius:15.0f];
    [self.farmDescriptionView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.farmDescriptionView.layer setBorderWidth:1.5f];
   
    
     [self.view addGestureRecognizer:[UIView setupTapGestureWithTarget:self Action:@selector(hideKeyboard) cancelsTouchesInview:NO setDelegate:YES]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Edit_Description_Screen_Loaded" parameters:nil];
}

#pragma mark - IBActions

- (IBAction)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonPressed:(UIButton *)sender {
    
    if([self.farmDescriptionTextView.text isEqualToString:@"Farm descriptions should include your growing practices, chemical usage, etc.  Are you an organic farmer?  Be as descriptive as possible to your potential customers."])
       [self.userData updateFarmDescription:@""];
    else
        [self.userData updateFarmDescription:self.farmDescriptionTextView.text];
}

#pragma mark - Methods

- (void)farmerProfileUpdated
{
    self.saveChanges = NO;
    self.saveButton.enabled = NO;
    self.originalText = self.userData.farmDescription;
    [self.saveButton setImage:[UIImage imageNamed:@"farmDescUpdated"] forState:UIControlStateDisabled];
}

-(void)hideKeyboard
{
    
    [self.farmDescriptionTextView resignFirstResponder];

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

#pragma mark - Delegate Methods

#pragma mark TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self moveScreenUp:textView];
    
    if ([textView.text isEqualToString:@"Farm descriptions should include your growing practices, chemical usage, etc.  Are you an organic farmer?  Be as descriptive as possible to your potential customers."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
        
    }
   // [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self moveScreenDown];
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Farm descriptions should include your growing practices, chemical usage, etc.  Are you an organic farmer?  Be as descriptive as possible to your potential customers.";
        textView.textColor = [UIColor colorWithRed:199.0 /255.0 green:199.0 / 255.0 blue:205.0 / 255.0 alpha:1.0]; //optional
        
        self.saveButton.enabled = NO;
        self.saveChanges = NO;
        
    }
   // [textView resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    if(!self.saveChanges)
    {
        self.saveChanges = YES;
        self.saveButton.enabled = YES;
    }
    
    if([[self.farmDescriptionTextView.text stringByReplacingCharactersInRange:range withString:text] isEqualToString:self.originalText])
    {
        self.saveButton.enabled = NO;
        self.saveChanges = NO;
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
