//
//  EditScheduleViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 4/11/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "EditScheduleViewController.h"
#import "UIView+AddOns.h"
#import "CustomPicker.h"
#import "Constants.h"
#import "HelperMethods.h"

@interface EditScheduleViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UserModelDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *dayOfTheWeekSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *scheduleSelectLocationTextfield;
@property (weak, nonatomic) IBOutlet UITextField *scheduleOpenTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *scheduleCloseTimeTextField;
@property (weak, nonatomic) IBOutlet UIView *overrideView;
@property (weak, nonatomic) IBOutlet UITextField *overrideLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *overrideCloseTimeTextField;
@property (weak, nonatomic) IBOutlet UIView *saveChangesView;
@property (weak, nonatomic) IBOutlet UILabel *saveStatusLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveChangesTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *locationClearButton;
@property (weak, nonatomic) IBOutlet UIButton *scheduleTimeClearButton;
@property (weak, nonatomic) IBOutlet UISwitch *overrideScheduleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *openClosedSwitch;
@property (nonatomic) NSInteger scheduleLocationSelected;
@property (nonatomic) NSInteger overrideLocationSelected;
@property (nonatomic) CGFloat animatedDistance;
@property (weak, nonatomic) IBOutlet UILabel *openCloseLabel;

@property (weak, nonatomic) IBOutlet UIButton *saveChangesButton;
@property (nonatomic, strong) UIDatePicker *startDatePicker;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic) BOOL changesMade;
@property (nonatomic) NSInteger previousSegment;
@property (weak, nonatomic) IBOutlet UIView *scheduleView;
@property (nonatomic) BOOL openTimeIsGood;
@property (nonatomic) BOOL closeTimeIsGood;


@end

@implementation EditScheduleViewController

- (void)setChangesMade:(BOOL)changesMade
{
    _changesMade = changesMade;
    
    if(changesMade)
        self.saveChangesButton.enabled = YES;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.overrideLocationTextField.delegate = self;
    self.overrideCloseTimeTextField.delegate = self;
    self.scheduleSelectLocationTextfield.delegate = self;
    self.scheduleCloseTimeTextField.delegate = self;
    self.scheduleOpenTimeTextField.delegate = self;
    self.userData.delegate = self;
    
    self.changesMade = NO;
    self.openTimeIsGood = NO;
    self.closeTimeIsGood = NO;
    
    [self.scheduleView.layer setCornerRadius:15.0f];
    [self.scheduleView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.scheduleView.layer setBorderWidth:1.5f];
    
    self.scheduleSelectLocationTextfield.inputView = [CustomPicker createPickerWithTag:zPickerScheduleLocations withDelegate:self andDataSource:self target:self action:@selector(hideKeyboard) andWidth:self.view.frame.size.width];
    self.scheduleSelectLocationTextfield.inputAccessoryView = [CustomPicker createAccessoryViewWithTitle:@"Done" target:self action:@selector(hideKeyboard)];
    
    self.overrideLocationTextField.inputView = [CustomPicker createPickerWithTag:zPickerOverrideLocations withDelegate:self andDataSource:self target:self action:@selector(hideKeyboard) andWidth:self.view.frame.size.width];
    self.overrideLocationTextField.inputAccessoryView = [CustomPicker createAccessoryViewWithTitle:@"Done" target:self action:@selector(hideKeyboard)];
    
    [self.view addGestureRecognizer:[UIView setupTapGestureWithTarget:self Action:@selector(datePickerDonePressed) cancelsTouchesInview:NO setDelegate:YES]];
    
    NSLocale *usLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setLocale:usLocale];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //check to see if users chat is enabled
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.startDatePicker = [[UIDatePicker  alloc]init];
    self.startDatePicker.datePickerMode = UIDatePickerModeTime;
    self.startDatePicker.minuteInterval = 15;
    
    [self resetPickerTime];
    
    [self.startDatePicker addTarget:self action:@selector(startDatePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStylePlain target:self action:@selector(datePickerDonePressed)];
    
    toolBar.barTintColor = [UIColor colorWithRed:0.820f green:0.835f blue:0.859f alpha:1.00f];
    
    toolBar.items = [[NSArray alloc] initWithObjects:barButtonDone,nil];
    barButtonDone.tintColor=[UIColor blackColor];
    
    
    UIView *pickerParentView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, 320, 216)];
    [pickerParentView addSubview:self.startDatePicker];
    [pickerParentView addSubview:toolBar];
    self.scheduleOpenTimeTextField.inputView = pickerParentView;
    self.scheduleCloseTimeTextField.inputView = pickerParentView;
    self.overrideCloseTimeTextField.inputView = pickerParentView;
    
    
    self.scheduleOpenTimeTextField.delegate = self;
    self.scheduleCloseTimeTextField.delegate = self;
    self.overrideCloseTimeTextField.delegate = self;
    
    self.previousSegment = [HelperMethods getWeekday];
    [self.dayOfTheWeekSegmentedControl setSelectedSegmentIndex:[HelperMethods getWeekday]];
    [self reloadScheduleComponentsWithDay:[HelperMethods getWeekday]];
    
    /*
    if(self.userData.overrideSchedule)
       [self.overrideScheduleSwitch setOn:YES];
    else
        [self.overrideScheduleSwitch setOn:NO];
    
    [self overrideSchduleSwitchChanged:self.overrideScheduleSwitch];
    */
    
    self.changesMade = NO;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Edit_Schedule_Screen_Loaded" parameters:nil];
}

