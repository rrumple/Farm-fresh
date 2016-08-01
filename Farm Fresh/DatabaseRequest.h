//
//  DatabaseRequest.h
//  SchoolApp
//
//  Created by RandallRumple on 11/10/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DatabaseRequestDelegate;

@interface DatabaseRequest : NSObject

@property (nonatomic, weak) id<DatabaseRequestDelegate> delegate;

+(NSString *)buildURLUsingFilename:(NSString *)fileName withKeys:(NSArray *)keys andData:(NSArray *)data;

-(void)performRequestToDatabaseWithURLasString:(NSString *)url withDelegate:(id<DatabaseRequestDelegate>)delegate postParams:(NSString *)postParams;

@end

@protocol DatabaseRequestDelegate <NSObject>
@optional



@required

- (void)httpRequestCompleteWithData:(NSArray *)data;

@end