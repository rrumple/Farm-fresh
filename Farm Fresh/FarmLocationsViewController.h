//
//  FarmLocationsViewController.h
//  Farm Fresh
//
//  Created by Randall Rumple on 3/20/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface FarmLocationsViewController : UIViewController

@property (nonatomic, strong) UserModel *userData;
@property (nonatomic) BOOL isPickingALocation;
@property (nonatomic, strong) NSDictionary *productData;

@end