#pragma mark - IBActions

- (IBAction)openCloseSwitchChanged:(UISwitch *)sender {
    
    self.changesMade = YES;
    
    if(sender.isOn)
    {
        self.openCloseLabel.text = @"Open";
        self.overrideLocationTextField.enabled = YES;
        self.overrideCloseTimeTextField.enabled = YES;
    }
    else
    {
        self.openCloseLabel.text = @"Closed";
        self.overrideLocationTextField.text = @"";
        self.overrideLocationTextField.enabled = NO;
        self.overrideLocationSelected = 0;
        self.overrideCloseTimeTextField.text = @"";
        self.overrideCloseTimeTextField.enabled = NO;
    }
}

- (IBAction)overrideSchduleSwitchChanged:(UISwitch *)sender {
    
    self.changesMade = YES;
    
    if(sender.isOn)
    {
        /*
        self.overrideView.hidden = NO;
        self.saveChangesTopConstraint.constant = 142;
        if(self.userData.overrideSchedule[@"closeTime"])
            self.overrideCloseTimeTextField.text = self.userData.overrideSchedule[@"closeTime"];
        if(self.userData.overrideSchedule[@"locationName"])
            self.overrideLocationTextField.text = self.userData.overrideSchedule[@"locationName"];
        if(self.userData.overrideSchedule[@"isOpen"])
            [self.openClosedSwitch setOn:[self.userData.overrideSchedule[@"isOpen"]boolValue]];
        [self openCloseSwitchChanged:self.openClosedSwitch];
        
        [self.view layoutIfNeeded];
         */
    }
    else
    {
        
        self.overrideView.hidden = YES;
        self.saveChangesTopConstraint.constant = 0;
        [self.view layoutIfNeeded];
        
        self.overrideLocationTextField.text = @"";
        self.overrideLocationSelected = 0;
        /*[self.userData removeOverrideSchedule];*/
        
    }
    
}

- (IBAction)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)weekdaySegmentedControlChanged:(UISegmentedControl *)sender {
    if(self.changesMade && self.scheduleSelectLocationTextfield.text.length > 0 && self.scheduleOpenTimeTextField.text.length > 0 && self.scheduleCloseTimeTextField.text.length > 0)
    {
        
        // ask the user if they want to save
       [self saveScheduleToFireBaseForDay:[NSString stringWithFormat:@"%ld", (long)self.previousSegment]];
    }
    
    [self reloadScheduleComponentsWithDay:sender.selectedSegmentIndex];
    self.previousSegment = sender.selectedSegmentIndex;
    
}
- (IBAction)locationClearButtonPressed:(UIButton *)sender {
    
    self.scheduleSelectLocationTextfield.text = @"";
    self.scheduleLocationSelected = 0;
    sender.hidden = YES;
}

- (IBAction)clearButtonPressed:(UIButton *)sender {
    
    self.scheduleOpenTimeTextField.text = @"";
    self.scheduleCloseTimeTextField.text = @"";
    
}

