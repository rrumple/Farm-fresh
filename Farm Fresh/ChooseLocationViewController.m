//
//  ChooseLocationViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/20/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "ChooseLocationViewController.h"
#import <Mapkit/Mapkit.h>
#import <CoreLocation/CoreLocation.h>
#import "AZDraggableAnnotationView.h"
#import "UIView+AddOns.h"

@interface ChooseLocationViewController () <MKMapViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate, UIGestureRecognizerDelegate, AZDraggableAnnotationViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *mapSearchBar;
@property (weak, nonatomic) IBOutlet UIButton *saveAddButton;
@property (weak, nonatomic) IBOutlet UIView *farmNameView;
@property (weak, nonatomic) IBOutlet UITextField *locationNameTextfield;
@property (weak, nonatomic) IBOutlet UIView *serachResultsView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *addUpdateLocationbutton;
@property (nonatomic) CLLocationCoordinate2D userCoordinate;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL oneTime;
@property (nonatomic, strong) NSString *fullAddress;
@property (nonatomic, assign) MKCoordinateRegion boundingRegion;
@property (nonatomic, strong) MKPointAnnotation *annotation;
@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchResultsHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchResultsHeightConstraint2;
@property (nonatomic) BOOL firstLoad;

@end

@implementation ChooseLocationViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    self.mapSearchBar.delegate = self;
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.oneTime = false;
    
    if(self.isChoosingAFilterLocation)
       [self.saveAddButton setTitle:@"Set" forState:UIControlStateNormal];
    if(self.isEditingLocation)
    {
        self.titleLabel.text = @"Edit Location";
        self.mapSearchBar.text = self.location[@"fullAddress"];
        [self startSearch:self.mapSearchBar.text];
        self.firstLoad = YES;
       
        
    }
    else if(!self.isEditingLocation && !self.isChoosingAFilterLocation)
        self.firstLoad = YES;
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    [self.locationManager requestWhenInUseAuthorization];
    
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [self.mapView addGestureRecognizer:singleTapRecognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] init];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    
    // In order to pass double-taps to the underlying MKMapView the delegate
    // for this recognizer (self) needs to return YES from
    // gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:
    doubleTapRecognizer.delegate = self;
    [self.mapView addGestureRecognizer:doubleTapRecognizer];
    
    
    // This delays the single-tap recognizer slightly and ensures that it
    // will _not_ fire if there is a double-tap
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    [FIRAnalytics logEventWithName:@"Choose_Location_Screen_Loaded" parameters:@{
                                                                                 @"Choosing_a_Filter_Location" : [NSString stringWithFormat:@"%i", self.isChoosingAFilterLocation],
                                                                                 @"Is_Editing_A_Location" : [NSString stringWithFormat:@"%i", self.isEditingLocation]
                                                                                 }];
}

#pragma mark - IBActions

- (IBAction)addLocationButtonPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    
    if(self.locationNameTextfield.text.length > 0)
        [self addLocationToUserData];
    else
    {
        [self presentViewController: [UIView createSimpleAlertWithMessage:@"The location must have a name."andTitle:@"Add Location" withOkButton:NO] animated: YES completion: nil];
        sender.enabled = YES;
    }
}

- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveAddButtonPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    
    if(self.isChoosingAFilterLocation)
    {
        CLLocation *coords = [[CLLocation alloc] initWithLatitude:self.annotation.coordinate.latitude longitude:self.annotation.coordinate.longitude];
        
        NSLog(@"%@",coords.description);
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", coords.coordinate.latitude] forKey:@"manualLat"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", coords.coordinate.longitude] forKey:@"manualLong"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:self.fullAddress forKey:@"filterLocationName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(self.isEditingLocation)
    {
        [self.addUpdateLocationbutton setImage:[UIImage imageNamed:@"editLocation2"] forState:UIControlStateNormal];
        self.locationNameTextfield.text = self.location[@"locationName"];
        self.farmNameView.hidden = false;
    }
    else
        self.farmNameView.hidden = false;
}


- (IBAction)gotoUserButtonPressed:(UIButton *)sender {
    
    MKCoordinateRegion mapRegion;
    mapRegion.center = self.mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.05;
    mapRegion.span.longitudeDelta = 0.05;
    
    [self.mapView setRegion:mapRegion animated: YES];
}

