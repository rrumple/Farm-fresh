//
//  InviteFriendsViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/21/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import <Social/Social.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface InviteFriendsViewController () <FBSDKAppInviteDialogDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *menuImageView;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

@end

@implementation InviteFriendsViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Invite_Screen_Loaded" parameters:nil];
}

#pragma mark - IBActions
- (IBAction)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)emailInviteButtonPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    
    MFMailComposeViewController *mcvc = [[MFMailComposeViewController alloc] init];
    mcvc.mailComposeDelegate = self;
    [mcvc setSubject:@"Check out Farm Fresh"];
    UIImage *image = [UIImage imageNamed:@"emailAppIcon"];
    //include your app icon here
    [mcvc addAttachmentData:UIImageJPEGRepresentation(image, 1) mimeType:@"image/jpg" fileName:@"icon.jpg"];
    // your message and link
    NSString *defaultBody =@"Email Description, apple.co/2adU7sH";
    [mcvc setMessageBody:defaultBody isHTML:YES];
    [self presentViewController:mcvc animated:YES completion:^{
        sender.enabled = YES;
    }];
}

- (IBAction)facebookButtonPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/1169058139821564"];
    //optionally set previewImageURL
    content.appInvitePreviewImageURL = [NSURL URLWithString:@"http://farmfresh.io/img/farm_fresh_FB.png"];
    
    // Present the dialog. Assumes self is a view controller
    // which implements the protocol `FBSDKAppInviteDialogDelegate`.
    [FBSDKAppInviteDialog showFromViewController:self
                                     withContent:content
                                        delegate:self];
    

    
    
}

- (IBAction)twitterButtonPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"I just downloaded the #FarmFresh app http://apple.co/2a9HpPY "];
        [self presentViewController:tweetSheet animated:YES completion:^{
            sender.enabled = YES;
        }];
    }
    else
    {
        
    }
}


#pragma mark - Methods



#pragma mark - Delegate Methods

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
    self.facebookButton.enabled = YES;
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
    self.facebookButton.enabled = YES;
}


#pragma mark - Navigation


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.menuImageView setImage:self.menuImage];
}

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
