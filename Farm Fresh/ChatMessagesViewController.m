//
//  ChatMessagesViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/22/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "ChatMessagesViewController.h"
#import "Constants.h"
#import "UIView+AddOns.h"
#import "HelperMethods.h"
#import "ChatLabel.h"

@interface ChatMessagesViewController () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UserModelDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (nonatomic, strong) FIRDatabaseReference *userRef;
@property (nonatomic, strong) FIRDatabaseReference *recRef;
@property (nonatomic, strong) FIRDatabaseReference *recNotificationRef;

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) NSArray *allMessages;
@property (nonatomic, strong) NSDictionary *allMessagesDic;
@property (nonatomic, strong) NSArray *receiversMessages;

@property (nonatomic) BOOL isFirstLoad;

@property (nonatomic) BOOL notificationProcessing;
@property (nonatomic) BOOL messagePending;
@property (nonatomic) BOOL verifyingUsersMessages;
@property (nonatomic) BOOL verifyingReceiversMessages;
@property (nonatomic) int notificationTypePending;
@property (nonatomic, strong) NSNotification *pendingNotification;
@property (nonatomic) BOOL tableRefreshPending;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextFieldHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (nonatomic) CGFloat animatedDistance;
@property (nonatomic) CGFloat keyboardHeight;

@end

@implementation ChatMessagesViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];


    
    self.messageTableView.dataSource = self;
    self.messageTableView.delegate = self;
    self.messageTextView.delegate = self;
    self.messageTextView.tag = 4;

    if(!self.userSelected)
    {
        //[self getMissingUserInfo];
        
    }
    else
    {
        [self setupFirebase];
    }
    
    [self.view addGestureRecognizer:[UIView setupTapGestureWithTarget:self Action:@selector(hideKeyboard) cancelsTouchesInview:NO setDelegate:YES]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Chat_Messages_Screen_Loaded" parameters:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
     [self.userData updateNotificationsStatus:[self.userSelected objectForKey:@"userID"]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}

#pragma mark - IBActions

- (IBAction)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendButtonPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    
    if([self.messageTextView.text length] > 0)
    {
        //self.loadingIndicatorView.hidden = false;
        //self.loadingActivityViewLabel.text = @"Sending Message...";
        //[self.loadingActivityIndicator startAnimating];
        self.messageTextView.editable = false;
        
        if(self.notificationProcessing)
        {
            //add send message to queue
            self.messagePending = true;
        }
        else
        {
            [self sendTheMessage];
        }
        
    }
    else
    {
        [self presentViewController: [UIView createSimpleAlertWithMessage:@"Message field is blank."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
    }
}

- (IBAction)insertPhotoButtonPressed:(UIButton *)sender {
    
}

#pragma mark - Methods

- (void)sendAlertToOtherUser
{
    
    NSString *name = @"";
    
    if(self.userType == 0)
    {
        name = [NSString stringWithFormat:@"%@ %@", self.userData.firstName, self.userData.lastName];
    }
    else if(self.userType == 1)
    {
        name = self.userData.farmName;
    }
    
    NSDictionary *notificaiton = @{
                                   @"userID" : [self.userSelected objectForKey:@"userID"],
                                   @"alertText" : [NSString stringWithFormat:@"%@ has sent you a message.", name],
                                   @"fromUserID" : self.userData.user.uid,
                                   @"alertExpireDate" : @"",
                                   @"alertTimeSent" : @"",
                                   @"alertType" : @"2",
                                   @"userType" : [NSString stringWithFormat:@"%li", (long)self.userType]
                                   
                                   };
    
    [[[self.userData.ref child:@"alert_queue"]childByAutoId]setValue:notificaiton withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        [FIRAnalytics logEventWithName:@"Notification_Sent" parameters:@{
                                                                         @"Notification_Type" : @"Chat Alert"
                                                                         
                                                                         }];
    }];
    
   
    
    
}

- (void)sendTheMessage
{
    if(self.messageTextViewHeightConstraint.constant != 29 && self.messageTextFieldHeightConstraint.constant != 30)
    {
        self.messageTextViewHeightConstraint.constant = 29;
        self.messageTextFieldHeightConstraint.constant = 30;
        [self.view layoutIfNeeded];
    }
    
    NSString *statusMessage = [HelperMethods chatDateToStringhhmma:[NSDate date]];
    
    NSDictionary *newMessage1 = @{@"messageText" : self.messageTextView.text, @"author" : self.userData.user.uid, @"hidden" : @"0", @"status" : statusMessage, @"verified" : @"0"} ;
    
    self.messageTextView.text = @"Write Message...";
    self.messageTextView.textColor = [UIColor colorWithRed:199.0 /255.0 green:199.0 / 255.0 blue:205.0 / 255.0 alpha:1.0];
    
    
    //[self addUserToRecentList];
    
    
    FIRDatabaseReference *messageRef = [self.userRef childByAutoId];
    
    [messageRef updateChildValues: newMessage1];
    
    
    
    FIRDatabaseReference *recMessageRef = [self.recRef childByAutoId];
    
    [recMessageRef updateChildValues:newMessage1 withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        if(!error)
        {
            [self.recNotificationRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot2) {
                
                if(snapshot2.value == [NSNull null]) {
                    NSLog(@"No messages");
                    FIRDatabaseReference *notification = [self.recNotificationRef childByAutoId];
                    [notification updateChildValues:@{@"userID": self.userData.user.uid}];
                    
                    
                } else {
                    NSDictionary *value1 = snapshot2.value;
                    NSArray *keys = value1.allKeys;
                    
                    BOOL match = false;
                    for(NSString *key in keys)
                    {
                        NSDictionary *tempDic = [value1 objectForKey:key];
                        if([[tempDic objectForKey:@"userID"] isEqualToString:self.userData.user.uid])
                        {
                            match = true;
                            break;
                        }
                    }
                    
                    if(!match)
                    {
                        FIRDatabaseReference *notification = [self.recNotificationRef childByAutoId];
                        [notification updateChildValues:@{@"userID": self.userData.user.uid}];
                    }
                }
                
            }];
            
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // The object has been saved.
                [FIRAnalytics logEventWithName:@"Chat_Message_Sent" parameters:nil];
                [self sendAlertToOtherUser];
                
                self.sendButton.enabled = true;
                self.messageTextView.editable = true;
                //self.autoScrollNextTime = true;
                //[self silentPushAlertReceived];
                
            });
            
        }
    }];
    
    
    
}