#pragma mark - Methods

-(NSString *)getAddressString:(MKMapItem *)mapItem
{
    NSString *label11;
    NSString *label12;
    
    
    if(mapItem.placemark.subThoroughfare)
        label11 = mapItem.placemark.subThoroughfare;
    else
        label11 = @"";
    
    if(mapItem.placemark.thoroughfare)
    {
        if(label11.length > 0)
            label12 = [NSString stringWithFormat:@" %@", mapItem.placemark.thoroughfare];
        else
            label12 = mapItem.placemark.thoroughfare;
    }
    else
        label12 = @"";
    
    return [NSString stringWithFormat:@"%@%@", label11, label12];

}

-(NSString *)getAddressLine2String:(MKMapItem *)mapItem
{
    NSString *label21;
    NSString *label22;
    NSString *label23;
    
    if(mapItem.placemark.locality)
        label21 = [NSString stringWithFormat:@"%@,",mapItem.placemark.locality];
    else
        label21 = @"";
    
    if(mapItem.placemark.administrativeArea)
    {
        
        if(label21.length > 0)
            label22 = [NSString stringWithFormat:@" %@", mapItem.placemark.administrativeArea];
        else
            label22 = mapItem.placemark.administrativeArea;
        
    }
    else
        label22 = @"";
    
    if(mapItem.placemark.postalCode)
    {
        
        if(label22.length > 0 || label21.length > 0)
            label23 = [NSString stringWithFormat:@" %@", mapItem.placemark.postalCode];
        else
            label23 = mapItem.placemark.postalCode;
    }
    else
        label23 = @"";
    
    return [NSString stringWithFormat:@"%@%@%@", label21, label22, label23];
}


- (void)addLocationToUserData
{
    NSDictionary *locationDictionary = @{
                                         @"fullAddress" : self.fullAddress,
                                         @"locationName" : self.locationNameTextfield.text,
                                         @"farmerID" : self.userData.user.uid,
                                         @"latitude" : [NSString stringWithFormat:@"%f",self.annotation.coordinate.latitude],
                                         @"longitude" : [NSString stringWithFormat:@"%f", self.annotation.coordinate.longitude]
                                         };
    
    CLLocation *coords = [[CLLocation alloc] initWithLatitude:self.annotation.coordinate.latitude longitude:self.annotation.coordinate.longitude];
    
    if(self.isEditingLocation)
        [self.userData updateAFarmLocation:self.location[@"locationID"] withData:locationDictionary andCoords:coords];
    else
        [self.userData addLocationToFarm:locationDictionary withCoords:coords];
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)moveAnnotationToCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self.annotation) {
        [UIView beginAnimations:[NSString stringWithFormat:@"slideannotation%@", self.annotation] context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.2];
        
        self.annotation.coordinate = coordinate;
        
        [UIView commitAnimations];
    } else {
        self.annotation = [[MKPointAnnotation alloc] init];
        self.annotation.coordinate = coordinate;
        
        [self.mapView addAnnotation:self.annotation];
    }
    
    
    
    MKCoordinateRegion mapRegion;
    mapRegion.center = self.annotation.coordinate;
    mapRegion.span.latitudeDelta = 0.05;
    mapRegion.span.longitudeDelta = 0.05;
    
    [self.mapView setRegion:mapRegion animated: YES];
    
}

