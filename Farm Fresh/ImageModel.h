//
//  ImageModel.h
//  Farm Fresh
//
//  Created by Randall Rumple on 6/1/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

@protocol ImageModelDelegate;

@interface ImageModel : NSObject

@property (nonatomic, weak) id<ImageModelDelegate> delegate;
@property (nonatomic) int imageCount;

+ (void)saveUserProfileImage:(NSData *)data forUser:(UserModel *)userData;

+ (void)saveFarmProfileImage:(NSData *)data forUser:(UserModel *)userData;

- (void)saveproductImage:(NSData *)data forUser:(FIRStorageReference *)storageRef withName:(NSString *)filename forProduct:(NSString *)productID atIndex:(int)index;

- (void)deleteProductImage:(NSString *)filename forProductID:(NSString *)productID forUser:(FIRStorageReference *)storageRef;

@end

@protocol ImageModelDelegate <NSObject>

@optional
- (void)imageUploadtCompleteForIndex:(int)index;
- (void)imageUploadtCompleteFacebookReady:(NSURL *)url;
- (void)imageUploadUpdate;
@end

