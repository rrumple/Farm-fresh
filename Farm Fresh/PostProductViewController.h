//
//  PostProductViewController.h
//  Farm Fresh
//
//  Created by Randall Rumple on 3/23/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface PostProductViewController : UIViewController

@property (nonatomic, strong) UserModel *userData;
@property (nonatomic, strong) UIImage *menuImage;
@property (nonatomic) BOOL isFirstTimeSetup;
@property (nonatomic) BOOL isInEditMode;
@property (nonatomic, strong) NSDictionary *productToEdit;

@end
