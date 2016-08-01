//
//  FarmLocationsViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/20/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "FarmLocationsViewController.h"
#import "ChooseLocationViewController.h"
#import <Mapkit/Mapkit.h>
#import "MainMenuViewController.h"

@interface FarmLocationsViewController ()<UITableViewDataSource, UITableViewDelegate, UserModelDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *locationsTableView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) NSInteger locationToEdit;
@property (nonatomic) BOOL isEditing;

@end

@implementation FarmLocationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationsTableView.dataSource = self;
    self.locationsTableView.delegate = self;
    self.userData.delegate = self;
    
    
    if(self.isPickingALocation)
        self.titleLabel.text = @"Select a location for this product";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isEditing = NO;
    
    [self.locationsTableView reloadData];
}

#pragma mark - Life Cycle



#pragma mark - IBActions

- (IBAction)backButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addRowButtonPressed {
    
    [self performSegueWithIdentifier:@"chooseLocationSegue" sender:self];
}

#pragma mark - Methods

- (void)editLocation:(id)sender
{
    UIButton *theButton = (UIButton *)sender;
    UIView *myView = (UIView *)theButton.superview;
    
    UITableViewCell *cell = (UITableViewCell *)myView.superview;
    
    NSIndexPath *indexPath = [self.locationsTableView indexPathForCell:cell];
    
    self.isEditing = YES;
    self.locationToEdit = indexPath.section;
    
    [self performSegueWithIdentifier:@"chooseLocationSegue" sender:self];
    
}

- (void)deleteLocation:(id)sender
{
    UIButton *theButton = (UIButton *)sender;
    UIView *myView = (UIView *)theButton.superview;
    
    UITableViewCell *cell = (UITableViewCell *)myView.superview;
    
    NSIndexPath *indexPath = [self.locationsTableView indexPathForCell:cell];
    
    [self.userData removeLocationFromFarmer:[[self.userData.farmLocations objectAtIndex:indexPath.section] objectForKey:@"locationID"]];
}

#pragma mark - Delegate Methods

- (void)farmLocationsUpdated
{
    [self.locationsTableView reloadData];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view isKindOfClass:[UIButton class]])
    {
        return NO;
    }
    else
        return YES;
    
}

#pragma mark - MapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id<MKAnnotation>)annotation {
    
    MKAnnotationView *pinView = nil;
    static NSString *defaultPinID = @"pin";
    pinView = (MKAnnotationView *)
    [mV dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    
    pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    pinView.canShowCallout = NO;
    pinView.image = [UIImage imageNamed:@"farmHouse.png"];
    return pinView;
}

#pragma mark - TableView Delegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 174.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.layer.cornerRadius = 10;
    cell.layer.masksToBounds = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.userData.farmLocations.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *locationCellIdentifier = @"locationCell";
    
    UITableViewCell *cell;
    
    if(self.isPickingALocation)
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    else
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    NSDictionary *locationDictionary = [self.userData.farmLocations objectAtIndex:indexPath.section];
    
    cell = [tableView dequeueReusableCellWithIdentifier:locationCellIdentifier forIndexPath:indexPath];
    
    UILabel *locationNameLabel = (UILabel *)[cell viewWithTag:1];
    MKMapView *mapView = (MKMapView *)[cell viewWithTag:2];
    UILabel *fullAddressLabel = (UILabel *)[cell viewWithTag:3];
    
    locationNameLabel.text = locationDictionary[@"locationName"];
    fullAddressLabel.text = locationDictionary[@"fullAddress"];
    
    mapView.delegate = self;
    [mapView removeAnnotations:mapView.annotations];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
    annotation.coordinate= CLLocationCoordinate2DMake([locationDictionary[@"latitude"]floatValue], [locationDictionary[@"longitude"]floatValue]);
    
    MKCoordinateRegion mapRegion;
    mapRegion.center = annotation.coordinate;
    mapRegion.span.latitudeDelta = 0.008;
    mapRegion.span.longitudeDelta = 0.008;
    
    [mapView setRegion:mapRegion animated: NO];
    
    [mapView addAnnotation:annotation];
        
       
    UIButton * deleteButton = (UIButton *)[cell viewWithTag:5];
    
    [deleteButton addTarget:self action:@selector(deleteLocation:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *editButton = (UIButton *)[cell viewWithTag:4];
    
    [editButton addTarget:self action:@selector(editLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isPickingALocation)
    {
      
        
    }
}



#pragma mark - Navigation

 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
     if([segue.identifier isEqualToString:@"chooseLocationSegue"])
     {
         ChooseLocationViewController *clvc = segue.destinationViewController;
         
         clvc.userData = self.userData;
        
         if(self.isEditing)
         {
              clvc.isEditingLocation = self.isEditing;
             clvc.location = [self.userData.farmLocations objectAtIndex:self.locationToEdit];
         }
     }
 }



@end
