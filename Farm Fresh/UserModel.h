//
//  UserModel.h
//  Farm Fresh
//
//  Created by Randall Rumple on 3/11/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Firebase.h"
#import "GeoFire.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
/* google
#import <GoogleSignIn/GoogleSignIn.h>
*/

@protocol UserModelDelegate;

@interface UserModel : NSObject

@property (nonatomic, weak) id<UserModelDelegate> delegate;

@property (nonatomic) int favoriteSearchTimerCount;
@property (nonatomic) BOOL isSearchTimerRunning;
@property (nonatomic) int provider;
@property (nonatomic) BOOL isUserLoggedIn;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *mainPhone;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *farmName;
@property (nonatomic, strong) NSString *farmDescription;
@property (nonatomic, strong) NSArray *farmLocations;
@property (nonatomic, strong) NSMutableDictionary *farmProducts;
@property (nonatomic) BOOL useCustomProfileImage;

@property (nonatomic) BOOL isFarmer;
@property (nonatomic) BOOL isAdmin;
@property (nonatomic, strong) FIRDatabaseReference *ref;
@property (nonatomic, strong) FIRUser *user;
@property (nonatomic, strong) FIRStorageReference *storageRef;
@property (nonatomic, strong) GeoFire *geoFire;
@property (nonatomic, strong) GeoFire *geoFireCities;
@property (nonatomic, strong) CLLocation *userLocation;

@property (nonatomic) int searchCounter;

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic) NSInteger searchResultSelected;
@property (nonatomic) NSInteger favoriteProductSelected;
@property (nonatomic, strong) NSMutableDictionary *searchResultsFarmers;
@property (nonatomic, strong) NSMutableDictionary *searchResultsLocations;
@property (nonatomic, strong) NSMutableDictionary *searchResultsAllLocations;
@property (nonatomic) BOOL searchStarted;
@property (nonatomic, strong) NSArray *selectedFarmersProducts;

@property (nonatomic, strong) NSDictionary *favorites;
@property (nonatomic, strong) NSMutableArray *favoriteFarmersData;
@property (nonatomic, strong) NSMutableDictionary *favoriteFarmersLocations;
@property (nonatomic) double searchRadius;
@property (nonatomic, strong) NSArray *categories;

@property (nonatomic, strong) NSString *rating;

@property (nonatomic) int numReviews;
@property (nonatomic, strong) NSString *contactPhone;
@property (nonatomic, strong) NSString *contactEmail;
@property (nonatomic) BOOL useChat;
@property (nonatomic) BOOL useEmail;
@property (nonatomic) BOOL useTelephone;
@property (nonatomic) BOOL followerNotification;
@property (nonatomic) BOOL reviewNotification;
@property (nonatomic, strong) NSString *numFavorites;
@property (nonatomic, strong) NSDictionary *mySchedule;
@property (nonatomic, strong) NSDictionary *overrideSchedule;
@property (nonatomic, strong) NSMutableArray *chatFollowers;
@property (nonatomic, strong) NSMutableArray *chatList;
@property (nonatomic, strong) NSMutableArray * notifications;
@property (nonatomic, strong) NSDictionary *singleProductSearchResult;

- (void)updateUserStatus;
- (void)userSignedOut;
- (void)saveFarmData:(NSDictionary *)farmData;
- (void)updateFarmName:(NSString *)string;
- (void)updateFarmerStatus:(BOOL)isFarmer;
- (void)updateUseCustomProfileImage:(BOOL)useCustomImage;
- (void)updateFarmDescription:(NSString *)string;
- (void)updateCityForUser:(CLLocation *)coords withCityName:(NSString *)cityName;
- (void)addLocationToFarm:(NSDictionary *)locationData withCoords:(CLLocation *)coords;
- (double)geoQueryforProducts:(CLLocation *)userLocation;
- (void)updateUserLocation:(CLLocation *)userLoc;
 - (void)stopSearchingForProducts;

- (NSString *)addProductToFarm:(NSDictionary *)productData;
- (void)updateProduct:(NSString *)productID withData:(NSDictionary *)productData;

- (void)checkSearchTimer;
- (void)changeRadius:(float)radius;