- (IBAction)saveChangesButtonPressed:(UIButton *)sender {

    [self resetPickerTime];
    
    if([sender.titleLabel.text isEqualToString:@"Clear Day"])
    {
        self.saveChangesButton.enabled = NO;
        self.scheduleCloseTimeTextField.text = @"";
        self.scheduleOpenTimeTextField.text = @"";
        self.scheduleLocationSelected = 0;
        self.scheduleSelectLocationTextfield.text = @"";
        
        self.saveStatusLabel.text = [NSString stringWithFormat:@"%@ Schedule Removed", [HelperMethods getWeekdayName:self.previousSegment]];
        [self.userData removeScheduleForDay:[NSString stringWithFormat:@"%ld", (long)self.dayOfTheWeekSegmentedControl.selectedSegmentIndex]];
        [self.saveChangesButton setTitle:@"Save Changes" forState:UIControlStateNormal];
        
    }
    else
        [self saveScheduleToFireBaseForDay:[NSString stringWithFormat:@"%ld", (long)self.dayOfTheWeekSegmentedControl.selectedSegmentIndex]];
    
}
#pragma mark - Methods

- (BOOL)isTimePM:(NSString *)time
{
    NSArray *timeArray1 = [time componentsSeparatedByString:@":"];
    NSString *value1AMPM = [timeArray1[1] substringFromIndex:2];
    
    if([value1AMPM isEqualToString:@"pm"])
        return YES;
    else
        return NO;
    
}

- (BOOL)compareTimesIsValue1:(NSString *)value1 beforeValue2:(NSString *)value2
{
    //value1 10:00am value2 2:00pm
    
    NSArray *timeArray1 = [value1 componentsSeparatedByString:@":"];
    NSString *value1AMPM = [timeArray1[1] substringFromIndex:2];
    int value1Hour = [timeArray1[0] intValue];
    int value1Min = [[timeArray1[1] substringToIndex:2]intValue];
    
    NSArray *timeArray2 = [value2 componentsSeparatedByString:@":"];
    NSString *value2AMPM = [timeArray2[1] substringFromIndex:2];
    int value2Hour = [timeArray2[0] intValue];
    int value2Min = [[timeArray2[1] substringToIndex:2]intValue];
    
    
    if([value1AMPM isEqualToString:@"pm"])
        if(value1Hour < 12)
            value1Hour += 12;
    if([value2AMPM isEqualToString:@"pm"])
        if(value2Hour < 12)
            value2Hour += 12;
    
    if(value1Hour <= value2Hour)
    {
        if(value1Hour == value2Hour)
        {
            if(value1Min <= value2Min)
            {
                if(value1Min == value2Min)
                {
                    return NO;
                }
                else
                    return YES;
            }
            return NO;
            
        }
        else
            return YES;
    }
    else
        return NO;
        
    
    return NO;
    
}

- (void)resetPickerTime
{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:today];
    [weekdayComponents setHour:07];
    [weekdayComponents setMinute:00];
    
    NSDate *newDate = [gregorian dateFromComponents:weekdayComponents];
    [self.startDatePicker setDate:newDate];
}

- (void)setPickerTotime:(NSString *)time
{
    NSArray *timeArray1 = [time componentsSeparatedByString:@":"];
    NSString *value1AMPM = [timeArray1[1] substringFromIndex:2];
    int value1Hour = [timeArray1[0] intValue];
    int value1Min = [[timeArray1[1] substringToIndex:2]intValue];
    
    if([value1AMPM isEqualToString:@"pm"])
        value1Hour += 12;
    
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:today];
    [weekdayComponents setHour:value1Hour];
    [weekdayComponents setMinute:value1Min];
    
    NSDate *newDate = [gregorian dateFromComponents:weekdayComponents];
    [self.startDatePicker setDate:newDate animated:YES];
}

