//
//  UserModel.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/11/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "UserModel.h"
#import "constants.h"
#import "HelperMethods.h"


@interface UserModel ()




@property (nonatomic, strong) GFCircleQuery *circleQuery;



@property (nonatomic) int favoriteCounter;


@property (nonatomic) int searchRetries;





@end

@implementation UserModel

- (NSMutableDictionary *)farmProducts
{
    if(!_farmProducts) _farmProducts = [[NSMutableDictionary alloc]init];
    return _farmProducts;
}

- (NSMutableArray *)notifications
{
    if(!_notifications) _notifications = [[NSMutableArray alloc]init];
    return _notifications;
}

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.searchRetries = 0;
        
        self.ref= [[FIRDatabase database] reference];
        
        self.storageRef = [[FIRStorage storage] reference];
    
        FIRDatabaseReference *geoFireRef = [self.ref child:@"_geofire"];
        FIRDatabaseReference *geoFireCities = [self.ref child:@"_geofire_cities"];
        
        self.geoFire = [[GeoFire alloc] initWithFirebaseRef:geoFireRef];
        self.geoFireCities = [[GeoFire alloc]initWithFirebaseRef:geoFireCities];
        
        self.searchRadius = 8.046720 * 4; // 5 * 4 = 20miles
        self.searchResults = [[NSArray alloc]init];
        self.searchResultsFarmers = [[NSMutableDictionary alloc]init];
        self.searchResultsLocations = [[NSMutableDictionary alloc]init];
        self.favoriteFarmersData = [[NSMutableArray alloc]init];
        self.favoriteFarmersLocations = [[NSMutableDictionary alloc]init];
        self.searchResultsAllLocations = [[NSMutableDictionary alloc]init];
        self.searchCounter = 0;
        self.favoriteCounter = 0;
        self.searchStarted = NO;
        self.isAdmin = NO;
        self.categories = @[@"Product Category Not Listed"];
        self.user = [FIRAuth auth].currentUser;
        self.storageRef = [self.storageRef child:self.user.uid];
        

    
    
        self.chatList = [[NSMutableArray alloc]init];
        self.chatFollowers = [[NSMutableArray alloc]init];
    }
    
    return self;
}

- (void)userSignedOut
{
    
    if(!self.firstName && !self.lastName && !self.user.uid)
    {
        FBSDKLoginManager *facebookLogin = [[FBSDKLoginManager alloc] init];
        
        [facebookLogin logOut];
        /*google
         [[GIDSignIn sharedInstance] signOut];
         */
        [[FIRAuth auth]signOut:nil];
        self.firstName = @"";
        self.lastName = @"";
        self.email = @"";
        self.mainPhone = @"";
        self.contactEmail = @"";
        self.contactPhone = @"";
        self.imageURL = @"";
        self.farmName = @"";
        self.farmDescription = @"";
        self.farmLocations = nil;
        self.farmProducts = nil;
        self.notifications = nil;
        self.isFarmer = NO;
        self.isUserLoggedIn = NO;
        self.isAdmin = NO;
        self.mySchedule = nil;
        self.overrideSchedule = nil;
        self.chatList = [[NSMutableArray alloc]init];
        self.chatFollowers = [[NSMutableArray alloc]init];
        self.favoriteFarmersLocations = [[NSMutableDictionary alloc]init];
        self.searchResultsAllLocations = [[NSMutableDictionary alloc]init];
        self.favoriteFarmersData = [[NSMutableArray alloc]init];
        self.storageRef = [[FIRStorage storage] reference];
        [self.ref removeAllObservers];
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    }
    else
    {
        self.isUserLoggedIn = NO;
        [[[[self.ref child:@"users/"]
           child:self.user.uid] child:@"pushPin/" ] removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            FBSDKLoginManager *facebookLogin = [[FBSDKLoginManager alloc] init];
            
            [facebookLogin logOut];
            /*google
             [[GIDSignIn sharedInstance] signOut];
             */
            [[FIRAuth auth]signOut:nil];
            self.firstName = @"";
            self.lastName = @"";
            self.email = @"";
            self.mainPhone = @"";
            self.contactEmail = @"";
            self.contactPhone = @"";
            self.imageURL = @"";
            self.farmName = @"";
            self.farmDescription = @"";
            self.farmLocations = nil;
            self.farmProducts = nil;
            self.notifications = nil;
            self.isFarmer = NO;
            self.isAdmin = NO;
            self.mySchedule = nil;
            self.overrideSchedule = nil;
            self.chatList = [[NSMutableArray alloc]init];
            self.chatFollowers = [[NSMutableArray alloc]init];
            self.favoriteFarmersLocations = [[NSMutableDictionary alloc]init];
            self.searchResultsAllLocations = [[NSMutableDictionary alloc]init];
            self.favoriteFarmersData = [[NSMutableArray alloc]init];
            self.storageRef = [[FIRStorage storage] reference];
            [self.ref removeAllObservers];
            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        }];
        
    }
    
   
    
}