- (void)setupFirebase
{
    //[self addUserToRecentList];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.titleLabel.text = [NSString stringWithFormat:@"%@", [self.userSelected objectForKey:@"name"]];
    });
    
    if(self.userData.user.uid)
    {
        self.userRef = [self.userData.ref child:[NSString stringWithFormat:@"/messages/%@-%@", self.userData.user.uid, [self.userSelected objectForKey:@"userID"]]];
        self.recRef = [self.userData.ref child:[NSString stringWithFormat:@"/messages/%@-%@", [self.userSelected objectForKey:@"userID"], self.userData.user.uid]];
        self.recNotificationRef = [self.userData.ref child:[NSString stringWithFormat:@"/notification/%@", [self.userSelected objectForKey:@"userID"]]];
  
        
        [[[self.userRef queryOrderedByChild:@"hidden"] queryEqualToValue:@"0"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            if(snapshot.value == [NSNull null]) {
                NSLog(@"No messages");
                dispatch_async(dispatch_get_main_queue(), ^{
                    //self.loadingIndicatorView.hidden = true;
                    //[self.loadingActivityIndicator stopAnimating];
                    
                });
                
                
            } else {
                
                [self.recRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot2) {
                    if(snapshot2.value == [NSNull null]) {
                        NSLog(@"No messages");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //self.loadingIndicatorView.hidden = true;
                            //[self.loadingActivityIndicator stopAnimating];
                            
                        });
                        
                        
                    } else {
                        NSDictionary *value1 = snapshot2.value;
                        NSArray *keys = value1.allKeys;
                        
                        
                        for(NSString *key in keys)
                        {
                            NSDictionary *tempDic = [value1 objectForKey:key];
                            if(![[[tempDic objectForKey:key]objectForKey:@"status"] isEqualToString:@"Read"] && ![[tempDic objectForKey:@"author"]isEqualToString:self.userData.user.uid])
                            {
                                FIRDatabaseReference *messageRef = [self.recRef child:key];
                                
                                [messageRef updateChildValues:@{@"status":@"Read"}];
                            }
                        }
                    }
                    
                }];
                
                
                
                
                
                NSDictionary *value = snapshot.value;
                //NSLog(@"Unsorted allKeys: %@", value.allKeys);
                NSArray *sortedAllKeys = [value.allKeys sortedArrayUsingSelector:@selector(compare:)];
                //NSLog(@"Sorted allKeys: %@", sortedAllKeys);
                
                self.allMessages = sortedAllKeys;
                self.allMessagesDic = snapshot.value;
                
               
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //self.loadingIndicatorView.hidden = true;
                    //[self.loadingActivityIndicator stopAnimating];
                    
                    if(self.messageTextView.isFirstResponder)
                    {
                        self.tableRefreshPending = true;
                    }
                    else
                    {
                        //if(!self.isFirstLoad)
                            //[self.audioPlayer play];
                        [self.messageTableView reloadData];
                        if([self.allMessages count] > 0)
                        {
                            
                            NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.allMessages count]-1 inSection:0];
                            
                            [self.messageTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        }
                        
                        
                    }
                    self.isFirstLoad = false;
                });
                
                
                
                
            }
        }];
        
       
    }
    
    
    
    
}

