//
//  ContactModel.h
//  School Intercom
//
//  Created by Randall Rumple on 1/2/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseRequest.h"

@interface ContactModel : NSObject

- (void)sendSupportTicketFrom:(NSString *)name withEmail:(NSString *)email withProblem:(NSString *)problem andMessage:(NSString *)message withDelegate:(id<DatabaseRequestDelegate>)delegate;

- (void)sendPDFToFarmer:(NSString *)name withEmail:(NSString *)email withFarmName:(NSString *)farmName withDelegate:(id<DatabaseRequestDelegate>)delegate;

@end