- (void)setUserData
{
    self.user = [FIRAuth auth].currentUser;
    
    if(self.storageRef.fullPath.length == 0)
        self.storageRef = [self.storageRef child:self.user.uid];
    
    FIRDatabaseReference *userRef = [self.ref child:[NSString stringWithFormat:@"/users/%@", self.user.uid]];
    if([self.delegate respondsToSelector:@selector(updateStatusUpdate:)])
    {
        [self.delegate updateStatusUpdate:1];
    }
    
    [userRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        if (snapshot.value == [NSNull null]) {
            
            if(self.isUserLoggedIn)
                [self userSignedOut];
            
            if([self.delegate respondsToSelector:@selector(updateStatusComplete)])
            {
                [self.delegate updateStatusComplete];
            }
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(updateStatusUpdate:)])
            {
                [self.delegate updateStatusUpdate:2];
            }
            
            NSString *pushPin;
            if(self.isUserLoggedIn)
                 pushPin = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PUSH_NOTIFICATION_PIN];
            
            if(pushPin)
                [[[self.ref child:@"/users/"] child:self.user.uid] updateChildValues:@{@"pushPin" : pushPin}];
             
            
            NSDictionary *value1 = snapshot.value;
            int nameType = 0;
            
            NSDictionary *favorites = [value1 objectForKey:@"favorites"];
            NSArray *favoriteKeys = favorites.allKeys;
            
            NSMutableDictionary * newFavorites = [[NSMutableDictionary alloc]init];
            
            
            for(NSString *string in favoriteKeys)
            {
                NSMutableDictionary *tempDic = [[favorites objectForKey:string]mutableCopy];
                
                [tempDic setObject:string forKey:@"favoriteID"];
                
                [newFavorites setObject:tempDic forKey:tempDic[@"farmerID"]];
                
            }
            
            self.favorites = newFavorites;
            [self updateFavoriteFarmersData];
            
            if(![self.firstName isEqualToString:[value1 objectForKey:@"firstName"]])
                nameType = 1;
            else if(![self.lastName isEqualToString:[value1 objectForKey:@"lastName"]])
                nameType = 2;
            
            self.firstName = [value1 objectForKey:@"firstName"];
            self.lastName = [value1 objectForKey:@"lastName"];
            self.email = [value1 objectForKey:@"email"];
            self.imageURL = [value1 objectForKey:@"profileImage"];
            if(!self.firstName || !self.lastName || !self.email)
            {
                if (self.user) {
                    id<FIRUserInfo> profile;
                    NSString *providerId;
                    NSString *uid;
                    NSString *name;
                    NSString *email;
                    NSString *photoUrl;
                    if (self.user != nil) {
                        profile = self.user.providerData.firstObject;
                        
                        providerId = profile.providerID;
                        uid = profile.uid;  // Provider-specific UID
                        name = profile.displayName;
                        email = profile.email;
                        photoUrl = [profile.photoURL absoluteString];
                        
                        
                    } else {
                        // No user is signed in.
                    }
                    // save the user's profile into the database so we can list users,
                    // use them in Security and Firebase Rules, and show profiles
                    NSArray *nameArray = [name componentsSeparatedByString:@" "];
                    NSMutableDictionary *newUser = [[NSMutableDictionary alloc]init];
                    if(providerId)
                        [newUser setObject:providerId forKey:@"provider"];
                    if([nameArray objectAtIndex:0])
                        [newUser setObject:[nameArray objectAtIndex:0] forKey:@"firstName"];
                    if([nameArray objectAtIndex:1])
                        [newUser setObject:[nameArray objectAtIndex:1] forKey:@"lastName"];
                    if(photoUrl)
                        [newUser setObject:photoUrl forKey:@"profileImage"];
                    if(email)
                        [newUser setObject:email forKey:@"email"];
                    
                    [[[self.ref child:@"users"]
                      child:self.user.uid] updateChildValues:newUser];
                    
                
                    
                    
                }
            }
            
            
            self.isFarmer = [[value1 objectForKey:@"isFarmer"] boolValue];
            self.searchRadius = [[value1 objectForKey:@"searchRadius"]doubleValue];
            self.isAdmin = [[value1 objectForKey:@"isAdmin"]boolValue];
            self.useCustomProfileImage = [[value1 objectForKey:@"useCustomProfileImage"]boolValue];
            if([value1 objectForKey:@"chatList"])
            {
                self.chatList = [[NSMutableArray alloc]init];
                NSDictionary *dic = [value1 objectForKey:@"chatList"];
                
               
                    NSArray *allKeys = [dic allKeys];
                
                    for(NSString *farmerID in allKeys)
                    {
                        FIRDatabaseReference *getNameRef = [[[self.ref child:@"/farms/"]child:farmerID]child:@"farmName/"];
                        
                        [getNameRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                            if(snapshot.value == [NSNull null])
                            {
                                
                            }
                            else
                            {
                                NSString *farmName = snapshot.value;
                                
                                BOOL match = NO;
                                for(NSDictionary *chatDic in self.chatList)
                                {
                                    if([chatDic[@"userID"] isEqualToString:farmerID])
                                    {
                                        match = YES;
                                        break;
                                    }
                                }
                                if(!match)
                                {
                                    [self.chatList addObject:@{
                                                                @"userID" : farmerID,
                                                                @"name" : farmName
                                                                }];
                                }
                            }
                        }];
                    }
                
            }

            
            
            if([self.delegate respondsToSelector:@selector(updateStatusComplete)])
            {
                [self.delegate updateStatusComplete];
            }
            
            if(nameType != 0)
            {
                if([self.delegate respondsToSelector:@selector(nameUpdated:)])
                {
                    [self.delegate nameUpdated:nameType];
                }
            }
            
            
        }
    }];
    
    FIRDatabaseReference *appSettingsRef = [self.ref child:@"appSettings/"];
    
    [appSettingsRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.value == [NSNull null]) {
            // The value is null
        }
        else
        {
            NSDictionary *value1 = snapshot.value;
            
            [[NSUserDefaults standardUserDefaults] setObject:value1[@"productExpireDays"] forKey:@"productExpireDays"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
    }];
    
    FIRDatabaseReference *farmRef = [self.ref child:[NSString stringWithFormat:@"/farms/%@", self.user.uid]];
    
    [farmRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        if (snapshot.value == [NSNull null]) {
            // The value is null
        }
        else
        {
            NSDictionary *value1 = snapshot.value;
            
            self.farmDescription = [value1 objectForKey:@"farmDescription"];
            self.farmName = [value1 objectForKey:@"farmName"];
            self.numReviews = [[value1 objectForKey:@"numReviews"] intValue];
            self.mainPhone = [value1 objectForKey:@"mainPhone"];
            self.contactPhone = [value1 objectForKey:@"contactPhone"];
            self.contactEmail = [value1 objectForKey:@"contactEmail"];
            self.useChat = [[value1 objectForKey:@"useChat"] boolValue];
            self.followerNotification = [[value1 objectForKey:@"followerNotification"]boolValue];
            self.reviewNotification = [[value1 objectForKey:@"reviewNotification"]boolValue];
            self.useEmail = [[value1 objectForKey:@"useEmail"] boolValue];
            self.useTelephone = [[value1 objectForKey:@"useTelephone"] boolValue];
            self.numFavorites = [value1 objectForKey:@"numFavorites"];
            if([value1 objectForKey:@"chatList"])
            {
                self.chatFollowers = [[NSMutableArray alloc]init];
                NSDictionary *dic = [value1 objectForKey:@"chatList"];
                
                    NSArray *allKeys = [dic allKeys];
                    
                    for(NSString *userID in allKeys)
                    {
                        FIRDatabaseReference *getNameRef = [[self.ref child:@"/users/"]child:userID];
                        
                        [getNameRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                            if(snapshot.value == [NSNull null])
                            {
                                
                            }
                            else
                            {
                                NSDictionary *userData = snapshot.value;
                                NSString *name = [NSString stringWithFormat:@"%@ %@", userData[@"firstName"], userData[@"lastName"]];
                                
                                BOOL match = NO;
                                for(NSDictionary *chatDic in self.chatFollowers)
                                {
                                    if([chatDic[@"userID"]isEqualToString:userID])
                                    {
                                        match = YES;
                                        break;
                                    }
                                }
                                if(!match)
                                {
                                    [self.chatFollowers addObject:@{
                                                               @"userID" : userID,
                                                               @"name" : name
                                                               }];
                                }
                            }
                        }];
                    }
                
            }
            
            if([value1 objectForKey:@"overrideSchedule"])
                self.overrideSchedule = [value1 objectForKey:@"overrideSchedule"];
            if([value1 objectForKey:@"schedule"])
            {
                if([[value1 objectForKey:@"schedule"] isKindOfClass:[NSArray class]])
                {
                    NSArray *tempArray = [value1 objectForKey:@"schedule"];
                    NSMutableDictionary *tempdic = [[NSMutableDictionary alloc]init];
                    NSLog(@"is Array");
                    for(int i = 0; i < tempArray.count; i++)
                    {
                        if([tempArray objectAtIndex:i] != [NSNull null])
                        {
                            [tempdic setObject:[tempArray objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d", i]];
                        }
                    }
                    self.mySchedule = tempdic;
                }
                else if([[value1 objectForKey:@"schedule"] isKindOfClass:[NSDictionary class]])
                {
                    self.mySchedule = (NSDictionary*)[value1 objectForKey:@"schedule"];
                }
                
            }
            
            
            if([self.delegate respondsToSelector:@selector(farmerProfileUpdated)])
            {
                [self.delegate farmerProfileUpdated];
            }
            
        }
    }];
    
    FIRDatabaseReference *farmLocRef = [self.ref child:@"/locations"];
    
    
    [[[farmLocRef queryOrderedByChild:@"farmerID"] queryEqualToValue:self.user.uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot2) {
        
        if(snapshot2.value == [NSNull null]) {
            NSLog(@"No messages");
            self.farmLocations = nil;
            
        } else {
            NSDictionary *value1 = snapshot2.value;
            NSArray *keys = value1.allKeys;
            NSMutableArray *values = [[NSMutableArray alloc]init];
            
            for(NSString *key in keys)
            {
                
                NSDictionary *tempDic = [value1 objectForKey:key];
                [values addObject:@{
                                    @"fullAddress" : tempDic[@"fullAddress"],
                                    @"locationName" : tempDic[@"locationName"],
                                    @"farmerID" : tempDic[@"farmerID"],
                                    @"latitude" : tempDic[@"latitude"],
                                    @"longitude" : tempDic[@"longitude"],
                                    @"locationID" : key
                                    }];
                
            }
            
            self.farmLocations = values;
            
            

        }
        
        if([self.delegate respondsToSelector:@selector(farmLocationsUpdated)])
        {
            [self.delegate farmLocationsUpdated];
        }
        
    }];
    
    FIRDatabaseReference *farmProductsRef = [self.ref child:@"/products"];
    
   
    
    [[[farmProductsRef queryOrderedByChild:@"farmerID"] queryEqualToValue:self.user.uid] observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot2) {
        
        if(snapshot2.value == [NSNull null]) {
            NSLog(@"No messages");
            
            
        } else {
            NSDictionary *tempDic = snapshot2.value;
            NSLog(@"%@",snapshot2.key);
            
            NSLocale *usLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setLocale:usLocale];
            [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
            
            BOOL isActive = [tempDic[@"isActive"]boolValue];
            NSDate *expireDate = [dateFormatter dateFromString:tempDic[@"expireDate"]];
            
            if(isActive)
            {
                if([expireDate compare:[NSDate date]] == NSOrderedAscending)
                {
                   /* [self makeProductInactive:snapshot2.key withUserID:tempDic[@"farmerID"] forProductNamed:tempDic[@"productHeadline"]];
                    */
                }
            }
            
            [self.farmProducts setObject:@{
                                           @"amount" : tempDic[@"amount"],
                                           @"amountDescription" : tempDic[@"amountDescription"],
                                           //@"category" : tempDic[@"category"],
                                           @"farmerID" : tempDic[@"farmerID"],
                                           @"productDescription" : tempDic[@"productDescription"],
                                           @"productHeadline" : tempDic[@"productHeadline"],
                                           @"datePosted" : tempDic[@"datePosted"],
                                           @"isActive" : tempDic[@"isActive"],
                                           @"expireDate" : tempDic[@"expireDate"],
                                           @"productID" : snapshot2.key
                                           } forKey:snapshot2.key];
            
            
        }
        NSLog(@"%@", self.farmProducts);
        if([self.delegate respondsToSelector:@selector(farmProductUpdated)])
        {
            [self.delegate farmProductUpdated];
        }
        
    }];
    
    [[[farmProductsRef queryOrderedByChild:@"farmerID"] queryEqualToValue:self.user.uid] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot2) {
        
        if(snapshot2.value == [NSNull null]) {
            NSLog(@"No messages");
            
            
        } else {
            NSDictionary *tempDic = snapshot2.value;
            NSLog(@"%@",snapshot2.key);
            
            NSLocale *usLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setLocale:usLocale];
            [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
            
            BOOL isActive = [tempDic[@"isActive"]boolValue];
            NSDate *expireDate = [dateFormatter dateFromString:tempDic[@"expireDate"]];
            
            if(isActive)
            {
                if([expireDate compare:[NSDate date]] == NSOrderedAscending)
                {
                   /* [self makeProductInactive:snapshot2.key withUserID:tempDic[@"farmerID"] forProductNamed:tempDic[@"productHeadline"]];*/
                }
            }
           
             
            [self.farmProducts setObject:@{
                                          @"amount" : tempDic[@"amount"],
                                          @"amountDescription" : tempDic[@"amountDescription"],
                                          //@"category" : tempDic[@"category"],
                                          @"farmerID" : tempDic[@"farmerID"],
                                          @"productDescription" : tempDic[@"productDescription"],
                                          @"productHeadline" : tempDic[@"productHeadline"],
                                          @"datePosted" : tempDic[@"datePosted"],
                                          @"isActive" : tempDic[@"isActive"],
                                          @"expireDate" : tempDic[@"expireDate"],
                                          @"productID" : snapshot2.key
                                          } forKey:snapshot2.key];
            
            
        }
        
        if([self.delegate respondsToSelector:@selector(farmProductUpdated)])
        {
            [self.delegate farmProductUpdated];
        }
        
    }];
    
    [[[farmProductsRef queryOrderedByChild:@"farmerID"] queryEqualToValue:self.user.uid] observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot *snapshot2) {
        
        if(snapshot2.value == [NSNull null]) {
            NSLog(@"No messages");
            
            
        } else {
            
            NSLog(@"%@",snapshot2.key);
            
            
            [self.farmProducts removeObjectForKey:snapshot2.key];
            
            
        }
        
        if([self.delegate respondsToSelector:@selector(farmProductUpdated)])
        {
            [self.delegate farmProductUpdated];
        }
        
    }];
    
    

}