-(void)hideKeyboard
{
    
    
    if(self.tableRefreshPending)
    {
        self.tableRefreshPending = NO;
        [self.messageTableView reloadData];
    }
    [self.messageTextView resignFirstResponder];
    
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(touch.view == self.sendButton)
    {
        return NO;
    }
    else
        return YES;
    
}

#pragma mark - Table view data source


// put ur height calculation method i took some hardcoded values change it :)
-(CGFloat)heightForText:(NSString *)text andFontSize:(CGFloat)fontSize andWidth:(CGFloat)width
{
    NSInteger MAX_HEIGHT = 2000;
    UITextView * textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, width, MAX_HEIGHT)];
    textView.text = text;
    textView.font = [UIFont systemFontOfSize:fontSize];
    [textView sizeToFit];
    return textView.frame.size.height;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    CGFloat heightOfcell = [self heightForText:[[self.allMessagesDic objectForKey:[self.allMessages objectAtIndex:indexPath.row]] objectForKey:@"messageText"] andFontSize:13.0 andWidth:206.0];
    NSLog(@"%f",heightOfcell);
    
    
    return 33 + heightOfcell;
    
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.allMessages count];
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userBubble";
    static NSString *CellIdentifier2 = @"fromBubble";
    
    UITableViewCell *cell;
    
    NSDictionary *message = [self.allMessagesDic objectForKey:[self.allMessages objectAtIndex:indexPath.row]];
    
    
    if(![self.userData.user.uid isEqualToString:[message objectForKey:@"author"]])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UILabel *statusLabel = (UILabel *)[cell.contentView viewWithTag:2];
        NSArray *statusArray = [[message objectForKey:@"status"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        
        //check for today
        NSString *today = [HelperMethods chatDateToStringhhmma:[NSDate date]];
        NSArray *todayArray = [today componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        if([statusArray[1] intValue] == [todayArray[1] intValue] && [statusArray[2] intValue] == [todayArray[2] intValue] && [statusArray[3] intValue] == [todayArray[3] intValue])
        {
            statusLabel.text = [NSString stringWithFormat:@"Sent Today: %@", statusArray[4]];
        }
        //check for yesterday
        else
        {
            statusLabel.text = [NSString stringWithFormat:@"Sent %@: %@/%@ %@", statusArray[0], statusArray[1], statusArray[2], statusArray[4]];
        }
        
        
        
        NSInteger MAX_HEIGHT = 2000;
        ChatLabel *messageLabel = [[ChatLabel alloc]initWithFrame:CGRectMake(0, 0, 100, MAX_HEIGHT)];
        
        UILabel *tempLabel = (UILabel* )[cell viewWithTag:5];
        if(tempLabel)
            [tempLabel removeFromSuperview];
        
        messageLabel.text = [message objectForKey:@"messageText"];
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor = [UIColor colorWithRed:119.0f / 255.0f green:169.0f / 255.0f blue:66.0f / 255.0f alpha:1.0f];
        
        [messageLabel setFont:[UIFont systemFontOfSize:13.0f]];
        UITextView * textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, 206, MAX_HEIGHT)];
        textView.text = [message objectForKey:@"messageText"];
        textView.font = [UIFont systemFontOfSize:13];
        [textView sizeToFit];
        
        [messageLabel setTag:5];
        CGRect frame = messageLabel.frame;
        frame.size.width = textView.frame.size.width;
        frame.size.height = textView.frame.size.height;
        frame.origin.x = 8;
        frame.origin.y = 11;
        frame.size.width += 10;
        if(frame.size.width > 206)
        {
            frame.size.width = 206;
            
        }
        messageLabel.numberOfLines = 100;
        [messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
        messageLabel.frame = frame;
        [messageLabel.layer setCornerRadius:10.0f];
        [messageLabel setClipsToBounds:YES];
        
        
        [cell addSubview:messageLabel];
        
        
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
        UILabel *statusLabel = (UILabel *)[cell.contentView viewWithTag:2];
        if([[message objectForKey:@"status"]isEqualToString:@"Read"])
        {
            statusLabel.text = @"Read";
        }
        else
        {
            NSArray *statusArray = [[message objectForKey:@"status"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
            //check for today
            NSString *today = [HelperMethods chatDateToStringhhmma:[NSDate date]];
            NSArray *todayArray = [today componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
            if([statusArray[1] intValue] == [todayArray[1] intValue] && [statusArray[2] intValue] == [todayArray[2] intValue] && [statusArray[3] intValue] == [todayArray[3] intValue])
            {
                statusLabel.text = [NSString stringWithFormat:@"Sent Today: %@", statusArray[4]];
            }
            //check for yesterday
            else
            {
                statusLabel.text = [NSString stringWithFormat:@"Sent %@: %@/%@ %@", statusArray[0], statusArray[1], statusArray[2], statusArray[4]];
            }
        }
        
        
        NSInteger MAX_HEIGHT = 2000;
        ChatLabel *messageLabel = [[ChatLabel alloc]initWithFrame:CGRectMake(0, 0, 185, MAX_HEIGHT)];
        
        
        UILabel *tempLabel = (UILabel* )[cell viewWithTag:5];
        if(tempLabel)
            [tempLabel removeFromSuperview];
        
        messageLabel.text = [message objectForKey:@"messageText"];
        messageLabel.backgroundColor = [UIColor colorWithWhite:118.0f / 255.0f alpha:1.0f];
        messageLabel.textColor = [UIColor whiteColor];
        [messageLabel setFont:[UIFont systemFontOfSize:13.0f]];
        UITextView * textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, 206, MAX_HEIGHT)];
        textView.text = [message objectForKey:@"messageText"];
        textView.font = [UIFont systemFontOfSize:13];
        [textView sizeToFit];
        
        [messageLabel setTag:5];
        CGRect frame = messageLabel.frame;
        frame.size.width = textView.frame.size.width;
        frame.size.height = textView.frame.size.height;
        if(frame.size.width > 206)
        {
            frame.size.width = 206;
            
        }
        frame.origin.y = 11;
        frame.size.width += 10;
        frame.origin.x = cell.frame.size.width - (frame.size.width + 10);
        messageLabel.numberOfLines = 100;
        [messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
        messageLabel.frame = frame;
        [messageLabel.layer setCornerRadius:10.0f];
        [messageLabel setClipsToBounds:YES];
        
        
        [cell addSubview:messageLabel];
    
        
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete ) {
        
        
        FIRDatabaseReference *messageRef = [self.userRef child:[self.allMessages objectAtIndex:indexPath.row]];
        
        [messageRef updateChildValues:@{@"hidden":@"1"}];
        
        
    }
    
}

#pragma mark TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self moveScreenUp:textView];
    
    if ([textView.text isEqualToString:@"Write Message..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
        
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self moveScreenDown];
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Write Message...";
        textView.textColor = [UIColor colorWithRed:199.0 /255.0 green:199.0 / 255.0 blue:205.0 / 255.0 alpha:1.0]; //optional
        
        
        
    }
   
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self hideKeyboard];
        
        [self sendButtonPressed:self.sendButton];
        return NO;
    }
    
    CGFloat height = [self heightForText:[NSString stringWithFormat:@"%@%@", textView.text, text] andFontSize:14.0 andWidth:textView.frame.size.width - 3];
    //height -= 3;
    
    CGFloat TFheight = textView.frame.size.height;
    
    if(height != TFheight)
    {
        CGFloat difference = height - TFheight;
        
        if(difference > 15 || difference < -15)
        {
            CGRect frame = textView.frame;
            CGRect tableViewFrame = self.messageTableView.frame;
            tableViewFrame.size.height -= difference;
            frame.size.height += difference;
            frame.origin.y -= difference;
            
            self.messageTextViewHeightConstraint.constant += difference;
            self.messageTextFieldHeightConstraint.constant += difference;
            
            [UIView animateWithDuration:0.3 animations:^{
                
                [self.view layoutIfNeeded];
                //textView.frame = frame;
                //self.messageTableView.frame = tableViewFrame;
                //self.messageTextField.frame = frame;
            }];
            
            NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.allMessages count]-1 inSection:0];
            [self.messageTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
        
    }
    return true;


}


#pragma mark - Navigation



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
