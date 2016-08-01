//
//  PostReviewViewController.h
//  Farm Fresh
//
//  Created by Randall Rumple on 5/30/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface PostReviewViewController : UIViewController

@property (nonatomic, strong) UserModel *userData;
@property (nonatomic, strong) NSDictionary *farmerSelected;


@end