- (void)addFarmerAsAFavorite:(NSDictionary *)farmerData
{
    FIRDatabaseReference *favoriteRef =[[self.ref child:[NSString stringWithFormat:@"users/%@/favorites", self.user.uid]]childByAutoId];
    
    NSString *favoriteID = favoriteRef.key;
    
    [favoriteRef setValue:farmerData];
    
    
    
    
    [[self.ref child:[NSString stringWithFormat:@"farms/%@/followers/", farmerData[@"farmerID"]]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if(snapshot.value == [NSNull null]){
            [[self.ref child:[NSString stringWithFormat:@"farms/%@/followers", farmerData[@"farmerID"]]] setValue: @{favoriteID : self.user.uid}];
        }
        else
        {
            NSMutableDictionary *followers = [snapshot.value mutableCopy];
            
            [followers setObject:self.user.uid forKey:favoriteID];
            
            [[self.ref child:[NSString stringWithFormat:@"farms/%@/followers", farmerData[@"farmerID"]]] setValue: followers];
        }
    }];
    
    FIRDatabaseReference *favoriteNumRef = [self.ref child:[NSString stringWithFormat:@"/farms/%@/numFavorites/", farmerData[@"farmerID"]]];
    
    [favoriteNumRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        if(snapshot.value == [NSNull null]) {
            NSLog(@"No messages");
            
        } else {
            
            NSString *numFavorites = snapshot.value;
            
            int numFavs = [numFavorites intValue];
            
            numFavs++;
            
            [favoriteNumRef setValue:[NSString stringWithFormat:@"%i", numFavs]];
            
            if([self.delegate respondsToSelector:@selector(favoriteAdded:)])
            {
                [self.delegate favoriteAdded:numFavs];
            }
            
        }
        
    }];

    
}

- (void)removeFarmer:(NSString *)farmerID AsFavorite:(NSString *)favoriteID
{
    [[self.ref child:[NSString stringWithFormat:@"users/%@/favorites/%@", self.user.uid, favoriteID]] removeValue];
    
    [[self.ref child:[NSString stringWithFormat:@"farms/%@/followers/%@", farmerID, favoriteID]] removeValue];
    
    
    FIRDatabaseReference *favoriteNumRef = [self.ref child:[NSString stringWithFormat:@"/farms/%@/numFavorites", farmerID]];
    
    [favoriteNumRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        if(snapshot.value == [NSNull null]) {
            NSLog(@"No messages");
            
        } else {
            
            NSString *numFavorites = snapshot.value;
            
            int numFavs = [numFavorites intValue];
            
            numFavs--;
            
            [favoriteNumRef setValue:[NSString stringWithFormat:@"%i", numFavs]];
            
        }
        
    }];
    
                           
}

#pragma mark Update Objects

- (void)updateEmail:(NSString *)string withPassword:(NSString *)password
{
    FIRDatabaseReference *userEmailRef = [self.ref child:@"/users/"];
    
   

    [[[userEmailRef queryOrderedByChild:@"email"] queryEqualToValue:string ]
     observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot2) {
         
         if(snapshot2.value == [NSNull null]) {
             
             
             
             if(self.provider == PASSWORD)
             {
                 [self.user updateEmail:self.email completion:^(NSError *_Nullable error) {
                     if(!error)
                         [[[[self.ref child:@"users/"]
                            child:self.user.uid] child:@"email/" ] setValue:string];
                     else
                         if([self.delegate respondsToSelector:@selector(emailFailure:)])
                         {
                             [self.delegate emailFailure:2];
                         }
                 }];
                 
             }
             else
             {
                 [[[[self.ref child:@"users/"]
                    child:self.user.uid] child:@"email/" ] setValue:string];
             }
     
             
         } else {
             
             if([self.delegate respondsToSelector:@selector(emailFailure:)])
             {
                 [self.delegate emailFailure:1];
             }
             
         }
         
     }];

    
}

- (void)updateFirstName:(NSString *)string
{
    
    [[[[self.ref child:@"users/"]
       child:self.user.uid] child:@"firstName/" ] setValue:string];
}

- (void)updateLastName:(NSString *)string
{
    
    [[[[self.ref child:@"users/"]
       child:self.user.uid] child:@"lastName/" ] setValue:string];
}

- (void)updateFarmName:(NSString *)string
{
    self.farmName = string;
    
    [[[[self.ref child:@"farms/"]
       child:self.user.uid] child:@"farmName/" ] setValue:string];
}

- (void)updateFarmDescription:(NSString *)string
{
    self.farmDescription = string;
    
    [[[[self.ref child:@"farms/"]
       child:self.user.uid] child:@"farmDescription/" ] setValue:string];
}

- (void)updateUseCustomProfileImage:(BOOL)useCustomImage
{
    self.useCustomProfileImage = useCustomImage;
    
    [[[[self.ref child:@"users/"]
       child:self.user.uid] child:@"useCustomProfileImage/" ] setValue:[NSString stringWithFormat:@"%i",useCustomImage]];
}

- (void)updateFarmerStatus:(BOOL)isFarmer
{
    self.isFarmer = isFarmer;
    
    [[[[self.ref child:@"users/"]
      child:self.user.uid] child:@"isFarmer/" ] setValue:[NSString stringWithFormat:@"%i",isFarmer]];
    
}

- (void)updateFollowerNotificationStatus:(BOOL)followerNotification
{
    self.followerNotification = followerNotification;
    
    [[[[self.ref child:@"farms/"]
       child:self.user.uid] child:@"followerNotification/" ] setValue:[NSString stringWithFormat:@"%i",followerNotification]];
}

- (void)updateReviewNotifcationStatus:(BOOL)reviewNotification
{
    self.reviewNotification = reviewNotification;
    
    [[[[self.ref child:@"farms/"]
       child:self.user.uid] child:@"reviewNotification/" ] setValue:[NSString stringWithFormat:@"%i",reviewNotification]];

}

- (void)updateUseChatStatus:(BOOL)useChat
{
    self.useChat = useChat;
    
    [[[[self.ref child:@"farms/"]
       child:self.user.uid] child:@"useChat/" ] setValue:[NSString stringWithFormat:@"%i",useChat]];
    
}

- (void)updateUseEmailStatus:(BOOL)useEmail
{
    self.useEmail = useEmail;
    
    [[[[self.ref child:@"farms/"]
       child:self.user.uid] child:@"useEmail/" ] setValue:[NSString stringWithFormat:@"%i",useEmail]];
    
}

- (void)updateUsePhoneStatus:(BOOL)useTelephone
{
    self.useTelephone = useTelephone;
    
    [[[[self.ref child:@"farms/"]
       child:self.user.uid] child:@"useTelephone/" ] setValue:[NSString stringWithFormat:@"%i",useTelephone]];
    
}

- (void)updateContactPhone:(NSString *)contactPhone
{
    self.contactPhone = contactPhone;
    
    [[[[self.ref child:@"farms/"]
       child:self.user.uid] child:@"contactPhone/" ] setValue:contactPhone];
    
}

- (void)updateContactEmail:(NSString *)contactEmail
{
    self.contactEmail = contactEmail;
    
    [[[[self.ref child:@"farms/"]
       child:self.user.uid] child:@"contactEmail/" ] setValue:contactEmail];
    
}

/*
- (void)saveNewUserDataToFirebase:(FAuthData *)authData
{
    NSArray *nameArray = [authData.providerData[@"displayName"] componentsSeparatedByString:@" "];
    
    NSDictionary *newUser = @{
                              @"provider": authData.provider,
                              @"firstName": [nameArray objectAtIndex:0],
                              @"lastName" : [nameArray objectAtIndex:1],
                              @"profileImage": authData.providerData[@"profileImageURL"],
                              @"email": authData.providerData[@"email"],
                              @"isFarmer":@"0"
                              };
    
    
    [[[self.ref child:@"users"]
      child:user.uid] setValue:newUser];
}
 */

- (void)saveFarmData:(NSDictionary *)farmData
{
    self.farmName = farmData[@"farmName"];
    self.farmDescription= farmData[@"farmDescription"];
   
    
    [[[self.ref child:@"farms"]
      child:self.user.uid] setValue:farmData];
    
}

- (void)removeLocationFromFarmer:(NSString *)locationID
{
    FIRDatabaseReference *locationRef =[[self.ref child:@"locations"] child:locationID];
    [locationRef removeValue];
    
    [self.geoFire removeKey:locationID];
    
    NSDictionary *tempScheduleDic = self.mySchedule;
    
    
    NSArray *allKeys = tempScheduleDic.allKeys;
    if(allKeys.count > 0)
    {
        
        for(NSString *key in allKeys)
        {
            NSDictionary * tempDay = [tempScheduleDic objectForKey:key];
            
            if([[tempDay objectForKey:@"locationID"] isEqualToString:locationID])
            {
                
                
                [[self.ref child:[NSString stringWithFormat:@"farms/%@/schedule/%@", self.user.uid, key]] removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                    
                    [self updateMySchedule];
                }];
            }
        }
        
        
    }
    

}

- (void)updateCityForUser:(CLLocation *)coords
{
    [self.geoFireCities setLocation:coords forKey:self.user.uid withCompletionBlock:^(NSError *error) {
        if (error != nil) {
            NSLog(@"An error occurred: %@", error);
        } else {
            NSLog(@"Saved location successfully!");
        }
    }];
}

