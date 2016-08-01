//
//  CitiesReportViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 7/6/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "CitiesReportViewController.h"

@interface CitiesReportViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *citiesTableView;
@property (nonatomic, strong) NSMutableArray *cities;
@property (nonatomic) int searchCounter;
@property (nonatomic, strong) GFCircleQuery *circleQuery;
@end

@implementation CitiesReportViewController

-(NSMutableArray *)cities
{
    if(!_cities) _cities = [[NSMutableArray alloc]init];
    return _cities;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationController.navigationBarHidden = YES;
    self.searchCounter = 0;
    self.citiesTableView.delegate = self;
    self.citiesTableView.dataSource = self;
    
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:39.781365 longitude:-96.848032];
    
    self.circleQuery = [self.userData.geoFireCities queryAtLocation:loc withRadius:2500];
    
    [self.circleQuery observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        NSLog(@"Key '%@' entered the search area and is at location '%@'", key, location);
        
        self.searchCounter++;
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if(!error)
            {
                for (CLPlacemark * placemark in placemarks)
                {
                    NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
                    NSLog(@"placemark.country %@",placemark.country);
                    NSLog(@"placemark.postalCode %@",placemark.postalCode);
                    NSLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
                    NSLog(@"placemark.locality %@",placemark.locality);
                    NSLog(@"placemark.subLocality %@",placemark.subLocality);
                    NSLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);
                    
                    if(placemark.locality)
                    {
                        
                        [self.cities addObject:@{
                                                @"cityName" : [NSString stringWithFormat:@"%@, %@",placemark.locality, placemark.administrativeArea],
                                                @"cityCount" : @"0"
                                                }];
                        
                        [self checkSearchCounter];
                    }
                    
                }
                
            }
            else
            {
                [self checkSearchCounter];
                NSLog(@"failed getting city: %@", [error description]);
            }
        }];
        
        
        
        
     
        
        
        
    }];
    
    [self.circleQuery observeReadyWithBlock:^{
        NSLog(@"All initial data has been loaded and events have been fired!");
        
        //[self.citiesTableView reloadData];
        
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Cities_Report_Screen_Loaded" parameters:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - IBActions

- (IBAction)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Methods

- (void)checkSearchCounter
{
    self.searchCounter--;
    
    if(self.searchCounter == 0)
    {
        NSMutableArray *newCities = [[NSMutableArray alloc]init];
        
        NSArray *tempCities = self.cities;
        int cityCount = 0;
        for(NSDictionary *city in self.cities)
        {
            for(NSDictionary *city2 in tempCities)
            {
                if([city[@"cityName"] isEqualToString:city2[@"cityName"]])
                    cityCount++;
            }
            
            BOOL match = NO;
            
            for(NSDictionary *city3 in newCities)
            {
                if([city[@"cityName"] isEqualToString:city3[@"cityName"]])
                {
                    match = YES;
                    break;
                }
            }
            
            if(!match)
            {
                [newCities addObject:@{
                                      @"cityName" : city[@"cityName"],
                                      @"cityCount" : [NSString stringWithFormat:@"%i", cityCount]
                                      }];
            }
            
            cityCount = 0;
        }
        
        self.cities = newCities;
        
        
        [self.citiesTableView reloadData];
    }
    
}

#pragma mark - Delegate Methods

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.cities.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.cities objectAtIndex:indexPath.row] objectForKey:@"cityName"];
    cell.detailTextLabel.text = [[self.cities objectAtIndex:indexPath.row] objectForKey:@"cityCount"];
    
    
    
    return cell;
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
