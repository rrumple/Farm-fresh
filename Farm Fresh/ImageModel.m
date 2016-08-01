//
//  ImageModel.m
//  Farm Fresh
//
//  Created by Randall Rumple on 6/1/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "ImageModel.h"

@interface ImageModel()

@property (nonatomic) int imagesComplete;


@end

@implementation ImageModel

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.imageCount = 0;
        self.imagesComplete = 0;
    }
    return self;
}

+ (void)saveUserProfileImage:(NSData *)data forUser:(UserModel *)userData
{
    

    // Create a reference to the file you want to upload
    FIRStorageReference *fileRef = [userData.storageRef child:@"profile/profile.png"];
    
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/png";
    
    // Upload the file to the path "images/rivers.jpg"
    //FIRStorageUploadTask *uploadTask =
    [fileRef putData:data metadata:metadata completion:^(FIRStorageMetadata *metadata, NSError *error) {
        if (error != nil) {
            // Uh-oh, an error occurred!
        } else {
            // Metadata contains file metadata such as size, content-type, and download URL.
            //NSURL *downloadURL = metadata.downloadURL;
        }
    }];
}

+ (void)saveFarmProfileImage:(NSData *)data forUser:(UserModel *)userData
{
    
    
    // Create a reference to the file you want to upload
    FIRStorageReference *fileRef = [userData.storageRef child:@"farm/farmProfile.png"];
    
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/png";
    
    // Upload the file to the path "images/rivers.jpg"
    //FIRStorageUploadTask *uploadTask =
    [fileRef putData:data metadata:metadata completion:^(FIRStorageMetadata *metadata, NSError *error) {
        if (error != nil) {
            // Uh-oh, an error occurred!
        } else {
            // Metadata contains file metadata such as size, content-type, and download URL.
            //NSURL *downloadURL = metadata.downloadURL;
            
            
        }
    }];
}

- (void)saveproductImage:(NSData *)data forUser:(FIRStorageReference *)storageRef withName:(NSString *)filename forProduct:(NSString *)productID atIndex:(int)index;
{
    // Create a reference to the file you want to upload
    FIRStorageReference *fileRef = [storageRef child:[NSString stringWithFormat:@"farm/products/%@/images/%@.png", productID, filename]];
    
    FIRStorageMetadata *metadata = [[FIRStorageMetadata alloc] init];
    metadata.contentType = @"image/png";
    
    // Upload the file to the path "images/rivers.jpg"
    //FIRStorageUploadTask *uploadTask =
    [fileRef putData:data metadata:metadata completion:^(FIRStorageMetadata *metadata, NSError *error) {
        self.imagesComplete++;
        
        if(self.imagesComplete == self.imageCount)
        {
            if([self.delegate respondsToSelector:@selector(imageUploadtCompleteForIndex:)])
           [self.delegate imageUploadtCompleteForIndex:index];
        }
        if (error != nil) {
            // Uh-oh, an error occurred!
        } else {
            // Metadata contains file metadata such as size, content-type, and download URL.
            //NSURL *downloadURL = metadata.downloadURL;
            
            
        }
    }];
}

- (void)deleteProductImage:(NSString *)filename forProductID:(NSString *)productID forUser:(FIRStorageReference *)storageRef
{
    // Create a reference to the file to delete
    FIRStorageReference *fileRef = [storageRef child:[NSString stringWithFormat:@"farm/products/%@/images/%@.png", productID, filename]];
    // Delete the file
    [fileRef deleteWithCompletion:^(NSError *error){
        self.imagesComplete++;
        
        if(self.imagesComplete == self.imageCount)
        {
            if([self.delegate respondsToSelector:@selector(imageUploadtCompleteForIndex:)])
                [self.delegate imageUploadtCompleteForIndex:0];
        }
        if (error != nil) {
            // Uh-oh, an error occurred!
        } else {
            // File deleted successfully
        }
    }];
}



@end