- (void)updateAFarmLocation:(NSString *)locationID withData:(NSDictionary *)locationData andCoords:(CLLocation *)coords
{
    FIRDatabaseReference *locationRef = [self.ref child:[NSString stringWithFormat:@"locations/%@", locationID]];
    
    [locationRef setValue:locationData];
    
    [self.geoFire setLocation:coords
                       forKey:locationID withCompletionBlock:^(NSError *error) {
                           if (error != nil) {
                               NSLog(@"An error occurred: %@", error);
                           } else {
                               NSLog(@"Saved location successfully!");
                               
                               
                           }
                       }];
    
    NSDictionary *tempScheduleDic = self.mySchedule;
    
    
    NSArray *allKeys = tempScheduleDic.allKeys;
    if(allKeys.count > 0)
    {
        
        for(NSString *key in allKeys)
        {
            NSDictionary * tempDay = [tempScheduleDic objectForKey:key];
            
            if([[tempDay objectForKey:@"locationID"] isEqualToString:locationID])
            {
                
                [[self.ref child:[NSString stringWithFormat:@"farms/%@/schedule/%@/", self.user.uid, key]]updateChildValues:@{@"locationName" : locationData[@"locationName"]} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                    
                    [self updateMySchedule];
                    
                }];
                
               
            }
        }
        
        
    }

}

- (void)addLocationToFarm:(NSDictionary *)locationData withCoords:(CLLocation *)coords
{
    FIRDatabaseReference *locationRef =[[self.ref child:@"locations"]childByAutoId];
    
    NSString *locationID = locationRef.key;
    
    [locationRef setValue:locationData];
    
   
    [self.geoFire setLocation:coords
                  forKey:locationID withCompletionBlock:^(NSError *error) {
                      if (error != nil) {
                          NSLog(@"An error occurred: %@", error);
                      } else {
                          NSLog(@"Saved location successfully!");
                      }
                  }];
  
    
}
 
- (NSString *)addProductToFarm:(NSDictionary *)productData
{
    FIRDatabaseReference *product = [[self.ref child:@"products"]childByAutoId];
    
    NSString *productID = product.key;
                                     
        [product setValue:productData withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        
        if([self.delegate respondsToSelector:@selector(newProductAdded:)])
        {
            [self.delegate newProductAdded:error];
        }
            
            [FIRAnalytics logEventWithName:@"New_Product_Posted" parameters:@{
                                                                              @"farmerID" : self.user.uid
                                                                                  }];
        
    }];
    
    
    NSDictionary *notificaiton = @{
                                   @"farmerID" : productData[@"farmerID"],
                                   @"alertText" : [NSString stringWithFormat:@"%@ just added %@", self.farmName, productData[@"productHeadline"]],
                                   @"fromUserID" : self.user.uid,
                                   @"alertExpireDate" : productData[@"expireDate"],
                                   @"alertTimeSent" : @"",
                                   @"alertType" : @"1",
                                   @"farmName" : self.farmName,
                                   @"productID" : productID
                                   
                                   };
    
    [[[self.ref child:@"alert_queue"]childByAutoId]setValue:notificaiton withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        [FIRAnalytics logEventWithName:@"Notification_Sent" parameters:@{
                                                                         @"Notification_Type" : @"Product Posted Alert"
                                                                         
                                                                         }];
    }];
    
   
    
    return productID;
}

- (void)updateProduct:(NSString *)productID withData:(NSDictionary *)productData
{
    FIRDatabaseReference *product = [[self.ref child:@"products/"]child:productID];
    [product updateChildValues:productData withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if([self.delegate respondsToSelector:@selector(newProductAdded:)])
        {
            [self.delegate newProductAdded:error];
        }
    }];
    
}

- (void)removeScheduleForDay:(NSString *)day
{
    [[self.ref child:[NSString stringWithFormat:@"farms/%@/schedule/%@", self.user.uid, day]] removeValue];
}

- (void)updateMySchedule
{
    [[self.ref child:[NSString stringWithFormat:@"farms/%@/", self.user.uid]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if(snapshot.value == [NSNull null]) {
            self.mySchedule = nil;
        }
        else
        {
            NSLog(@"%@", snapshot.value);
            if([[snapshot.value objectForKey:@"schedule"] isKindOfClass:[NSArray class]])
            {
                NSArray *tempArray = [snapshot.value objectForKey:@"schedule"];
                NSMutableDictionary *tempdic = [[NSMutableDictionary alloc]init];
                NSLog(@"is Array");
                for(int i = 0; i < tempArray.count; i++)
                {
                    if([tempArray objectAtIndex:i] != [NSNull null])
                    {
                        [tempdic setObject:[tempArray objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d", i]];
                    }
                }
                self.mySchedule = tempdic;
            }
            else if([[snapshot.value objectForKey:@"schedule"] isKindOfClass:[NSDictionary class]])
            {
                self.mySchedule = (NSDictionary*)[snapshot.value objectForKey:@"schedule"];
            }
            else
                self.mySchedule = nil;
        }
        
        if([self.delegate respondsToSelector:@selector(updateMyScheduleComplete)])
        {
            [self.delegate updateMyScheduleComplete];
        }
    }];
}

- (void)addScheudle:(NSDictionary *)scheduleData
{
    [[self.ref child:[NSString stringWithFormat:@"farms/%@/schedule", self.user.uid]] updateChildValues:scheduleData];
}

- (void)addOverideSchedule:(NSDictionary *)overrideSchedule
{
   /* [[self.ref child:[NSString stringWithFormat:@"farms/%@/overrideSchedule", self.user.uid]] updateChildValues:overrideSchedule];*/
}

- (void)removeOverrideSchedule
{
     [[self.ref child:[NSString stringWithFormat:@"farms/%@/overrideSchedule", self.user.uid]] removeValue];
    
    self.overrideSchedule = nil;
}

- (void)updateUserStatus
{/*google
    GIDSignIn *googleSignIn = [GIDSignIn sharedInstance];
    
    
    if([googleSignIn currentUser])
    {
        self.isUserLoggedIn = YES;
        self.provider = GOOGLE;
        
        GIDGoogleUser *user = [googleSignIn currentUser];
        
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:user.authentication.idToken
                                         accessToken:user.authentication.accessToken];
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            if (error) {
                // Error authenticating with Firebase with OAuth token
            } else {
                // User is now logged in!
                NSLog(@"Successfully logged in! %@", user);
                
                [self setUserData];
                
            }
        }];
        
    }
    
    else */if([FBSDKAccessToken currentAccessToken])
    {
        self.isUserLoggedIn = YES;
        self.provider = FACEBOOK;
        
        FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                         credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                         .tokenString];
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                        if (error) {
                            NSLog(@"Login failed. %@", error);
                        } else {
                            NSLog(@"Logged in! %@", user);
                            
                            [self setUserData];

                        }
                    }];
        
    }
    else if([FIRAuth auth].currentUser)
    {
        self.isUserLoggedIn = YES;
        self.provider = PASSWORD;
        
        [self setUserData];
        
        
       
    }
    else
    {
        self.isUserLoggedIn = NO;
        
        
        if([self.delegate respondsToSelector:@selector(updateStatusComplete)])
        {
            [self.delegate updateStatusComplete];
        }

    }
    
}

- (NSArray *)getProductsForUser
{
    NSArray *products;
    
    FIRDatabaseReference *farmProductsRef = [self.ref child:@"/products"];
    
    
    [farmProductsRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot2) {
        
        if(snapshot2.value == [NSNull null]) {
            NSLog(@"No messages");
            
        } else {
            NSDictionary *value1 = snapshot2.value;
            NSArray *keys = value1.allKeys;
            NSMutableArray *values = [[NSMutableArray alloc]init];
            
            for(NSString *key in keys)
            {
                
                NSDictionary *tempDic = [value1 objectForKey:key];
                [values addObject:@{
                                    @"amount" : tempDic[@"amount"],
                                    @"amountDescription" : tempDic[@"amountDescription"],
                                    //@"category" : tempDic[@"category"],
                                    @"farmerID" : tempDic[@"farmerID"],
                                    @"productDescription" : tempDic[@"productDescription"],
                                    @"productHeadline" : tempDic[@"productHeadline"],
                                    @"productID" : key
                                    }];
                
            }
            
            self.farmLocations = values;
            
            if([self.delegate respondsToSelector:@selector(farmLocationsUpdated)])
            {
                [self.delegate farmLocationsUpdated];
            }
            
        }
        
    }];

    
    return products;
}

- (double)getDistanceFromUser:(CLLocation *)farmLocation
{
    CLLocationDistance distance = [ farmLocation distanceFromLocation: self.circleQuery.center];
    
    double miles = distance / 1609.344;
    return miles;
}

- (void)checkSearchCounter
{
    self.searchCounter--;
    
    if(self.searchCounter == 0)
    {
        //search completed
        self.searchStarted = NO;
        
        if([self.delegate respondsToSelector:@selector(geoSearchCompleted)])
        {
            [self.delegate geoSearchCompleted];
        }
        
        
    }
}

- (void)checkFavoriteCounter
{
    self.favoriteCounter--;
    
    if(self.favoriteCounter == 0)
    {
        if([self.delegate respondsToSelector:@selector(favoriteFarmersUpdated)])
        {
            [self.delegate favoriteFarmersUpdated];
        }
    }
}

#pragma mark Geo Search Methods