- (double)getCurrentSearchRadius;
- (int)getFarmerRating:(NSString *)farmerID;
- (NSDictionary *)getLocationSelectedIsFavorite:(BOOL)isFavorite;
- (NSDictionary *)getFarmerSelectedIsFavorite:(BOOL)isFavorite;
- (NSDictionary *)getProductSelectedIsFavorite:(BOOL)isFavorite;
- (BOOL)setSelectedProductByProductID:(NSString *)productID;
- (BOOL)setSelectedFromFavoritesProductByProductID:(NSString *)productID;
- (void)getProductsOfSelectedFarmerIsFavorite:(BOOL)isFavorite;
- (void)updateFirstName:(NSString *)string;
- (void)updateLastName:(NSString *)string;
- (void)updateEmail:(NSString *)string withPassword:(NSString *)password;
- (void)addFarmerAsAFavorite:(NSDictionary *)farmerData;
- (void)removeFarmer:(NSString *)farmerID AsFavorite:(NSString *)favoriteID;
- (void)updateFavoriteFarmersData;
- (void)changeFavoriteFarmer:(NSString *)farmerID withNotificationStatus:(BOOL)isOn;
- (BOOL)getNotificationStatusForFarmer:(NSString *)farmerID;
- (void)updateCategories;
- (void)updateMySchedule;
- (void)removeScheduleForDay:(NSString *)day;
- (void)addScheudle:(NSDictionary *)scheduleData;
- (void)addOverideSchedule:(NSDictionary *)overrideSchedule;
- (void)removeOverrideSchedule;
- (void)removeLocationFromFarmer:(NSString *)locationID;
- (NSArray *)getFarmersThatChat;
- (void)addUserToFarmersChatList:(NSString *)farmerID isFavoriting:(BOOL)isFavoriting;
- (void)updateFollowerNotificationStatus:(BOOL)followerNotification;
- (void)updateReviewNotifcationStatus:(BOOL)reviewNotification;
- (void)updateUseChatStatus:(BOOL)useChat;
- (void)updateUseEmailStatus:(BOOL)useEmail;
- (void)updateUsePhoneStatus:(BOOL)useTelephone;
- (void)updateContactPhone:(NSString *)contactPhone;
- (void)updateContactEmail:(NSString *)contactEmail;
- (NSDictionary *)getNextInLineLocation:(NSString *)locationID isFavorite:(BOOL)isFavorite;
- (void)updateAFarmLocation:(NSString *)locationID withData:(NSDictionary *)locationData andCoords:(CLLocation *)coords;

- (void)addReview:(NSDictionary *)reviewData ToFarmer:(NSString *)farmerID;

- (NSInteger)getNumberOfProducts;
- (NSMutableArray *)getProductsArray;
- (void)makeProductInactive:(NSString *)productID withUserID:(NSString *)userID forProductNamed:(NSString *)productName;
- (void)deleteProductFromFirebase:(NSString *)productID;
- (void)clearNotifications;
- (void)getUsersNotifications;
- (void)loadSingleProductFromDatabase;
- (void)updateNotificationsStatus:(NSString *)userIDSelected;

-(void)addFacebookPostIDToProduct:(NSString *)productID withPostID:(NSString *)postID;

@end

@protocol UserModelDelegate <NSObject>
@optional
- (void)updateStatusComplete;
- (void)updateStatusUpdate:(int)statusCode;
- (void)farmLocationsUpdated;
- (void)farmProductUpdated;
- (void)readyToUpdateLocation;
- (void)productAdded;
- (void)geoSearchCompleted;
- (void)farmerProductsLoadComplete;
- (void)farmerProfileUpdated;
- (void)nameUpdated:(int) nameType;
- (void)emailFailure:(int) failCode;
- (void)favoriteFarmersUpdated;
- (void)categoriesUpdated;
- (void)newProductAdded:(NSError *) error;
- (void)locationRemoved;
- (void)favoriteAdded:(int) numFavorites;
- (void)reviewAddComplete:(bool) wasSuccessful;
- (void)notificationsLoaded:(NSArray *)notificaitons;
- (void)updateMyScheduleComplete;
- (void)searchCompleted;
- (void)postStatusMessage:(NSString *)message;
- (void)favoriteFarmersUpdateFailed;
- (void)cityUpdated;
@required

@end



