//
//  HelperMethods.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/15/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "HelperMethods.h"
#import <QuartzCore/QuartzCore.h>
NSString *const HelperMethodsImageDownloadCompleted = @"HelperMethodsImageDownloadCompleted";

@implementation HelperMethods

+ (void)downloadUserProfileImageFromFirebase:(UserModel *)userData
{
    
    // Create a reference to the file you want to download
    FIRStorageReference *fileRef = [userData.storageRef child:@"profile/profile.png"];
    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
    [fileRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
        if (error != nil) {
            // Uh-oh, an error occurred!
        } else {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"profile.png"];
            [data writeToFile:filePath atomically:YES];
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:HelperMethodsImageDownloadCompleted object:nil];
                
            });
        }
    }];
}

+ (void)downloadOtherUsersFarmProfileImageFromFirebase:(NSString *)userID
{
    
    
    
    // Create a reference to the file you want to download
    FIRStorageReference *fileRef = [[[FIRStorage storage] reference] child:[NSString stringWithFormat:@"%@/farm/farmProfile.png", userID]];
    
    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
    [fileRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
        if (error != nil) {
            // Uh-oh, an error occurred!
        } else {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_farmProfile.png", userID]];
            [data writeToFile:filePath atomically:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:HelperMethodsImageDownloadCompleted object:nil];
                
            });
        }
    }];
}

+ (void)downloadProductImageFromFirebase:(NSString *)userID forProductID:(NSString *)productID imageNumber:(NSInteger)imageNumber
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%ld.png", productID, (long)imageNumber]];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* attrs = [fm attributesOfItemAtPath:filePath error:nil];
    
    if (attrs != nil) {
        NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
        NSLog(@"Date Created: %@", [date description]);
        if([self getTimeSinceFileCreated:[date description]])
        {
            NSLog(@"Removing Photo and redownloading");
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        
    }
    else {
        NSLog(@"Not found");
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        // Create a reference to the file you want to download
        FIRStorageReference *fileRef = [[[FIRStorage storage] reference] child:[NSString stringWithFormat:@"%@/farm/products/%@/images/%@_%ld.png", userID, productID, productID, (long)imageNumber]];
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        [fileRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
            if (error != nil) {
                // Uh-oh, an error occurred!
            } else {
                
                [data writeToFile:filePath atomically:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"HelperMethodsProductImageDownloadComplete" object:[NSString stringWithFormat:@"%ld", (long)imageNumber]];
                    
                });

                
            
            }
        }];
    }
}

+ (void)downloadFarmProfileImageFromFirebase:(UserModel *)userData
{
    
    // Create a reference to the file you want to download
    FIRStorageReference *fileRef = [userData.storageRef child:@"farm/farmProfile.png"];
    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
    [fileRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
        if (error != nil) {
            // Uh-oh, an error occurred!
        } else {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"farmProfile.png"];
            [data writeToFile:filePath atomically:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:HelperMethodsImageDownloadCompleted object:nil];
                
            });
        }
    }];
}

+ (void)downloadSingleImageFromBaseURL:(NSString *)baseURL withFilename:(NSString *)fileName saveToDisk:(BOOL)saveToDisk replaceExistingImage:(BOOL)replaceExistingImage
{
    
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, fileName];
    if(![[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:baseURL]];
        //NSLog(@"%@", baseImageURL);
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                            if (!error)
                                                            {
                                                                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                                                                
                                                                NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
                                                                [data1 writeToFile:pngFilePath atomically:YES];
                                                                NSLog(@"%@ download complete", fileName);
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [[NSNotificationCenter defaultCenter]postNotificationName:HelperMethodsImageDownloadCompleted object:nil];
                                                                    
                                                                });
                                                                
                                                            }
                                                        }];
        [task resume];
    }
    else if (replaceExistingImage)
    {
        pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, fileName];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:baseURL]];
        // NSLog(@"%@", baseImageURL);
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                            if (!error)
                                                            {
                                                                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                                                                
                                                                NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
                                                                [data1 writeToFile:pngFilePath atomically:YES];
                                                                NSLog(@"%@ download complete", fileName);
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [[NSNotificationCenter defaultCenter]postNotificationName:HelperMethodsImageDownloadCompleted object:nil];
                                                                    
                                                                });
                                                            }
                                                        }];
        [task resume];
        
    }
    else
        NSLog(@"%@ is already downloaded", fileName);
    
    
}

+ (NSArray *)getProductCategories
{
    return @[@"Corn", @"Beans", @"Cabbage", @"Carrots"];
}