- (void)addProductsForFarmerID:(NSString *)farmerID distanceInfo:(NSDictionary *)distanceInfo
{
     //get all of the farmers products and display them @ this location
    
    FIRDatabaseReference *farmProductsRef = [self.ref child:@"/products"];
    
    self.searchCounter++;
    [[[farmProductsRef queryOrderedByChild:@"farmerID"] queryEqualToValue:farmerID]
     observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot2) {
         
         if(snapshot2.value == [NSNull null]) {
             NSLog(@"No messages");
             [self checkSearchCounter];
         } else {
             
             NSLog(@"%@ --- Number of Children - %lu",snapshot2.key, (unsigned long)snapshot2.childrenCount);
             
             NSDictionary *value1 = snapshot2.value;
             NSArray *keys = value1.allKeys;
             NSMutableArray *values = [[NSMutableArray alloc]init];
             double distanceToFarm = [distanceInfo[@"distanceToFarm"]doubleValue];
             NSString *distanceToFarmString = distanceInfo[@"distanceToFarmString"];
             NSLocale *usLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
             [dateFormatter setLocale:usLocale];
             [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
             
             
             
             for(NSString *key2 in keys)
             {
                 NSDictionary *tempDic = [value1 objectForKey:key2];
                 
                 BOOL isActive = [tempDic[@"isActive"]boolValue];
                 NSDate *expireDate = [dateFormatter dateFromString:tempDic[@"expireDate"]];
                 
                 if(isActive)
                 {
                     if([expireDate compare:[NSDate date]] == NSOrderedAscending)
                     {
                         /*[self makeProductInactive:key2 withUserID:tempDic[@"farmerID"] forProductNamed:tempDic[@"productHeadline"]];*/
                     }
                     else
                     {
                         BOOL match = NO;
                         
                         for(NSDictionary *tempDic2 in self.searchResults)
                         {
                             if([key2 isEqualToString:tempDic2[@"productID"]])
                             {
                                 match = YES;
                                 break;
                             }
                         }
                         if(!match)
                         {
                             [values addObject: @{
                                              @"amount" : tempDic[@"amount"],
                                              @"amountDescription" : tempDic[@"amountDescription"],
                                              //@"category" : tempDic[@"category"],
                                              @"farmerID" : tempDic[@"farmerID"],
                                              @"productDescription" : tempDic[@"productDescription"],
                                              @"productHeadline" : tempDic[@"productHeadline"],
                                              @"productID" : key2,
                                              @"distanceToFarmString" : distanceToFarmString,
                                              @"distanceToFarm" : [NSNumber numberWithDouble:distanceToFarm],
                                              @"datePosted" : tempDic[@"datePosted"]
                                              }];
                         }
                     }
                 }
                 
                 
                 
                 
                 
             }
             
             
             NSMutableArray *tempResults = [self.searchResults mutableCopy];
             
             
             BOOL recordInserted = NO;
             if(tempResults.count != 0)
             {
                 for(int i = 0; i < tempResults.count; i++)
                 {
                     NSNumber *number1 = [[tempResults objectAtIndex:i] objectForKey:@"distanceToFarm"];
                     
                     if(distanceToFarm < [number1 doubleValue])
                     {
                         NSRange range = NSMakeRange(i, values.count);
                         NSIndexSet *set = [[NSIndexSet alloc]initWithIndexesInRange:range];
                         [tempResults insertObjects:values atIndexes:set];
                         recordInserted = YES;
                         break;
                     }
                 }
             }
             else
             {
                 [tempResults addObjectsFromArray:values];
                 recordInserted = YES;
             }
             
             if(!recordInserted)
             {
                 [tempResults addObjectsFromArray:values];
             }
             
             self.searchResults = tempResults;
             
             if([self.delegate respondsToSelector:@selector(productAdded)])
             {
                 [self.delegate productAdded];
             }
         }
         
         [self checkSearchCounter];
         
     }];
    
}

- (void)checkScheduleOverrideWithFarmerData:(NSDictionary *)farmerData locationData:(NSDictionary *)locationData distanceInfo:(NSDictionary *)distanceInfo
{
    //find out if override is in effect
    
    BOOL pictureUpdated = [farmerData[@"pictureUpdated"]boolValue];
    NSString *temp = farmerData[@"farmerID"];
    
    FIRDatabaseReference *farmerRef = [self.ref child:[NSString stringWithFormat:@"/farms/%@/overrideSchedule", temp]];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@_farmProfile.png",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], temp];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* attrs = [fm attributesOfItemAtPath:pngFilePath error:nil];
    
    if (attrs != nil) {
        NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
        NSLog(@"Date Created: %@", [date description]);
        if([HelperMethods getTimeSinceFileCreated:[date description]])
        {
            NSLog(@"Removing Photo and redownloading");
            [[NSFileManager defaultManager] removeItemAtPath:pngFilePath error:nil];
        }
        
        
    }
    else {
        NSLog(@"Not found");
    }
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:pngFilePath] || pictureUpdated)
    {
        [HelperMethods downloadOtherUsersFarmProfileImageFromFirebase:temp];
    }
    
    
    self.searchCounter++;
    
    [farmerRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot3) {
        
        if(snapshot3.value == [NSNull null]) {
            //no override found
            //find out if the location is choosen for today
            NSLog(@"No messages");
            
            NSInteger weekday = [HelperMethods getWeekday];
            
            FIRDatabaseReference *scheduleRef = [self.ref child:[NSString stringWithFormat:@"/farms/%@/schedule/%ld", temp, (long)weekday]];
            
            [scheduleRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot3) {
                
                if(snapshot3.value == [NSNull null]) {
                    //No schedule found for this farm on this day.
                    
                    NSLog(@"No messages");
                    
                    [self.searchResultsLocations setObject:locationData forKey:farmerData[@"farmerID"]];
                    [self.searchResultsFarmers setObject:farmerData forKey:farmerData[@"farmerID"]];
                    
                    [self addProductsForFarmerID:farmerData[@"farmerID"] distanceInfo:distanceInfo];
                    
                    [self checkSearchCounter];
                } else {
                    
                    NSDictionary *value2 = snapshot3.value;
                    
                    NSDictionary *tempDic2 = value2;
                    
                    NSString *locationID = tempDic2[@"locationID"];
                    
                    if([locationID isEqualToString:locationData[@"locationID"]])
                    {
                        [self.searchResultsLocations setObject:locationData forKey:farmerData[@"farmerID"]];
                        [self.searchResultsFarmers setObject:farmerData forKey:farmerData[@"farmerID"]];
                        
                        [self addProductsForFarmerID:farmerData[@"farmerID"] distanceInfo:distanceInfo];
                    }
                    
                    
                    
                }
                [self checkSearchCounter];
            }];
            
        } else {
            
            //override found
            
            NSDictionary *value2 = snapshot3.value;
            
            NSDictionary *tempDic2 = value2;
            
            NSString *locationID = tempDic2[@"locationID"];
            
            if([locationID isEqualToString:locationData[@"locationID"]])
            {
                [self.searchResultsLocations setObject:locationData forKey:farmerData[@"farmerID"]];
                [self.searchResultsFarmers setObject:farmerData forKey:farmerData[@"farmerID"]];
                
                [self addProductsForFarmerID:farmerData[@"farmerID"] distanceInfo:distanceInfo];
            }
            
            [self checkSearchCounter];
            
        }
       
    }];
    
    
   
}

- (void)processLocation:(NSDictionary *)locationData distanceInfo:(NSDictionary *)distanceInfo
{
    //find farmer data for location entered
    
    NSString *temp = locationData[@"farmerID"];
    
    FIRDatabaseReference *farmerRef = [self.ref child:[NSString stringWithFormat:@"/farms/%@/", temp]];
    
    
    
    self.searchCounter++;
    
    [farmerRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot3) {
        
        if(snapshot3.value == [NSNull null]) {
            NSLog(@"No messages");
            
        } else {
            
            NSDictionary *value2 = snapshot3.value;
            
            NSDictionary *tempDic2 = value2;
            NSDictionary *schedule;
            NSString *activeLocation;
            NSMutableArray *locations = [[NSMutableArray alloc]init];
            
            
            if([tempDic2 objectForKey:@"schedule"])
            {
                if([[tempDic2 objectForKey:@"schedule"] isKindOfClass:[NSArray class]])
                {
                    NSArray *tempArray = [tempDic2 objectForKey:@"schedule"];
                    NSMutableDictionary *tempdic = [[NSMutableDictionary alloc]init];
                    NSLog(@"is Array");
                    for(int i = 0; i < tempArray.count; i++)
                    {
                        if([tempArray objectAtIndex:i] != [NSNull null])
                        {
                            if([HelperMethods getWeekday] == i)
                            {
                                activeLocation = [[tempArray objectAtIndex:i]objectForKey:@"locationID"];
                            }
                            [tempdic setObject:[tempArray objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d", i]];
                        }
                    }
                    schedule = tempdic;
                }
                else if([[tempDic2 objectForKey:@"schedule"] isKindOfClass:[NSDictionary class]])
                {
                    
                    schedule = (NSDictionary*)[tempDic2 objectForKey:@"schedule"];
                    activeLocation = [[schedule objectForKey:[NSString stringWithFormat:@"%ld",(long)[HelperMethods getWeekday]]]objectForKey:@"locationID"];
                }
                
                NSArray *keys = schedule.allKeys;
                
                for(NSString *key in keys)
                {
                    NSDictionary *dic = [schedule objectForKey:key];
                    
                    BOOL exists = NO;
                    
                    for(NSString *string in locations)
                    {
                        if([string isEqualToString:dic[@"locationID"]])
                        {
                            exists = YES;
                            break;
                        }
                    }
                    
                    if(!exists)
                        [locations addObject:dic[@"locationID"]];
                }
        
                if(locations.count > 0)
                {
                    self.searchCounter += (int)locations.count;
                    
                    for(NSString *location in locations)
                    {
                        
                        //get location data
                        
                        FIRDatabaseReference *farmerLocationRef = [self.ref child:[NSString stringWithFormat:@"/locations/%@", location]];
                        
                        
                        
                        [farmerLocationRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot4) {
                            
                            if(snapshot4.value == [NSNull null]) {
                                NSLog(@"No messages");
                                
                                
                            } else {
                                
                                NSDictionary *value3 = snapshot4.value;
                                
                                NSDictionary *tempDic3 = value3;
                                
                                CLLocation *farmLocation = [[CLLocation alloc]initWithLatitude:[tempDic3[@"latitude"] floatValue] longitude:[tempDic3[@"longitude"]floatValue]];
                               
                                double distanceToFarm = [self getDistanceFromUser:farmLocation];
                                
                                
                                NSString *distanceToFarmString;
                                if(distanceToFarm >= 50.0)
                                    distanceToFarmString = @">50 mi";
                                else
                                    distanceToFarmString = [NSString stringWithFormat:@"%0.2f mi", distanceToFarm];
                                
                                [self.searchResultsAllLocations setObject:@{
                                                                           @"farmerID" : tempDic3[@"farmerID"],
                                                                           @"fullAddress" : tempDic3[@"fullAddress"],
                                                                           @"latitude" : tempDic3[@"latitude"],
                                                                           @"longitude" : tempDic3[@"longitude"],
                                                                           @"locationName" : tempDic3[@"locationName"],
                                                                           @"locationID" : location,
                                                                           @"distanceToFarm" : [NSString stringWithFormat:@"%f",distanceToFarm],
                                                                           @"distanceToFarmString" : distanceToFarmString
                                                                           } forKey:location];
                                
                                
                                
                            }
                            [self checkSearchCounter];
                        }];
                        
                        
                    }
                    
                }
                
            }
            else
                schedule = [[NSDictionary alloc]init];
            
            
            if(!activeLocation)
                activeLocation = @"";
        
            
            [self checkScheduleOverrideWithFarmerData: @{
                                                         @"farmerID" : temp,
                                                         @"address" : @"",
                                                         @"city" : @"",
                                                         @"farmDescription" : tempDic2[@"farmDescription"],
                                                         @"farmName" : tempDic2[@"farmName"],
                                                         @"contactPhone" : tempDic2[@"contactPhone"],
                                                         @"rating" : tempDic2[@"rating"],
                                                         @"numReviews" :
                                                             tempDic2[@"numReviews"],
                                                         @"state" : tempDic2[@"state"],
                                                         @"zip" : @"",
                                                         @"followerNotification" : tempDic2[@"followerNotification"],
                                                         @"reviewNotification" : tempDic2[@"reviewNotification"],
                                                         @"useChat" : tempDic2[@"useChat"], @"useEmail" : tempDic2[@"useEmail"],
                                                         @"contactEmail" : tempDic2[@"contactEmail"],
                                                         @"useTelephone" : tempDic2[@"useTelephone"],
                                                         @"schedule" : schedule, @"activeLocation" : activeLocation, @"locations" : locations
                                                         } locationData:locationData distanceInfo:distanceInfo];
            
            
        }
        [self checkSearchCounter];
    }];
    
    
    
 
}