- (void)datePickerDonePressed
{
    if(self.scheduleOpenTimeTextField.text.length > 0)
    {
        if(self.scheduleCloseTimeTextField.text.length > 0)
        {
            if([self compareTimesIsValue1:self.scheduleOpenTimeTextField.text beforeValue2:self.scheduleCloseTimeTextField.text])
            {
                self.openTimeIsGood = YES;
                self.scheduleOpenTimeTextField.textColor = [UIColor blackColor];
            }
            else
            {
                self.openTimeIsGood = NO;
                self.scheduleOpenTimeTextField.textColor = [UIColor redColor];
            }
        }
        else
        {
            self.openTimeIsGood = YES;
            self.scheduleOpenTimeTextField.textColor = [UIColor blackColor];
        }
    }
    
    if(self.scheduleCloseTimeTextField.text.length > 0)
    {
        if(self.scheduleOpenTimeTextField.text.length > 0)
        {
            if([self isTimePM:self.scheduleOpenTimeTextField.text])
            {
                if([self isTimePM:self.scheduleCloseTimeTextField.text])
                {
                    if([self compareTimesIsValue1:self.scheduleOpenTimeTextField.text beforeValue2:self.scheduleCloseTimeTextField.text])
                    {
                        self.closeTimeIsGood = YES;
                        self.scheduleCloseTimeTextField.textColor = [UIColor blackColor];
                    }
                    else
                    {
                        self.closeTimeIsGood = NO;
                        self.scheduleCloseTimeTextField.textColor = [UIColor redColor];
                    }
                }
                else
                {
                    self.closeTimeIsGood = NO;
                    self.scheduleCloseTimeTextField.textColor = [UIColor redColor];
                }
            }
            else
            {
                if([self compareTimesIsValue1:self.scheduleOpenTimeTextField.text beforeValue2:self.scheduleCloseTimeTextField.text])
                {
                    self.closeTimeIsGood = YES;
                    self.scheduleCloseTimeTextField.textColor = [UIColor blackColor];
                }
                else
                {
                    self.closeTimeIsGood = NO;
                    self.scheduleCloseTimeTextField.textColor = [UIColor redColor];
                }
            }
        }
        else
        {
            self.closeTimeIsGood = YES;
            self.scheduleCloseTimeTextField.textColor = [UIColor blackColor];
        }
    }
    
    
    [self resetPickerTime];
    
    [self hideKeyboard];
}