+ (NSDictionary *)getStateNamesAndAbbreviations
{
    NSDictionary *states =
                    @{@"stateNames" :
                        @[@"Alabama",
                        @"Alaska",
                        @"Arizona",
                        @"Arkansas",
                        @"California",
                        @"Colorado",
                        @"Connecticut",
                        @"Delaware",
                        @"Florida",
                        @"Georgia",
                        @"Hawaii",
                        @"Idaho",
                        @"Illinois",
                        @"Indiana",
                        @"Iowa",
                        @"Kansas",
                        @"Kentucky",
                        @"Louisiana",
                        @"Maine",
                        @"Maryland",
                        @"Massachusetts",
                        @"Michigan",
                        @"Minnesota",
                        @"Mississippi",
                        @"Missouri",
                        @"Montana",
                        @"Nebraska",
                        @"Nevada",
                        @"New Hampshire",
                        @"New Jersey",
                        @"New Mexico",
                        @"New York",
                        @"North Carolina",
                        @"North Dakota",
                        @"Ohio",
                        @"Oklahoma",
                        @"Oregon",
                        @"Pennsylvania",
                        @"Rhode Island",
                        @"South Carolina",
                        @"South Dakota",
                        @"Tennessee",
                        @"Texas",
                        @"Utah",
                        @"Vermont",
                        @"Virginia",
                        @"Washington",
                        @"West Virginia",
                        @"Wisconsin",
                        @"Wyoming",
                        @"Washington, DC"],
                             
                    @"stateAbbreviations" :
                        @[@"AL",
                        @"AK",
                        @"AZ",
                        @"AR",
                        @"CA",
                        @"CO",
                        @"CT",
                        @"DE",
                        @"FL",
                        @"GA",
                        @"HI",
                        @"ID",
                        @"IL",
                        @"IN",
                        @"IA",
                        @"KS",
                        @"KY",
                        @"LA",
                        @"ME",
                        @"MD",
                        @"MA",
                        @"MI",
                        @"MN",
                        @"MS",
                        @"MO",
                        @"MT",
                        @"NE",
                        @"NV",
                        @"NH",
                        @"NJ",
                        @"NM",
                        @"NY",
                        @"NC",
                        @"ND",
                        @"OH",
                        @"OK",
                        @"OR",
                        @"PA",
                        @"RI",
                        @"SC",
                        @"SD",
                        @"TN",
                        @"TX",
                        @"UT",
                        @"VT",
                        @"VA",
                        @"WA",
                        @"WV",
                        @"WI",
                        @"WY",
                        @"DC"
                          ]};
    
    return states;
}

+ (BOOL)getTimeSinceFileCreated:(NSString *)dateStringToCheck
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
    
    NSDate *d1 =  [formatter dateFromString:dateStringToCheck];
    NSDate *d2 = [NSDate date];
    NSDateComponents* components = [c components:(NSCalendarUnitMinute) fromDate:d1 toDate:d2 options:0] ;
    
    
    NSLog(@"%ld", (long)components.minute);
    
    if(components.minute > 60)// 60 minute caching of photos
        return true;
    else
        false;
    return false;
    
}

+ (NSString *)getTimeSinceDate:(NSString *)dateStringToCheck
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
    
    NSDate *d1 =  [formatter dateFromString:dateStringToCheck];
    NSDate *d2 = [NSDate date];
    NSDateComponents* components = [c components:(NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:d1 toDate:d2 options:0] ;
    
    
    NSString *timeSince;
    if(components.day == 0)
    {
        if(components.hour == 0)
        {
            //Display Minutes
            if(components.minute <= 2)
                timeSince = @"Just Now";
            else
                timeSince = [NSString stringWithFormat:@"%ld minutes", (long)components.minute];
        }
        else
        {
            //Display Hours
            if(components.hour == 1)
                timeSince = @"1 hour";
            else
                timeSince = [NSString stringWithFormat:@"%ld hours", (long)components.hour];
        }
    }
    else
    {
        //Display in Days
        
        if(components.day == 1)
            timeSince = @"1 day";
        else
            timeSince = [NSString stringWithFormat:@"%ld days", (long)components.day];
    }
    
    return timeSince;
}

+ (NSString *)formatPostedAndExpireDate:(NSString *)dateString isPostedDate:(BOOL)isPostedDate
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
    
    NSDate *d1 =  [formatter dateFromString:dateString];
    NSDate *d2 = [NSDate date];
    NSDateComponents* components = [c components:(NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate:d1 toDate:d2 options:0] ;
    
    
    NSString *timeSince;
    if(components.day < 1 && isPostedDate)
    {
        [formatter setDateFormat:@"hh:mma"];
        timeSince = [NSString stringWithFormat:@"Today - %@",[formatter stringFromDate:d1]];
    }
    else
    {
        [formatter setDateFormat:@"MM/dd/yyyy hh:mma"];
        timeSince = [formatter stringFromDate:d1];
    }
    
    
    return timeSince;
}