- (void)checkTimer
{
    if(self.searchStarted == YES)
    {
        //self.searchRetries++;
        
        self.searchCounter = 1;
        [self checkSearchCounter];
        
    }
}

- (void)startSerchTimer
{
    
    [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(checkTimer) userInfo:nil repeats:NO];
}

- (double)geoQueryforProducts:(CLLocation *)userLocation
{

    double radiusUsed;
    
    if(!self.searchStarted)
    {
        
        //[self startSerchTimer];
        [self.circleQuery removeAllObservers];
        self.searchStarted = YES;
        self.searchCounter = 0;
        self.userLocation = userLocation;
        
        CLLocation *center = userLocation;
        
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"savedRadius"]);
        
        if(self.isUserLoggedIn)
        {
            radiusUsed = self.searchRadius;
            NSLog(@"%f", self.searchRadius);
            self.circleQuery = [self.geoFire queryAtLocation:center withRadius:self.searchRadius];
        }
        else
        {
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"savedRadius"] && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"savedRadius"] isEqualToString:@""])
               {
                   double radius = [[[NSUserDefaults standardUserDefaults] objectForKey:@"savedRadius"]doubleValue];
                   radiusUsed = radius;
                   self.circleQuery = [self.geoFire queryAtLocation:center withRadius:radius];
               }
               else
               {
                   radiusUsed = self.searchRadius;
                   self.circleQuery = [self.geoFire queryAtLocation:center withRadius:self.searchRadius];
               }
            
            
        }
        self.searchCounter++;
        
    }
    [self.circleQuery observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        NSLog(@"Key '%@' entered the search area and is at location '%@'", key, location);
        
        double distanceToFarm = [self getDistanceFromUser:location];
        NSString *distanceToFarmString;
        if(distanceToFarm >= 50.0)
            distanceToFarmString = @">50 mi";
        else
            distanceToFarmString = [NSString stringWithFormat:@"%0.2f mi", distanceToFarm];
        
        //get location data
        
        FIRDatabaseReference *farmerLocationRef = [self.ref child:[NSString stringWithFormat:@"/locations/%@", key]];
        
        
        
        [farmerLocationRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot4) {
            self.searchCounter++;
            if(snapshot4.value == [NSNull null]) {
                NSLog(@"No messages");

                
            } else {
                
                NSDictionary *value3 = snapshot4.value;
                
                NSDictionary *tempDic3 = value3;
                
                [self processLocation: @{
                                         @"farmerID" : tempDic3[@"farmerID"],
                                         @"fullAddress" : tempDic3[@"fullAddress"],
                                         @"latitude" : tempDic3[@"latitude"],
                                         @"longitude" : tempDic3[@"longitude"],
                                         @"locationName" : tempDic3[@"locationName"],
                                         @"locationID" : key
                                         } distanceInfo:@{
                                                          @"distanceToFarm" : [NSString stringWithFormat:@"%f",distanceToFarm],
                                                          @"distanceToFarmString" : distanceToFarmString
                                                          }];
               
                
            }
            [self checkSearchCounter];
        }];
 
     
        
    }];
    
    [self.circleQuery observeEventType:GFEventTypeKeyExited withBlock:^(NSString *key, CLLocation *location) {
        NSLog(@"Key '%@' left the search area and is at location '%@'", key, location);
    }];
    
    [self.circleQuery observeEventType:GFEventTypeKeyMoved withBlock:^(NSString *key, CLLocation *location) {
        NSLog(@"Key '%@' moved in the search area and is at location '%@'", key, location);
    }];
    
    [self.circleQuery observeReadyWithBlock:^{
        NSLog(@"All initial data has been loaded and events have been fired!");
        
        //[self checkSearchCounter];
        
        [self startSerchTimer];
        
        if([self.delegate respondsToSelector:@selector(searchCompleted)])
        {
            [self.delegate searchCompleted];
        }
        
        
    }];
    
    return [self getCurrentSearchRadius];
 
}

- (void)stopSearchingForProducts
{
    [self.circleQuery removeAllObservers];
}


- (void)changeRadius:(float)radiusMiles
{
    double meters = (double)(radiusMiles * 1609.344) / (double)1000.0;
    if(self.isUserLoggedIn)
    {
        [[[[self.ref child:@"/users/"]
       child:self.user.uid] child:@"/searchRadius/" ] setValue:[NSString stringWithFormat:@"%f", meters]];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", meters] forKey:@"savedRadius"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    self.searchRadius = meters;
    
}

- (void)updateUserLocation:(CLLocation *)userLoc
{
    self.circleQuery.center = userLoc;
}


- (double)getCurrentSearchRadius
{
    double miles;
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"savedRadius"]);
    if(!self.isUserLoggedIn && [[NSUserDefaults standardUserDefaults] objectForKey:@"savedRadius"] && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"savedRadius"] isEqualToString:@""])
    {
        miles = ([[[NSUserDefaults standardUserDefaults] objectForKey:@"savedRadius"]floatValue] * 1000) / 1609.344;
    }
    else
      miles = (self.searchRadius * 1000) / 1609.344;
    return miles;
}

- (int)getFarmerRating:(NSString *)farmerID
{
    
    
    if([self.searchResultsFarmers objectForKey:farmerID])
    {
        return [[[self.searchResultsFarmers objectForKey:farmerID]objectForKey:@"rating"]intValue];
    }
    else
        return 99;
}

- (NSDictionary *)getNextInLineLocation:(NSString *)locationID isFavorite:(BOOL)isFavorite
{
    if(isFavorite)
    {
        NSArray *locations = [[self.favoriteFarmersData objectAtIndex:self.searchResultSelected] objectForKey:@"locations"];
        BOOL getNext = NO;
        
        for(int i = 0; i < locations.count; i++)
        {
            NSString *location = [locations objectAtIndex:i];
            
            if(getNext)
                return [self.favoriteFarmersLocations objectForKey:[locations objectAtIndex:i]];
            
            
            if([location isEqualToString:locationID])
            {
                if(i == locations.count -1)
                    return [self.favoriteFarmersLocations objectForKey:[locations objectAtIndex:0]];
                else
                    getNext = YES;
            }
            
        }
    }
    else
    {
        NSArray *locations = [[self.searchResultsFarmers objectForKey:[[self.searchResults objectAtIndex:self.searchResultSelected] objectForKey:@"farmerID"]]objectForKey:@"locations"];
        BOOL getNext = NO;
        
        for(int i = 0; i < locations.count; i++)
        {
            NSString *location = [locations objectAtIndex:i];
            
            if(getNext)
                return [self.searchResultsAllLocations objectForKey:[locations objectAtIndex:i]];
            
            
            if([location isEqualToString:locationID])
            {
                if(i == locations.count -1)
                    return [self.searchResultsAllLocations objectForKey:[locations objectAtIndex:0]];
                else
                    getNext = YES;
            }
            
        }
        
    }
    
    return nil;
    
        
}

- (NSDictionary *)getLocationSelectedIsFavorite:(BOOL)isFavorite
{
    if(isFavorite)
    {
        if(![[[self.favoriteFarmersData objectAtIndex:self.searchResultSelected] objectForKey:@"activeLocation"] isEqualToString:@""])
            
            return [self.favoriteFarmersLocations objectForKey:[[self.favoriteFarmersData objectAtIndex:self.searchResultSelected] objectForKey:@"activeLocation"]];
        else
        {
            NSArray *locations = [[self.favoriteFarmersData objectAtIndex:self.searchResultSelected] objectForKey:@"locations"];
            if(locations.count > 0)
                return [self.favoriteFarmersLocations objectForKey:[locations objectAtIndex:0]];
            else
                return nil;
        }
        
    }
    else
    {
        NSDictionary *farmerSelected = [self.searchResultsFarmers objectForKey:[[self.searchResults objectAtIndex:self.searchResultSelected] objectForKey:@"farmerID"]];
        
        if(![farmerSelected[@"activeLocation"] isEqualToString:@""])
        {
            return [self.searchResultsAllLocations objectForKey:farmerSelected[@"activeLocation"]];
        }
        else
        {
            return [self.searchResultsLocations objectForKey:[[self.searchResults objectAtIndex:self.searchResultSelected] objectForKey:@"farmerID"]];
        }
    }
    
}

