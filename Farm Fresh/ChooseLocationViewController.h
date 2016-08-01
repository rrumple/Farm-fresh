//
//  ChooseLocationViewController.h
//  Farm Fresh
//
//  Created by Randall Rumple on 3/20/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface ChooseLocationViewController : UIViewController

@property (nonatomic, strong) UserModel *userData;
@property (nonatomic) BOOL isChoosingAFilterLocation;
@property (nonatomic) BOOL isEditingLocation;
@property (nonatomic, strong) NSDictionary *location;

@end