+ (NSString *)prepStringForValidation:(NSString *)input
{
    return [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+ (BOOL)isEmailValid:(NSString *)email
{
    
    if(email.length > 0)
    {
        NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        if  ([emailTest evaluateWithObject:[HelperMethods prepStringForValidation:email]] != YES)
            return NO;
        else
            return YES;
    }
    else
        return NO;
    
    
}

+ (void)removeUserProfileImage
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/profile.png",docDir];
    
    NSError *error;
    
    [[NSFileManager defaultManager] removeItemAtPath:pngFilePath error:&error];
}

+ (NSArray *)getDateArrayFromString:(NSString *)date
{
    NSArray *dateArray = [date componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"- :/"]];
    
    return dateArray;
    
}

+ (NSArray *)ConvertHourUsingDateArray:(NSArray *)dateArray
{
    NSMutableArray *newArray = [dateArray mutableCopy];
    NSInteger hour = [dateArray[3] integerValue];
    
    if(hour > 12)
    {
        hour -=12;
        if(hour == 12)
            newArray[5] = @"am";
        else
            newArray[5] = @"pm";
    }
    else
    {
        if(hour == 12)
            newArray[5] = @"pm";
        else if(hour == 0)
        {
            hour = 12;
            newArray[5] = @"am";
        }
        else if(hour < 12)
            newArray[5] = @"am";
    }
    
    newArray[3] = [NSString stringWithFormat:@"%li", (long)hour];
    
    return newArray;
}

+ (NSInteger)getWeekday
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger weekday = [comps weekday];
    
    return weekday -1;
}

+ (NSString *)chatDateToStringhhmma:(NSDate *)date
{
    NSString *dateString = @"";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE/MM/dd/yyyy/h:mm a"];
    
    
    
    dateString = [dateFormatter stringFromDate:date];
    
    
    
    return dateString;
    
    
}

+ (NSString *)formatExpireDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    
    [dateFormatter setDateFormat:@"MM/dd/yyyy @ hh:mma"];
    
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)formatSentDateForNotifications:(NSString *)dateString
{
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *d1 =  [formatter dateFromString:dateString];
    
    [formatter setDateFormat:@"MM/dd hh:mma"];
    
    
    return [formatter stringFromDate:d1];
}

+ (NSString *)getWeekdayNameAbbr:(NSInteger)day
{
    switch (day) {
        case 0:
            return @"Sun.";
            break;
        case 1:
            return @"Mon.";
            break;
        case 2:
            return @"Tue.";
            break;
        case 3:
            return @"Weds.";
            break;
        case 4:
            return @"Thurs.";
            break;
        case 5:
            return @"Fri.";
            break;
        case 6:
            return @"Sat.";
            break;
            
        default:
            return @"";
            break;
    }
}

+ (NSString *)getWeekdayName:(NSInteger)day
{
    switch (day) {
        case 0:
            return @"Sunday";
            break;
        case 1:
            return @"Monday";
            break;
        case 2:
            return @"Tuesday";
            break;
        case 3:
            return @"Wednesday";
            break;
        case 4:
            return @"Thursday";
            break;
        case 5:
            return @"Friday";
            break;
        case 6:
            return @"Saturday";
            break;
            
        default:
            return @"";
            break;
    }
}

+ (BOOL)isLocationOpen:(NSString *)openTime closed:(NSString *)closedTime
{
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute  fromDate:[NSDate date]];
    
    NSInteger hour= [components hour];
    NSInteger minute = [components minute];
    
    NSArray *array = [openTime componentsSeparatedByString:@":"];
    
    if(array.count != 2)
        return NO;
    
    NSInteger openHour = [[array objectAtIndex:0] integerValue];
    NSInteger openMins = [[[array objectAtIndex:1] substringToIndex:2]integerValue];
    
    if([[[array objectAtIndex:1] substringFromIndex:2] isEqualToString:@"pm"])
        openHour += 12;
    
    array = [closedTime componentsSeparatedByString:@":"];
    if(array.count != 2)
        return NO;
    
    NSInteger closeHour = [[array objectAtIndex:0] integerValue];
    NSInteger closeMins = [[[array objectAtIndex:1] substringToIndex:2]integerValue];
    
    if([[[array objectAtIndex:1] substringFromIndex:2] isEqualToString:@"pm"])
        closeHour += 12;
    
    if(hour > openHour)
    {
        if(hour < closeHour)
        {
            return YES;
        }
        else if(hour == closeHour)
        {
            if(minute < closeMins)
                return YES;
        }
        
    }
    else if (hour == openHour)
    {
        if(minute >= openMins)
        {
            if(hour < closeHour)
            {
                return YES;
            }
            else if(hour == closeHour)
            {
                if(minute < closeMins)
                    return YES;
            }
        }
    }
    else
        return NO;
    
    return NO;
}

@end
