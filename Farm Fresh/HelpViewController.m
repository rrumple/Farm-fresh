//
//  HelpViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/21/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "HelpViewController.h"
#import "HelpDisplayViewController.h"
#import "CreateSupportTicketViewController.h"

@interface HelpViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *termsAndConditionsButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyPolicyButton;
@property (weak, nonatomic) IBOutlet UIButton *safetyGuidelinesButton;

@end

@implementation HelpViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.versionLabel.text = [NSString stringWithFormat:@"v %@",[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [FIRAnalytics logEventWithName:@"Help_Screen_Loaded" parameters:nil];
    
    self.helpButton.enabled = YES;
    self.termsAndConditionsButton.enabled = YES;
    self.privacyPolicyButton.enabled = YES;
    self.safetyGuidelinesButton.enabled = YES;
}

#pragma mark - IBActions

- (IBAction)exitButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)privacyPolicyButtonPressed:(UIButton *)sender {
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.farmfresh.io/privacy-policy.html"]];
}

- (IBAction)helpButtonPressed:(UIButton *)sender {
    
   /* sender.enabled = NO;
    
    [self performSegueWithIdentifier:@"showHelpSegue" sender:self];
    */
}

#pragma mark - Methods



#pragma mark - Delegate Methods



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"showHelpSegue"])
    {
        HelpViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }
    else if([segue.identifier isEqualToString:@"helpToCreateSupportTicketSegue"])
    {
        CreateSupportTicketViewController *vc = segue.destinationViewController;
        
        vc.userData = self.userData;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