- (NSDictionary *)getFarmerSelectedIsFavorite:(BOOL)isFavorite
{
    if(isFavorite)
    return [self.favoriteFarmersData objectAtIndex:self.searchResultSelected];
    else
    return [self.searchResultsFarmers objectForKey:[[self.searchResults objectAtIndex:self.searchResultSelected] objectForKey:@"farmerID"]];
}

- (BOOL)setSelectedFromFavoritesProductByProductID:(NSString *)productID
{
    BOOL wasSelected = NO;
    
    for(int i = 0 ; i < self.selectedFarmersProducts.count; i++)
    {
        NSDictionary *tempDic = [self.selectedFarmersProducts objectAtIndex:i];
        if([tempDic[@"productID"] isEqualToString:productID])
        {
            self.favoriteProductSelected = i;
            wasSelected = YES;
            break;
        }
    }
    
    return wasSelected;
}

- (BOOL)setSelectedProductByProductID:(NSString *)productID
{
    BOOL wasSelected = NO;
    
    for(int i = 0 ; i < self.searchResults.count; i++)
    {
        NSDictionary *tempDic = [self.searchResults objectAtIndex:i];
        if([tempDic[@"productID"] isEqualToString:productID])
        {
            self.searchResultSelected = i;
            wasSelected = YES;
            break;
        }
    }
    
    return wasSelected;
}

- (NSDictionary *)getProductSelectedIsFavorite:(BOOL)isFavorite
{
    if(isFavorite)
        return [self.selectedFarmersProducts objectAtIndex:self.favoriteProductSelected];
    else
        return [self.searchResults objectAtIndex:self.searchResultSelected];
}

- (void)getProductsOfSelectedFarmerIsFavorite:(BOOL)isFavorite
{
   
    NSString *farmerID;
    if(isFavorite)
        farmerID = [[self.favoriteFarmersData objectAtIndex:self.searchResultSelected] objectForKey:@"farmerID"];
    else
        farmerID = [[self.searchResults objectAtIndex:self.searchResultSelected] objectForKey:@"farmerID"];
    
    
    
    FIRDatabaseReference *farmProductsRef = [self.ref child:@"/products"];
    
    
    [[[farmProductsRef queryOrderedByChild:@"farmerID"] queryEqualToValue:farmerID]
     observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot2) {
        
        if(snapshot2.value == [NSNull null]) {
            NSLog(@"No messages");
            
        } else {
            NSDictionary *value1 = snapshot2.value;
            NSArray *keys = value1.allKeys;
            NSMutableArray *values = [[NSMutableArray alloc]init];
            
            for(NSString *key in keys)
            {
                
                
                NSDictionary *tempDic = [value1 objectForKey:key];
   
                CLLocation *location = [[CLLocation alloc]initWithLatitude:[[tempDic objectForKey:@"latitude"] floatValue] longitude:[[tempDic objectForKey:@"longitude"]floatValue]];
                
                double distanceToFarm = [self getDistanceFromUser:location];
  
                NSString *distanceToFarmString;
                if(distanceToFarm >= 50.0)
                    distanceToFarmString = @">50 mi";
                else
                    distanceToFarmString = [NSString stringWithFormat:@"%0.2f mi", distanceToFarm];
                
                [values addObject:@{
                                    @"amount" : tempDic[@"amount"],
                                    @"amountDescription" : tempDic[@"amountDescription"],
                                    //@"category" : tempDic[@"category"],
                                    @"farmerID" : tempDic[@"farmerID"],
                                    @"productDescription" : tempDic[@"productDescription"],
                                    @"productHeadline" : tempDic[@"productHeadline"],
                                    @"productID" : key,
                                    @"distanceToFarmString" : distanceToFarmString,
                                    @"distanceToFarm" : [NSNumber numberWithDouble:distanceToFarm],
                                    @"datePosted" : tempDic[@"datePosted"],
                                    @"isActive" : tempDic[@"isActive"]
                                    }];
                
            }
            
            self.selectedFarmersProducts = values;
            
            if([self.delegate respondsToSelector:@selector(farmerProductsLoadComplete)])
            {
                [self.delegate farmerProductsLoadComplete];
            }
            
        }
        
    }];
    
   
}

- (void)addUserToFarmersChatList:(NSString *)farmerID isFavoriting:(BOOL)isFavoriting
{
    if(!isFavoriting)
    {
        FIRDatabaseReference *chatListRef =[[[self.ref child:@"farms/"]child:farmerID]child:@"chatList/"];
    
    
        [chatListRef updateChildValues:@{self.user.uid : self.user.uid }];
    }
    
    FIRDatabaseReference *chatListRef2 = [[[self.ref child:@"users/"]child:self.user.uid]child:@"chatList/"];
    
    [chatListRef2 updateChildValues:@{farmerID : farmerID}];
}

- (void)getChatFollowers
{
    
}

- (void)updateChatList
{
    if(self.isFarmer)
    {
        [self getChatFollowers];
    }
}

- (NSMutableArray *)getFarmersThatChat
{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    
    for(NSDictionary *farmer in self.favoriteFarmersData)
    {
        if([farmer[@"useChat"] boolValue])
        {
            [tempArray addObject:farmer];
        }
    }
    
    return tempArray;
}