- (void)saveScheduleToFireBaseForDay:(NSString *)day
{
    self.saveChangesButton.enabled = NO;
    
    self.saveStatusLabel.text = [NSString stringWithFormat:@"%@ Schedule Saved", [HelperMethods getWeekdayName:self.previousSegment]];
    
   /* if(self.overrideScheduleSwitch.isOn)
    {
        NSString *locationName;
        NSString *locationID;
        if(self.openClosedSwitch.isOn)
        {
            locationName = [[self.userData.farmLocations objectAtIndex:self.overrideLocationSelected] objectForKey:@"locationName"];
            locationID = [[self.userData.farmLocations objectAtIndex:self.overrideLocationSelected] objectForKey:@"locationID"];
        }
        else
        {
            locationName = @"";
            locationID = @"";
        }
        
        NSDictionary *overrideData = @{
                                       @"locationName" : locationName,
                                       @"locationID" : [[self.userData.farmLocations objectAtIndex:self.overrideLocationSelected] objectForKey:@"locationID"],
                                       @"closeTime" : self.overrideCloseTimeTextField.text,
                                       @"overrideDate" : [NSString stringWithFormat:@"%@", [NSDate date]],
                                       @"isOpen" : [NSString stringWithFormat:@"%i", self.openClosedSwitch.isOn]
                                       
                                       };
        
        [self.userData addOverideSchedule:overrideData];
    }*/
    
    if(self.scheduleOpenTimeTextField.text.length > 0 && self.openTimeIsGood)
    {
        if(self.scheduleCloseTimeTextField.text.length > 0 && self.closeTimeIsGood)
        {
            if(self.scheduleSelectLocationTextfield.text > 0)
            {
                NSDictionary *scheduleData = @{
                                               day : @{
                                                       @"locationID":[[self.userData.farmLocations objectAtIndex:self.scheduleLocationSelected] objectForKey:@"locationID"],
                                                       @"openTime" : self.scheduleOpenTimeTextField.text,
                                                       @"closeTime" : self.scheduleCloseTimeTextField.text,
                                                       @"locationName" : [[self.userData.farmLocations objectAtIndex:self.scheduleLocationSelected] objectForKey:@"locationName"]
                                                       }
                                               };
                
                [self.userData addScheudle:scheduleData];
                
                [self.saveChangesButton setTitle:@"Clear Day" forState:UIControlStateNormal];
                self.saveChangesButton.enabled = YES;

            }
            else
            {
                self.saveChangesButton.enabled = YES;
                [self presentViewController: [UIView createSimpleAlertWithMessage:@"A location must be selected."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
            }
        }
        else
        {
            self.saveChangesButton.enabled = YES;
            [self presentViewController: [UIView createSimpleAlertWithMessage:@"Schedule close time is invalid."andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
        }
    }
    else
    {
        self.saveChangesButton.enabled = YES;
        [self presentViewController: [UIView createSimpleAlertWithMessage:@"Schedule open time is invalid"andTitle:@"Error!" withOkButton:NO] animated: YES completion: nil];
    }
}

- (void)reloadScheduleComponentsWithDay:(NSInteger)index
 {
     self.scheduleCloseTimeTextField.text = @"";
     self.scheduleOpenTimeTextField.text = @"";
     self.scheduleSelectLocationTextfield.text = @"";
     
     NSString *indexString = [NSString stringWithFormat:@"%ld", (long)index];
     
     if([self.userData.mySchedule objectForKey:indexString])
     {
         self.scheduleSelectLocationTextfield.text = [[self.userData.mySchedule objectForKey:indexString] objectForKey:@"locationName"];
         self.scheduleOpenTimeTextField.text = [[self.userData.mySchedule objectForKey:indexString] objectForKey:@"openTime"];
         self.scheduleCloseTimeTextField.text = [[self.userData.mySchedule objectForKey:indexString] objectForKey:@"closeTime"];
         for(int i = 0; i < self.userData.farmLocations.count; i++)
         {
             NSDictionary *dic = [self.userData.farmLocations objectAtIndex:i];
             if([dic[@"locationID"] isEqualToString:[[self.userData.mySchedule objectForKey:indexString] objectForKey:@"locationID"]])
             {
                 self.scheduleLocationSelected = i;
                 break;
             }
                 
         }
         
         [self.saveChangesButton setTitle:@"Clear Day" forState:UIControlStateNormal];
         self.saveChangesButton.enabled = YES;
                                                      
     }
     else
     {
         [self.saveChangesButton setTitle:@"Save Changes" forState:UIControlStateNormal];
         self.saveChangesButton.enabled = NO;
     }
 }
     
- (NSString *)formatDate:(NSDate *)date
{
    
    return [self.dateFormatter stringFromDate:date];
}

- (NSString *)convertDate:(NSString *)date
{
    
    //NSLog(@"%@", date);
    NSArray *startTimeArray = [HelperMethods getDateArrayFromString:date];
    startTimeArray = [HelperMethods ConvertHourUsingDateArray:startTimeArray];
    
    int minutes = [startTimeArray[4] intValue];
    NSString *minutesString = startTimeArray[4];
    
    if(minutes > 45)
        minutesString = @"00";
    else if(minutes > 30 && minutes < 45)
        minutesString = @"45";
    else if(minutes > 15 && minutes < 30)
        minutesString = @"30";
    else if(minutes > 0 && minutes < 15)
        minutesString = @"15";
    
    return [NSString stringWithFormat:@"%@:%@%@", startTimeArray[3], minutesString, startTimeArray[5]];
    
}


- (void)startDatePickerValueChanged
{
    self.changesMade = YES;
    if([self.saveChangesButton.titleLabel.text isEqualToString:@"Clear Day"])
        [self.saveChangesButton setTitle:@"Save Changes" forState:UIControlStateNormal];
    
    NSString *timeText = [self convertDate:[self formatDate:self.startDatePicker.date]];
    //NSMutableDictionary *tempDic = [[self.days objectAtIndex:self.selectDaySegmentedControl.selectedSegmentIndex]mutableCopy];
    
   // NSMutableArray *tempArray = [[tempDic objectForKey:@"schedule"]mutableCopy];
    
    NSMutableDictionary *tempSchedule;
    
    if(self.scheduleOpenTimeTextField.isFirstResponder)
    {
        self.scheduleOpenTimeTextField.text = timeText;
        //tempSchedule = [[tempArray objectAtIndex:0]mutableCopy];
        [tempSchedule setValue:timeText forKey:@"startTime"];
        //[tempArray replaceObjectAtIndex:0 withObject:tempSchedule];
        self.scheduleTimeClearButton.hidden = false;
    }
    else if(self.scheduleCloseTimeTextField.isFirstResponder)
    {
        self.scheduleCloseTimeTextField.text = timeText;
        //tempSchedule = [[tempArray objectAtIndex:1]mutableCopy];
        [tempSchedule setValue:timeText forKey:@"startTime"];
        //[tempArray replaceObjectAtIndex:1 withObject:tempSchedule];
        self.scheduleTimeClearButton.hidden = false;
    }
    else if(self.overrideCloseTimeTextField.isFirstResponder)
    {
        self.overrideCloseTimeTextField.text = timeText;
        //tempSchedule = [[tempArray objectAtIndex:0]mutableCopy];
        [tempSchedule setValue:timeText forKey:@"endTime"];
        //[tempArray replaceObjectAtIndex:0 withObject:tempSchedule];
        
    }
    
    
    
    
   // [tempDic setValue:tempArray forKey:@"schedule"];
    //[self.days replaceObjectAtIndex:self.selectDaySegmentedControl.selectedSegmentIndex withObject:tempDic];
    
    
    
}


-(void)hideKeyboard
{
    
    [self.scheduleSelectLocationTextfield resignFirstResponder];
    [self.scheduleOpenTimeTextField resignFirstResponder];
    [self.scheduleCloseTimeTextField resignFirstResponder];
    [self.overrideLocationTextField resignFirstResponder];
    [self.overrideCloseTimeTextField resignFirstResponder];
    
}

#pragma mark - Delegate Methods

- (void)farmerProfileUpdated
{
    
   
    
    
    [UIView animateWithDuration:1.0 animations:^{
        self.saveStatusLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.saveStatusLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.changesMade = NO;
        }];
    }];
    
    
}

#pragma mark - UITextField Delegate

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    self.changesMade = YES;
    if([self.saveChangesButton.titleLabel.text isEqualToString:@"Clear Day"])
        [self.saveChangesButton setTitle:@"Save Changes" forState:UIControlStateNormal];
    if(self.scheduleSelectLocationTextfield.isFirstResponder)
    {
        if([self.scheduleSelectLocationTextfield.text isEqualToString:@""])
        {
            self.scheduleSelectLocationTextfield.text = [[self.userData.farmLocations objectAtIndex:0] objectForKey:@"locationName"];
            self.scheduleLocationSelected = 0;
            self.locationClearButton.hidden = NO;
        }
    }
    else if(self.overrideLocationTextField.isFirstResponder)
    {
        if([self.overrideLocationTextField.text isEqualToString:@""])
        {
            self.overrideLocationTextField.text = [[self.userData.farmLocations objectAtIndex:0] objectForKey:@"locationName"];
            self.overrideLocationSelected = 0;
        }
    }
    else if(self.scheduleOpenTimeTextField.isFirstResponder)
    {
        if([self.scheduleOpenTimeTextField.text isEqualToString:@""])
            textField.text = [self convertDate:[self formatDate:self.startDatePicker.date]];
        else
            [self setPickerTotime:self.scheduleOpenTimeTextField.text];
    }
    else if(self.scheduleCloseTimeTextField.isFirstResponder)
    {
        if([self.scheduleCloseTimeTextField.text isEqualToString:@""])
            textField.text = [self convertDate:[self formatDate:self.startDatePicker.date]];
        else
            [self setPickerTotime:self.scheduleCloseTimeTextField.text];
    }
    else if(self.overrideCloseTimeTextField.isFirstResponder)
    {
        if([self.overrideCloseTimeTextField.text isEqualToString:@""])
            textField.text = [self convertDate:[self formatDate:self.startDatePicker.date]];
    }
    
    if(textField.tag >= 10)
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
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag >= 10)
    {
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y += self.animatedDistance;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        [UIView commitAnimations];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.changesMade = YES;
    if([self.saveChangesButton.titleLabel.text isEqualToString:@"Clear Day"])
        [self.saveChangesButton setTitle:@"Save Changes" forState:UIControlStateNormal];
    return YES;
}


#pragma mark - PickerView Delegate

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerScheduleLocations || pickerView.tag == zPickerOverrideLocations)
        return self.userData.farmLocations.count;
    else
        return 0;
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerScheduleLocations || pickerView.tag == zPickerOverrideLocations)
        return [[self.userData.farmLocations objectAtIndex:row] objectForKey:@"locationName"];
    else
        return @"";
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.changesMade = YES;
    if([self.saveChangesButton.titleLabel.text isEqualToString:@"Clear Day"])
        [self.saveChangesButton setTitle:@"Save Changes" forState:UIControlStateNormal];
    
    if(pickerView.tag == zPickerScheduleLocations)
    {
        self.scheduleSelectLocationTextfield.text = [[self.userData.farmLocations objectAtIndex:row] objectForKey:@"locationName"];
        self.scheduleLocationSelected = row;
    }
    else if(pickerView.tag == zPickerOverrideLocations)
    {
        self.overrideLocationTextField.text = [[self.userData.farmLocations objectAtIndex:row] objectForKey:@"locationName"];
        self.overrideLocationSelected = row;
    }
    
    
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

