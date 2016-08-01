//
//  DatabaseRequest.m
//  SchoolApp
//
//  Created by RandallRumple on 11/10/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "DatabaseRequest.h"
#import "Constants.h"

@interface DatabaseRequest ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation DatabaseRequest



+(NSString *)buildURLUsingFilename:(NSString *)fileName withKeys:(NSArray *)keys andData:(NSArray *)data
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < data.count; i++)
    {
        if([[data objectAtIndex:i] isKindOfClass:[NSString class]])
        {
            NSString * string = (NSString *)[data objectAtIndex:i];
            
            NSString *newString1 = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            NSString *newString = [newString1 stringByReplacingOccurrencesOfString: @"&" withString: @"%26"];
            NSString *newString2 = [newString stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
            [array insertObject:newString2 atIndex:i];
            
            
        }
        else
        {
            [array insertObject:[data objectAtIndex:i] atIndex:i];
        }
    }
    
    NSMutableString *URLstring = [NSMutableString stringWithString:BASE_URL];
    
    [URLstring appendString:fileName];
    
    if ([keys count] == [array count])
    {
        for (int i = 0; i < [keys count]; i++)
        {
            if (i == 0)
            {
                [URLstring appendString:[NSString stringWithFormat:@"?%@=%@", keys[i],array[i]]];
            }
            else
            {
                [URLstring appendString:[NSString stringWithFormat:@"&%@=%@", keys[i], array[i]]];
            }
        }
        
        //[URLstring setString:[URLstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        
        NSLog(@"%@ request started", fileName);
        NSLog(@"URL - %@", URLstring);
        
        
    }
    

    
    return URLstring;
}

-(void)performRequestToDatabaseWithURLasString:(NSString *)urlString withDelegate:(id<DatabaseRequestDelegate>)delegate postParams:(NSString *)postParams
{
    
    self.delegate = delegate;
    
        //NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
    //urlRequest.timeoutInterval = 10000.0;
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:urlString];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[postParams dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSArray *dataArray;
        if(error == nil)
        {
            NSError *error1;
            
            dataArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error1];
            NSLog(@"%@", dataArray);
        }
        else
        {
            dataArray = [[NSArray alloc]init];
            NSLog(@"Database connection failed");
        }
        
        if([self.delegate respondsToSelector:@selector(httpRequestCompleteWithData:)])
        {
            [self.delegate httpRequestCompleteWithData:dataArray];
        }
    }];
    [dataTask resume];
    
    /*
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        
                                                        
                                                    }];
    
    [dataTask resume];
     */
    
   /* NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
        if(data)
        {
            
                
                NSError *error1;
            
                dataArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error1];
                NSLog(@"%@", dataArray);
                
            
        }
        else
        {
            dataArray = [[NSArray alloc]init];
            NSLog(@"Database connection failed");
        }*/
    
    
    
}



@end
