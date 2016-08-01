//
//  CustomerReviewsViewController.h
//  Farm Fresh
//
//  Created by Randall Rumple on 3/23/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface CustomerReviewsViewController : UIViewController

@property (nonatomic, strong) UserModel *userData;
@property (nonatomic, strong) NSDictionary *farmerSelected;
@property (nonatomic) BOOL isViewingAlert;

@end
