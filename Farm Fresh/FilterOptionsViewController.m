//
//  FilterOptionsViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 4/3/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "FilterOptionsViewController.h"
#import "ChooseLocationViewController.h"

@interface FilterOptionsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *sliderLabel;
@property (weak, nonatomic) IBOutlet UISlider *milesSlider;
@property (weak, nonatomic) IBOutlet UILabel *locationStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentAddressLabel;
@property (weak, nonatomic) IBOutlet UIButton *setLocationButton;
@property (weak, nonatomic) IBOutlet UISwitch *locationSwitch;

@end

@implementation FilterOptionsViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sliderLabel.text = [NSString stringWithFormat:@"%0.2f Miles", self.userData.getCurrentSearchRadius];
    [self.milesSlider setValue:self.userData.getCurrentSearchRadius animated:NO];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     [FIRAnalytics logEventWithName:@"Filter_Options_Screen_Loaded" parameters:nil];
    
    self.currentAddressLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"filterLocationName"];
    
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"isUsingGPSForSearches"]boolValue])
    {
        [self.locationSwitch setOn:YES];
        self.locationStatusLabel.text = @"Using GPS Location";
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"<%f,%f>", self.userData.userLocation.coordinate.latitude, self.userData.userLocation.coordinate.longitude] forKey:@"filterLocationName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        

        
        self.currentAddressLabel.text =  [[NSUserDefaults standardUserDefaults] objectForKey:@"filterLocationName"];
        self.setLocationButton.hidden = YES;
    }
    else
    {
        [self.locationSwitch setOn:NO];
        self.setLocationButton.hidden = false;
        self.locationStatusLabel.text = @"Using Manually Set Location";
    
        
        if(![[NSUserDefaults standardUserDefaults] objectForKey:@"manualLat"] && ![[NSUserDefaults standardUserDefaults] objectForKey:@"manualLong"])
            self.currentAddressLabel.text = @"Location Not Set";
        else
            self.currentAddressLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"filterLocationName"];
        
       
        
    }
}

#pragma mark - IBActions

- (IBAction)setLocationButtonPressed:(UIButton *)sender {
    
    [self.locationSwitch setOn:NO];
    self.setLocationButton.hidden = false;
    self.locationStatusLabel.text = @"Using Manually Set Location";
    
}

- (IBAction)locationOptionChanged:(UISwitch *)sender
{
    if(sender.isOn)
    {
        self.locationStatusLabel.text = @"Using GPS Location";
        [[NSUserDefaults standardUserDefaults]setValue:@"1" forKey:@"isUsingGPSForSearches"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"manualLat"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"manualLong"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"filterLocationName"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"<%f,%f>", self.userData.userLocation.coordinate.latitude, self.userData.userLocation.coordinate.longitude] forKey:@"filterLocationName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    
        
        self.setLocationButton.hidden = YES;
        self.currentAddressLabel.text =  [[NSUserDefaults standardUserDefaults] objectForKey:@"filterLocationName"];
    }
    else
    {
        self.locationStatusLabel.text = @"Using Manually Set Location";
        [[NSUserDefaults standardUserDefaults]setValue:@"0" forKey:@"isUsingGPSForSearches"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        self.setLocationButton.hidden = NO;
        if(![[NSUserDefaults standardUserDefaults] objectForKey:@"manualLat"] && ![[NSUserDefaults standardUserDefaults] objectForKey:@"manualLong"])
            self.currentAddressLabel.text = @"Location Not Set";
        else
            self.currentAddressLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"filterLocationName"];
        
    }
}

- (IBAction)sliderChanged:(UISlider *)sender {
    
    
    self.sliderLabel.text = [NSString stringWithFormat:@"%0.2f Miles", roundf(sender.value * 2.0) * .5];
    [sender setValue:roundf(sender.value * 2.0) * .5 animated:NO];
}

- (IBAction)saveButtonPressed:(UIButton *)sender {
    
    sender.enabled = false;
    
        [self.userData changeRadius:roundf(self.milesSlider.value * 2.0) * .5];
  
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Methods



#pragma mark - Delegate Methods



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"filterSetLocation"])
    {
        ChooseLocationViewController *clvc = segue.destinationViewController;
        
        clvc.userData = self.userData;
        clvc.isChoosingAFilterLocation = YES;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