- (void)updateFavoriteFarmersData
{
    
    self.favoriteFarmersData = [[NSMutableArray alloc]init];
    
    NSArray *favoriteKeys = self.favorites.allKeys;
    
    FIRDatabaseReference *farmerRef = [self.ref child:@"/farms"];
    
    self.favoriteCounter += (int)favoriteKeys.count;
    
    for(NSString *key in favoriteKeys)
    {
        
      
        
        [[farmerRef child:key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot3) {
            
            if(snapshot3.value == [NSNull null]) {
                NSLog(@"No messages");
                
            } else {
                
                NSDictionary *value2 = snapshot3.value;
                
                NSDictionary *tempDic2 = value2;
                NSDictionary *schedule;
                NSString *activeLocation;
                NSMutableArray *locations = [[NSMutableArray alloc]init];
                
                if([tempDic2 objectForKey:@"schedule"])
                {
                    if([[tempDic2 objectForKey:@"schedule"] isKindOfClass:[NSArray class]])
                    {
                        NSArray *tempArray = [tempDic2 objectForKey:@"schedule"];
                        NSMutableDictionary *tempdic = [[NSMutableDictionary alloc]init];
                        NSLog(@"is Array");
                        for(int i = 0; i < tempArray.count; i++)
                        {
                            if([tempArray objectAtIndex:i] != [NSNull null])
                            {
                                if([HelperMethods getWeekday] == i)
                                {
                                    activeLocation = [[tempArray objectAtIndex:i]objectForKey:@"locationID"];
                                }
                                [tempdic setObject:[tempArray objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d", i]];
                            }
                        }
                        schedule = tempdic;
                    }
                    else if([[tempDic2 objectForKey:@"schedule"] isKindOfClass:[NSDictionary class]])
                    {
                        
                        schedule = (NSDictionary*)[tempDic2 objectForKey:@"schedule"];
                        activeLocation = [[schedule objectForKey:[NSString stringWithFormat:@"%ld",(long)[HelperMethods getWeekday]]]objectForKey:@"locationID"];
                    }
                    
                    NSArray *keys = schedule.allKeys;
                    
                    for(NSString *key in keys)
                    {
                        NSDictionary *dic = [schedule objectForKey:key];
                        
                        BOOL exists = NO;
                        
                        for(NSString *string in locations)
                        {
                            if([string isEqualToString:dic[@"locationID"]])
                            {
                                exists = YES;
                                break;
                            }
                        }
                        
                        if(!exists)
                           [locations addObject:dic[@"locationID"]];
                    }
                    
                    if(locations.count > 0)
                    {
                        self.favoriteCounter += (int)locations.count;
                        
                     for(NSString *location in locations)
                     {
                         
                         //get location data
                         
                         FIRDatabaseReference *farmerLocationRef = [self.ref child:[NSString stringWithFormat:@"/locations/%@", location]];
                         
                         
                         
                         [farmerLocationRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot4) {
                             
                             if(snapshot4.value == [NSNull null]) {
                                 NSLog(@"No messages");
                                 
                                 
                             } else {
                                 
                                 NSDictionary *value3 = snapshot4.value;
                                 
                                 NSDictionary *tempDic3 = value3;
                                 
                                 CLLocation *farmLocation = [[CLLocation alloc]initWithLatitude:[tempDic3[@"latitude"] floatValue] longitude:[tempDic3[@"longitude"]floatValue]];
                                 
                                 double distanceToFarm = [self getDistanceFromUser:farmLocation];
                                 
                                 NSString *distanceToFarmString;
                                 if(distanceToFarm >= 50.0)
                                     distanceToFarmString = @">50 mi";
                                 else
                                     distanceToFarmString = [NSString stringWithFormat:@"%0.2f mi", distanceToFarm];
                                 
                                 [self.favoriteFarmersLocations setObject:@{
                                                                            @"farmerID" : tempDic3[@"farmerID"],
                                                                            @"fullAddress" : tempDic3[@"fullAddress"],
                                                                            @"latitude" : tempDic3[@"latitude"],
                                                                            @"longitude" : tempDic3[@"longitude"],
                                                                            @"locationName" : tempDic3[@"locationName"],
                                                                            @"locationID" : location,
                                                                            @"distanceToFarm" : [NSString stringWithFormat:@"%f",distanceToFarm],
                                                                            @"distanceToFarmString" : distanceToFarmString
                                                                            } forKey:location];
                                 
                                 
                                
                             }
                            [self checkFavoriteCounter]; 
                         }];
                         
                         
                     }
                        
                    }
                    
                }
                else
                    schedule = [[NSDictionary alloc]init];
                
                if(!activeLocation)
                    activeLocation = @"";
                
                [self.favoriteFarmersData addObject: @{
                                                       @"farmerID" : key,
                                                       @"address" : tempDic2[@"address"],
                                                       @"city" : tempDic2[@"city"],
                                                       @"farmDescription" : tempDic2[@"farmDescription"],
                                                       @"farmName" : tempDic2[@"farmName"],
                                                       @"mainPhone" : tempDic2[@"mainPhone"],
                                                       @"rating" : tempDic2[@"rating"],
                                                       @"numReviews" :
                                                           tempDic2[@"numReviews"],
                                                       @"state" : tempDic2[@"state"],
                                                       @"zip" : tempDic2[@"zip"],
                                                       @"followerNotification" : tempDic2[@"followerNotification"],
                                                        @"reviewNotification" : tempDic2[@"reviewNotification"],
                                                       @"useChat" : tempDic2[@"useChat"], @"useEmail" : tempDic2[@"useEmail"],
                                                       @"contactEmail" : tempDic2[@"contactEmail"],
                                                       @"schedule" : schedule,
                                                       @"activeLocation" : activeLocation, @"locations" : locations
                                                       }];
                
                
                
            }
            [self checkFavoriteCounter];
        }];
        
    }
    
    
}

- (void)changeFavoriteFarmer:(NSString *)farmerID withNotificationStatus:(BOOL)isOn
{
    [[[[self.ref child:@"/users/"]
       child:self.user.uid] child:[NSString stringWithFormat:@"favorites/%@/getNotifications",[self.favorites[farmerID] objectForKey:@"favoriteID"]]] setValue:[NSString stringWithFormat:@"%i",isOn]];

}

- (BOOL)getNotificationStatusForFarmer:(NSString *)farmerID
{
    return [[self.favorites[farmerID] objectForKey:@"getNotifications"] boolValue];
}

- (void)updateCategories
{
    [[self.ref child:@"/categories/"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        if (snapshot.value == [NSNull null]) {
            // The value is null
        }
        else
        {
            NSDictionary *value1 = snapshot.value;
            
            
            NSDictionary *categories = value1;
            NSArray *categoryKeys = categories.allKeys;
            
            NSMutableArray * newCategories = [[NSMutableArray alloc]init];
            
            
            for(NSString *string in categoryKeys)
            {
                
                [newCategories addObject:[categories objectForKey:string]];
                
                
            }
            
            NSArray *temparray = [newCategories sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            
            NSMutableArray *array = [temparray mutableCopy];
            
            [array insertObject:@"Product Category Not Listed" atIndex:0];
            
            self.categories = array;
            
            
            if([self.delegate respondsToSelector:@selector(categoriesUpdated)])
            {
                [self.delegate categoriesUpdated];
            }
            
        }
        
    }];

}

- (void)addReview:(NSDictionary *)reviewData ToFarmer:(NSString *)farmerID
{
    
    [[[[self.ref child:[NSString stringWithFormat:@"farms/%@/reviews", farmerID]] queryOrderedByChild:@"reviewerID" ] queryEqualToValue:reviewData[@"reviewerID"] ] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        if (snapshot.value == [NSNull null]) {
            // The value is null
            NSLog(@"No results Found");
            [[[self.ref child:[NSString stringWithFormat:@"farms/%@/reviews", farmerID]] childByAutoId] updateChildValues:reviewData];
            
            [[self.ref child:[NSString stringWithFormat:@"farms/%@/", farmerID]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                
                if (snapshot.value == [NSNull null]) {
                    // The value is null
                }
                else
                {
                    NSDictionary *value1 = snapshot.value;
                    
                    
                    double ratingDouble = [value1[@"ratingDouble"]doubleValue];
                    int rating = [value1[@"rating"] intValue];
                    int numReviews = [value1[@"numReviews"] intValue];
                    
                    if(numReviews == 0)
                    {
                        rating = 0;
                        ratingDouble = 0.0;
                    }
                    
                    ratingDouble += [reviewData[@"reviewRating"]doubleValue];
                    numReviews++;
                    
                    if(numReviews != 0)
                    {
                        rating = (int)ratingDouble / (int)numReviews;
                    }
                    
                    
                    
                    NSDictionary *review = @{
                                             @"rating" : [NSString stringWithFormat:@"%i", rating],
                                             @"numReviews" : [NSString stringWithFormat:@"%i", numReviews],
                                             @"ratingDouble" : [NSString stringWithFormat:@"%f", ratingDouble]
                                             };
                    
                    [[self.ref child:[NSString stringWithFormat:@"farms/%@/", farmerID]]updateChildValues:review];
                    if([self.delegate respondsToSelector:@selector(reviewAddComplete:)])
                    {
                        [self.delegate reviewAddComplete:YES];
                    }
                    
                    
                    
                }
                
            }];
        }
        else
        {
           
            
            NSLog(@"Results Found");
            
            if([self.delegate respondsToSelector:@selector(reviewAddComplete:)])
            {
                [self.delegate reviewAddComplete:NO];
            }
            
        }
        
    }];
    
    

    
}

- (NSInteger)getNumberOfProducts
{
    return self.farmProducts.allKeys.count;
}

- (NSMutableArray *)getProductsArray
{
    NSMutableArray *productsArray = [[NSMutableArray alloc]init];
    NSArray *productKeys = self.farmProducts.allKeys;
    
     NSArray *sortedAllKeys = [productKeys sortedArrayUsingSelector:@selector(compare:)];
    
    for(NSString *key in sortedAllKeys)
    {
        [productsArray addObject:[self.farmProducts objectForKey:key]];
    }
    
    return productsArray;
}

- (void)makeProductInactive:(NSString *)productID withUserID:(NSString *)userID forProductNamed:(NSString *)productName
{
    FIRDatabaseReference *productRef = [[self.ref child:@"/products"] child:productID];
    [productRef updateChildValues:@{
                                    @"isActive" : @"0",
                                    @"expireDate" : @"",
                                    @"datePosted" : @""
                                    }];
    
    
}


- (void)deleteProductFromFirebase:(NSString *)productID
{
    FIRDatabaseReference *productDelRef = [[self.ref child:@"/products"] child:productID];
                                           
    [productDelRef removeValue];
    
    FIRDatabaseReference *alertQueueRef = [self.ref child:@"/alert_queue"];
    
    [[[alertQueueRef queryOrderedByChild:@"productID"] queryEqualToValue:productID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.value == [NSNull null]) {
            // The value is null
        }
        else
        {
            NSDictionary *value1 = snapshot.value;
            
            
            NSArray *keys = value1.allKeys;
            
            for(NSString *key in keys)
            {
                FIRDatabaseReference *alertDeleteRef = [[self.ref child:@"/alert_queue"]child:key];
                
                [alertDeleteRef removeValue];
            }
            
            
        }
        
    }];
    
    
}

- (void)clearNotifications
{
    self.notifications = [[NSMutableArray alloc]init];
}

- (void)getUsersNotifications
{
    for(NSDictionary *favorite in self.favoriteFarmersData)
    {
        FIRDatabaseReference *notificaitons = [self.ref child:@"/alert_queue"];
        
        
        
        
        [[[notificaitons queryOrderedByChild:@"farmerID"] queryEqualToValue:favorite[@"farmerID"]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot2) {
            
            if(snapshot2.value == [NSNull null]) {
                NSLog(@"No messages");
                
                
            } else {
                NSDictionary *value1 = snapshot2.value;
                NSArray *keys = value1.allKeys;
                NSLocale *usLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                
                for(NSString *key in keys)
                {
                    NSDictionary *tempDic = [value1 objectForKey:key];
                    [dateFormatter setLocale:usLocale];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
                    
                    NSDate *expireDate = [dateFormatter dateFromString:tempDic[@"alertExpireDate"]];
                    
                    
                    if([expireDate compare:[NSDate date]] == NSOrderedDescending && [tempDic[@"alertType"]intValue] == 1)
                    {
                        [self.notifications addObject:@{
                                                        @"alertText" : tempDic[@"alertText"],
                                                        @"farmName" : tempDic[@"farmName"],
                                                        @"alertTimeSent" : tempDic[@"alertTimeSent"],
                                                        @"productID" : tempDic[@"productID"],
                                                        @"fromUserID" : tempDic[@"fromUserID"]
                                                        }];
                    }
                }
                
               
                
                
                
            
                
                
            }
            NSLog(@"%@", self.farmProducts);
            if([self.delegate respondsToSelector:@selector(notificationsLoaded:)])
            {
                [self.delegate notificationsLoaded:self.notifications];
            }
            
        }];
    }
}

- (void)loadSingleProductFromDatabase
{
    
}

- (void)updateNotificationsStatus:(NSString *)userIDSelected
{
    
    FIRDatabaseReference *userNotificationRef = [self.ref child:[NSString stringWithFormat:@"/notification/%@", self.user.uid]];
    [userNotificationRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot2) {
        
        if(snapshot2.value == [NSNull null]) {
            NSLog(@"No messages");
            
        } else {
            NSDictionary *value1 = snapshot2.value;
            NSArray *keys = value1.allKeys;
            
            BOOL match = false;
            NSString *matchedKey;
            for(NSString *key in keys)
            {
                NSDictionary *tempDic = [value1 objectForKey:key];
                if([[tempDic objectForKey:@"userID"] isEqualToString:userIDSelected])
                {
                    match = true;
                    matchedKey = key;
                    break;
                    
                }
            }
            
            if(match)
            {
                FIRDatabaseReference *notification = [userNotificationRef child:matchedKey];
                [notification removeValue];
            }
        }
        
    }];
}

@end
