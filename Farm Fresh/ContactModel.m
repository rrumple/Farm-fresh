//
//  ContactModel.m
//  School Intercom
//
//  Created by Randall Rumple on 1/2/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "ContactModel.h"
#import "Constants.h"

@interface ContactModel()
@property (nonatomic, strong) DatabaseRequest *databaseRequest;
@end

@implementation ContactModel

-(DatabaseRequest *)databaseRequest
{
    if(!_databaseRequest) _databaseRequest = [[DatabaseRequest alloc]init];
    return _databaseRequest;
}

- (void)sendSupportTicketFrom:(NSString *)name withEmail:(NSString *)email withProblem:(NSString *)problem andMessage:(NSString *)message withDelegate:(id<DatabaseRequestDelegate>)delegate
{
    NSArray *keys = @[@"name", @"email", @"problem", @"problemDescription"];
    NSArray *data = @[name, email, problem, message];
    
    NSMutableString *params = [[NSMutableString alloc]init];
    
    for(int i = 0; i < [keys count]; i++)
    {
        if(i == 0)
        {
            [params appendString:[NSString stringWithFormat:@"%@=%@", keys[i],data[i]]];
        }
        else
        {
            [params appendString:[NSString stringWithFormat:@"&%@=%@", keys[i],data[i]]];
        }
        
    }
    
    
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_SEND_SUPPORT_EMAIL withKeys:@[] andData:@[]];
    
    [self.databaseRequest performRequestToDatabaseWithURLasString:urlString withDelegate:delegate postParams:params];
    
  


}

- (void)sendPDFToFarmer:(NSString *)name withEmail:(NSString *)email withFarmName:(NSString *)farmName withDelegate:(id<DatabaseRequestDelegate>)delegate
{


    
   
    NSArray *keys = @[@"name", @"email", @"farmName"];
    NSArray *data = @[name, email, farmName];
    
    NSMutableString *params = [[NSMutableString alloc]init];
    
    for(int i = 0; i < [keys count]; i++)
    {
        if(i == 0)
        {
            [params appendString:[NSString stringWithFormat:@"%@=%@", keys[i],data[i]]];
        }
        else
        {
            [params appendString:[NSString stringWithFormat:@"&%@=%@", keys[i],data[i]]];
        }
        
    }
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_SEND_PDF_TO_FARMER withKeys:@[] andData:@[]];
    
    [self.databaseRequest performRequestToDatabaseWithURLasString:urlString withDelegate:delegate postParams:params];
    
    
    
    
}

@end
