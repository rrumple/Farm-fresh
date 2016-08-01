//
//  SetupCategoriesViewController.m
//  Farm Fresh
//
//  Created by Randall Rumple on 4/12/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "SetupCategoriesViewController.h"

@interface SetupCategoriesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *categories;
@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;

@end

@implementation SetupCategoriesViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.categoryTableView.delegate = self;
    self.categoryTableView.dataSource = self;
    
    [[self.userData.ref child:@"categories/"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        if (snapshot.value == [NSNull null]) {
            // The value is null
        }
        else
        {
            NSDictionary *value1 = snapshot.value;
            
            
            NSDictionary *categories = value1;
            NSArray *categoryKeys = categories.allKeys;
            
            NSMutableArray * newCategories = [[NSMutableArray alloc]init];
            
            
            for(NSString *string in categoryKeys)
            {
                [newCategories addObject:@{@"key" : string,
                                           @"categoryName" : [categories objectForKey:string]
                 
                 }];
                
            }
            
            
            NSSortDescriptor *categoryDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryName" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:categoryDescriptor];
            self.categories = [newCategories sortedArrayUsingDescriptors:sortDescriptors];
        
            
             NSLog(@"%@", self.categories);
            
            [self.categoryTableView reloadData];
            
        }
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FIRAnalytics logEventWithName:@"Setup_Categories_Screen_Loaded" parameters:nil];
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

- (IBAction)addCategoryButtonPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Category Name"
                                          message:@"Please enter a Category name, you will be notified if the entry already exists."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Category Name";
         [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   sender.enabled = YES;
                                   UITextField *category = alertController.textFields.firstObject;
                                   
                                   [[[self.userData.ref child:@"categories/"]childByAutoId] setValue:category.text];
                                   
                               }];
    
    [alertController addAction: okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Methods



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
 
 return self.categories.count;
 }


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell" forIndexPath:indexPath];
 
     cell.textLabel.text = [[self.categories objectAtIndex:indexPath.row] objectForKey:@"categoryName"];
     
     
 
 return cell;
 }



 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }



 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {

     [[self.userData.ref child:[NSString stringWithFormat:@"categories/%@", [[self.categories objectAtIndex:indexPath.row] objectForKey:@"key"]]] removeValue];
     
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


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