- (void)startSearch:(NSString *)searchString {
    if (self.localSearch.searching)
    {
        [self.localSearch cancel];
    }
    
    // Confine the map search area to the user's current location.
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = self.userCoordinate.latitude;
    newRegion.center.longitude = self.userCoordinate.longitude;
    
    // Setup the area spanned by the map region:
    // We use the delta values to indicate the desired zoom level of the map,
    //      (smaller delta values corresponding to a higher zoom level).
    //      The numbers used here correspond to a roughly 8 mi
    //      diameter area.
    //
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    request.naturalLanguageQuery = searchString;
    request.region = newRegion;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error) {
        if (error != nil) {
            
        } else {
            self.searchResults = [response mapItems];
            
            // Used for later when setting the map's region in "prepareForSegue".
            self.boundingRegion = response.boundingRegion;
            
            //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
            /*if(self.isEditingLocation && self.firstLoad)
            {
               [self tableView:self.searchTableView didSelectRowAtIndexPath:indexPath];
                self.firstLoad = NO;
            }*/
            
            [self.searchTableView reloadData];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    if (self.localSearch != nil) {
        self.localSearch = nil;
    }
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [self.localSearch startWithCompletionHandler:completionHandler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressCell" forIndexPath:indexPath];
    
    MKMapItem *mapItem = [self.searchResults objectAtIndex:indexPath.row];
  
    
    cell.textLabel.text = [self getAddressString:mapItem];
    cell.detailTextLabel.text = [self getAddressLine2String:mapItem];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.searchResults.count > 0)
    {
        MKMapItem *mapItem = self.searchResults[indexPath.row];
        
        [self.locationManager stopUpdatingLocation]; // We only want one update.
        
        //self.locationManager.delegate = nil;
        
        [self.mapView setRegion:self.boundingRegion animated:YES];
        
        
        self.fullAddress = [NSString stringWithFormat:@"%@ %@", [self getAddressString:mapItem], [self getAddressLine2String:mapItem]];
        
        
        
        [self moveAnnotationToCoordinate:mapItem.placemark.location.coordinate];
        
        // We have only one annotation, select it's callout.
        //[self.testMapView selectAnnotation:[self.testMapView.annotations objectAtIndex:0] animated:YES];
        
        [self.mapSearchBar resignFirstResponder];
        
        MKCoordinateRegion mapRegion;
        mapRegion.center = mapItem.placemark.location.coordinate;
        mapRegion.span.latitudeDelta = 0.05;
        mapRegion.span.longitudeDelta = 0.05;
        
        [self.mapView setRegion:mapRegion animated: YES];
        
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if(!self.isEditingLocation)
        [self startSearch:[NSString stringWithFormat:@"%f,%f", self.userCoordinate.longitude, self.userCoordinate.latitude]];    // Remember for later the user's current location.
    CLLocation *userLocation = locations.lastObject;
    self.userCoordinate = userLocation.coordinate;
    
    [manager stopUpdatingLocation]; // We only want one update.
    
    manager.delegate = nil;         // We might be called again here, even though we
    // called "stopUpdatingLocation", so remove us as the delegate to be sure.
    
    if(!self.isEditingLocation)
    {
        if(self.firstLoad)
        {
            self.firstLoad = NO;
            [self moveAnnotationToCoordinate:self.userCoordinate];
            [self movedAnnotation:self.annotation];
        }
        else
            [self startSearch:self.mapSearchBar.text];
    }
    else
    {
         [self startSearch:[NSString stringWithFormat:@"%@,%@", self.location[@"longitude"], self.location[@"latitude"]]];
       
        CLLocationCoordinate2D coords = CLLocationCoordinate2DMake([self.location[@"latitude"] floatValue], [self.location[@"longitude"] floatValue]);
        
        [self moveAnnotationToCoordinate:coords];
        [self movedAnnotation:self.annotation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // report any errors returned back from Location Services
}

#pragma mark MKMapViewDelegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(!self.oneTime)
    {
        MKCoordinateRegion mapRegion;
        mapRegion.center = mapView.userLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.01;
        mapRegion.span.longitudeDelta = 0.01;
        
        if(!self.isEditingLocation)
            [mapView setRegion:mapRegion animated: YES];
        self.oneTime = true;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)anno
{
    if ([anno isKindOfClass:[MKUserLocation class]] || self.isChoosingAFilterLocation)
        return nil;
    

    MKAnnotationView *annotationView = [mv dequeueReusableAnnotationViewWithIdentifier:@"DraggableAnnotationView"];
    
    if (!annotationView) {
        annotationView = [[AZDraggableAnnotationView alloc] initWithAnnotation:anno reuseIdentifier:@"DraggableAnnotationView"];
    }
    
    ((AZDraggableAnnotationView *)annotationView).delegate = self;
    ((AZDraggableAnnotationView *)annotationView).mapView = self.mapView;
    
    return annotationView;
}

#pragma mark UIGestureRecognizerDelegate methods

/**
 Asks the delegate if two gesture recognizers should be allowed to recognize gestures simultaneously.
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // Returning YES ensures that double-tap gestures propogate to the MKMapView
    return YES;
}

#pragma mark UIGestureRecognizer handlers

- (void)handleSingleTapGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
    {
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    [self moveAnnotationToCoordinate:[self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView]];
    [self movedAnnotation:self.annotation];
}

#pragma mark AZDraggableAnnotationView delegate

- (void)movedAnnotation:(MKPointAnnotation *)anno
{
    NSLog(@"Dragged annotation to %f,%f", anno.coordinate.latitude, anno.coordinate.longitude);
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:anno.coordinate.latitude longitude:anno.coordinate.longitude]; //insert your coordinates
    
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  MKPlacemark *placemark = [placemarks objectAtIndex:0];
                  MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:placemark];
                  self.fullAddress = [NSString stringWithFormat:@"%@ %@", [self getAddressString:mapItem], [self getAddressLine2String:mapItem]];
                  
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      self.mapSearchBar.text = self.fullAddress;
                      
                      MKCoordinateRegion mapRegion;
                      mapRegion.center = self.annotation.coordinate;
                      mapRegion.span.latitudeDelta = 0.01;
                      mapRegion.span.longitudeDelta = 0.01;
                      
                      [self.mapView setRegion:mapRegion animated: YES];
                      
                  });
                  
              }
     
     ];
}

#pragma mark - Search Bar Delegate Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBarRightConstraint.constant = 8;
     [searchBar setShowsCancelButton:YES animated:NO];
    [UIView animateWithDuration:.3 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if(finished)
        {
        self.serachResultsView.hidden = false;
        self.searchResultsHeightConstraint.constant = 207;
        self.searchResultsHeightConstraint2.constant = 207;
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        }
    }];
    
    
    
    
   
    NSMutableArray * annotationsToRemove = [ self.mapView.annotations mutableCopy ] ;
    [ annotationsToRemove removeObject:self.mapView.userLocation ] ;
    [ self.mapView removeAnnotations:annotationsToRemove ] ;
    self.annotation = nil;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    self.searchResultsHeightConstraint.constant = 10;
    self.searchResultsHeightConstraint2.constant = 10;
    
    [searchBar setShowsCancelButton:YES animated:NO];
    [UIView animateWithDuration:.5 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if(finished)
        {
        self.serachResultsView.hidden = true;
        self.searchBarRightConstraint.constant = 58;
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        }
    }];
    
    
    self.serachResultsView.hidden = true;
    self.searchBarRightConstraint.constant = 58;
    [searchBar setShowsCancelButton:NO animated:NO];
    [UIView animateWithDuration:.5 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    // Check if location services are available
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"%s: location services are not available.", __PRETTY_FUNCTION__);
        
        // Display alert to the user.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location services"
                                                                       message:@"Location services are not enabled on this device. Please enable location services in settings."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}]; // Do nothing action to dismiss the alert.
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    // Request "when in use" location service authorization.
    // If authorization has been denied previously, we can display an alert if the user has denied location services previously.
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"%s: location services authorization was previously denied by the user.", __PRETTY_FUNCTION__);
        
        // Display alert to the user.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location services"
                                                                       message:@"Location services were previously denied by the user. Please enable location services for this app in settings."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}]; // Do nothing action to dismiss the alert.
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    // Start updating locations.
    //self.locationManager.delegate = self;
    //[self.locationManager startUpdatingLocation];
    [self startSearch:searchBar.text];
    
    // When a location is delivered to the location manager delegate, the search will actually take place. See the -locationManager:didUpdateLocations: method.
}                  // called when keyboard search button pressed

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
   // self.locationManager.delegate = self;
    //[self.locationManager startUpdatingLocation];
    [self startSearch:searchText];
    
    // If the text changed, reset the tableview if it wasn't empty.
    if (self.searchResults.count != 0) {
        
        // Set the list of places to be empty.
        self.searchResults = @[];
        // Reload the tableview.
        [self.searchTableView reloadData];
        // Disable the "view all" button.
        
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
