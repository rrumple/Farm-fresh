//
//  PostReviewViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 5/30/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "PostReviewViewController.h"
#import "Constants.h"
#import "UIView+AddOns.h"

@interface PostReviewViewController ()<UITextViewDelegate, UserModelDelegate>
@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;
@property (weak, nonatomic) IBOutlet UIImageView *star1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star2ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star3ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star4ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *star5ImageView;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UILabel *starNumberLabel;

@property (nonatomic) int rating;

@property (nonatomic) CGFloat animatedDistance;

@property (nonatomic) BOOL saveChanges;
@property (nonatomic, strong) NSString *originalText;

@end

@implementation PostReviewViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reviewTextView.delegate = self;
    self.rating = 0;
    self.saveChanges = NO;
    self.userData.delegate = self;
    
    self.originalText = @"";
    
    [self.view addGestureRecognizer:[UIView setupTapGestureWithTarget:self Action:@selector(hideKeyboard) cancelsTouchesInview:NO setDelegate:YES]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Post_Review_Screen_Loaded" parameters:nil];
}

#pragma mark - IBActions

- (IBAction)postButtonPressed:(UIButton *)sender {
    sender.enabled = NO;
    
    if(![self.userData.user.uid isEqualToString:self.farmerSelected[@"farmerID"]])
    {
        NSDate *now = [NSDate date];
        
        NSDictionary *reviewData = @{
                                     @"reviewText" : [NSString stringWithFormat:@"%@\n\n\t-%@ %@.", self.reviewTextView.text,self.userData.firstName, [self.userData.lastName substringToIndex:1]],
                                     @"reviewRating" : [NSString stringWithFormat:@"%i", self.rating],
                                     @"reviewDate" : [NSString stringWithFormat:@"%@", now],
                                     @"reviewerID" : self.userData.user.uid
                                     
                                     };
        
        [self.userData addReview:reviewData ToFarmer:self.farmerSelected[@"farmerID"]];
    }
    else
    {
        [self presentViewController: [UIView createSimpleAlertWithMessage:@"You are not allowed to leave a review for your own farm."andTitle:@"Review" withOkButton:NO] animated: YES completion: nil];
    }
    
}

- (IBAction)closeButtonPressed:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)reviewStepperChanged:(UIStepper *)sender {
    
    self.rating = (int)sender.value;
    
    [self updateStars];
    
}

#pragma mark - Methods

- (void)updateStars
{
    switch(self.rating)
    {
        case 0:
            self.starNumberLabel.text = @"0";
            self.star1ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star5ImageView.image = [UIImage imageNamed:@"emptyStar"];
            break;
        case 1:
            self.starNumberLabel.text = @"0.5";
            self.star1ImageView.image = [UIImage imageNamed:@"halfStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star5ImageView.image = [UIImage imageNamed:@"emptyStar"];
            break;
        case 2:
            self.starNumberLabel.text = @"1.0";
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star5ImageView.image = [UIImage imageNamed:@"emptyStar"];
            break;
        case 3:
            self.starNumberLabel.text = @"1.5";
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"halfStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star5ImageView.image = [UIImage imageNamed:@"emptyStar"];
            break;
        case 4:
            self.starNumberLabel.text = @"2.0";
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star5ImageView.image = [UIImage imageNamed:@"emptyStar"];
            break;
        case 5:
            self.starNumberLabel.text = @"2.5";
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"halfStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star5ImageView.image = [UIImage imageNamed:@"emptyStar"];
            break;
        case 6:
            self.starNumberLabel.text = @"3.0";
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"emptyStar"];
            self.star5ImageView.image = [UIImage imageNamed:@"emptyStar"];
            break;
        case 7:
            self.starNumberLabel.text = @"3.5";
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"halfStar"];
            self.star5ImageView.image = [UIImage imageNamed:@"emptyStar"];
            break;
        case 8:
            self.starNumberLabel.text = @"4.0";
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star5ImageView.image = [UIImage imageNamed:@"emptyStar"];
            break;
        case 9:
            self.starNumberLabel.text = @"4.5";
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star5ImageView.image = [UIImage imageNamed:@"halfStar"];
            break;
        case 10:
            self.starNumberLabel.text = @"5.0";
            self.star1ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star2ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star3ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star4ImageView.image = [UIImage imageNamed:@"fullStar"];
            self.star5ImageView.image = [UIImage imageNamed:@"fullStar"];
            break;
        
    }
}

-(void)hideKeyboard
{
    
    [self.reviewTextView resignFirstResponder];
    
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

- (void)reviewAddComplete:(bool)wasSuccessful
{
    if(wasSuccessful)
    {
       
        if([self.farmerSelected[@"followerNotification"]boolValue])
        {
            NSDictionary *notificaiton = @{
                                       @"userID" : self.farmerSelected[@"farmerID"],
                                       @"alertText" : [NSString stringWithFormat:@"%@ %@ just posted a review of your farm.", self.userData.firstName, [self.userData.lastName substringToIndex:1]],
                                       @"fromUserID" : self.userData.user.uid,
                                       @"alertExpireDate" : @"",
                                       @"alertTimeSent" : @"",
                                       @"alertType" : @"6"
                                       
                                       };
        
            [[[self.userData.ref child:@"alert_queue"]childByAutoId]setValue:notificaiton];
        }

        
        [FIRAnalytics logEventWithName:@"Review_Posted_Successfully" parameters:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [FIRAnalytics logEventWithName:@"Review_Posted_Failed" parameters:nil];
        [self presentViewController: [UIView createSimpleAlertWithMessage:@"You have already left a review for this farmer"andTitle:@"Post Review Failed." withOkButton:NO] animated: YES completion: nil];
    }
}

#pragma mark TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //[self moveScreenUp:textView];
    
    if ([textView.text isEqualToString:@"Example: Farm did all that and more for me and they have great fruit and vegetables for the whole family.  We are going to get more to eat from this place for days to come."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
        
    }
    // [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    //[self moveScreenDown];
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Example: Farm did all that and more for me and they have great fruit and vegetables for the whole family.  We are going to get more to eat from this place for days to come.";
        textView.textColor = [UIColor colorWithRed:199.0 /255.0 green:199.0 / 255.0 blue:205.0 / 255.0 alpha:1.0]; //optional
        
        self.postButton.enabled = NO;
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
        self.postButton.enabled = YES;
    }
    
    if([[self.reviewTextView.text stringByReplacingCharactersInRange:range withString:text] isEqualToString:self.originalText])
    {
        self.postButton.enabled = NO;
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
