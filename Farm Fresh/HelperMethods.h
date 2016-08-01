//
//  HelperMethods.h
//  Farm Fresh
//
//  Created by Randall Rumple on 3/15/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+ImageEffects.h"
#import "UserModel.h"

UIKIT_EXTERN NSString * const HelperMethodsImageDownloadCompleted;

@interface HelperMethods : NSObject

+ (void)downloadSingleImageFromBaseURL:(NSString *)baseURL withFilename:(NSString *)fileName saveToDisk:(BOOL)saveToDisk replaceExistingImage:(BOOL)replaceExistingImage;
+ (NSDictionary *)getStateNamesAndAbbreviations;
+ (NSArray *)getProductCategories;
+ (BOOL)getTimeSinceFileCreated:(NSString *)dateStringToCheck;
+ (NSString *)getTimeSinceDate:(NSString *)dateStringToCheck;
+ (BOOL)isEmailValid:(NSString *)email;
+ (void)removeUserProfileImage;
+ (NSArray *)getDateArrayFromString:(NSString *)date;
+ (NSArray *)ConvertHourUsingDateArray:(NSArray *)dateArray;
+ (NSInteger)getWeekday;
+ (NSString *)chatDateToStringhhmma:(NSDate *)date;
+ (NSString *)getWeekdayName:(NSInteger)day;
+ (NSString *)getWeekdayNameAbbr:(NSInteger)day;
+ (NSString *)formatExpireDate:(NSDate *)date;
+ (NSString *)formatPostedAndExpireDate:(NSString *)dateString isPostedDate:(BOOL)isPostedDate;
+ (NSString *)formatSentDateForNotifications:(NSString *)dateString;
+ (BOOL)isLocationOpen:(NSString *)openTime closed:(NSString *)closedTime;
+ (void)downloadUserProfileImageFromFirebase:(UserModel *)userData;
+ (void)downloadFarmProfileImageFromFirebase:(UserModel *)userData;
+ (void)downloadOtherUsersFarmProfileImageFromFirebase:(NSString *)userID;
+ (void)downloadProductImageFromFirebase:(NSString *)userID forProductID:(NSString *)productID imageNumber:(NSInteger)imageNumber;

@end
