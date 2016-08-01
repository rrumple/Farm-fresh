//
//  HelpDisplayViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/23/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "HelpDisplayViewController.h"
#import "CreateSupportTicketViewController.h"

@interface HelpDisplayViewController ()
@property (weak, nonatomic) IBOutlet UIButton *createSupportTicketButton;
@property (weak, nonatomic) IBOutlet UITextView *helpTextView;

@end

@implementation HelpDisplayViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.userData.isUserLoggedIn)
        self.createSupportTicketButton.hidden = YES;
    
    [self.helpTextView.layer setCornerRadius:15.0f];
    [self.helpTextView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.helpTextView.layer setBorderWidth:1.5f];
    [self.helpTextView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.helpTextView.layer setShadowOpacity:0.8];
    [self.helpTextView.layer setShadowRadius:3.0];
    [self.helpTextView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Help_Screen_Loaded" parameters:nil];
}

#pragma mark - IBActions

- (IBAction)menuButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - Methods



#pragma mark - Delegate Methods



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"createSupportTicketSegue"])
    {
        CreateSupportTicketViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

*/

@end
