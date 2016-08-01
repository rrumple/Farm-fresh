//
//  MainMenuViewController.h
//  Farm Fresh
//
//  Created by Randall Rumple on 3/9/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface MainMenuViewController : UITableViewController


@property (nonatomic, strong) UIImage *screenShotImage;
@property (nonatomic) BOOL moveImage;
@property (nonatomic, strong) UserModel *userData;
@end
