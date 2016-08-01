//
//  AppDelegate.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/5/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "HomeViewController.h"
#import "ChatMessagesViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    NSString *finalToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:finalToken forKey:USER_PUSH_NOTIFICATION_PIN];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    if(finalToken && self.userData.isUserLoggedIn)
        [[[self.userData.ref child:@"/users/"] child:self.userData.user.uid] updateChildValues:@{@"pushPin" : finalToken}];
    
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token, error: %@", error);
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    UIApplicationState state = application.applicationState;
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:ADLoadDataNotification object:nil userInfo:nil];
    
    //BOOL sendLocalNotification = false;
    
    if(state == UIApplicationStateActive)
    {
        
        NSString *title = @"";
        
        NSString *alertType = [[userInfo valueForKey:@"aps"]valueForKey:@"alertType"];
        UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
        
        if([alertType intValue] != 2 && ![navController.visibleViewController isKindOfClass:[ChatMessagesViewController class]])
        {
            switch ([alertType intValue]) {
                case 1: title = @"New Product Posted";
                    break;
                case 2: title = @"Chat Notification";
                    break;
                case 3: title = @"New Follower Notification";
                    break;
                case 4: title = @"Product Posted Notification";
                    break;
                case 5: title = @"Product Expired Notificaiton";
                    break;
                case 6: title = @"Product Review Notification";
                    break;
            }
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:title
                                                  message:[[userInfo valueForKey:@"aps"]valueForKey:@"alert"]
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:@"Dismiss"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
            [alertController addAction: okAction];
            
            UIAlertAction *productAction;
            UIAlertAction *chatAction;
            UIAlertAction *expiredAction;
            UIAlertAction *reviewAction;
            
            
            
            
            if([alertType intValue] == 1)
            {
                productAction = [UIAlertAction
                                 actionWithTitle:@"View Product"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:SCREEN_TO_LOAD];
                                     [[NSUserDefaults standardUserDefaults]synchronize];
                                     [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"productID"] forKey:@"productID"];
                                     [[NSUserDefaults standardUserDefaults]synchronize];
                                     [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"fromUserID"] forKey:@"fromUserID"];
                                     [[NSUserDefaults standardUserDefaults]synchronize];
                                     
                                     [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:ALERT_RECIEVED];
                                     [[NSUserDefaults standardUserDefaults]synchronize];
                                     
                                    
                                     
                                     if([navController.visibleViewController isKindOfClass:[HomeViewController class]])
                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessNotification" object:nil userInfo:nil];
                                     else
                                         [navController.visibleViewController.navigationController popToRootViewControllerAnimated:NO];
                                     
                                 }];
                [alertController addAction: productAction];
                 [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
            }
            else if ([alertType intValue] == 2)
            {
        
                
                    chatAction = [UIAlertAction
                                  actionWithTitle:@"View Message"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      NSString *name = @"";
                                      [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:SCREEN_TO_LOAD];
                                      [[NSUserDefaults standardUserDefaults]synchronize];
                                      [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"fromUserID"] forKey:@"fromUserID"];
                                      [[NSUserDefaults standardUserDefaults]synchronize];
                                      [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"userType"] forKey:@"userType"];
                                      [[NSUserDefaults standardUserDefaults]synchronize];
                                      
                                      
                                      
                                      name = [[userInfo valueForKey:@"aps"]valueForKey:@"alert"];
                                      name = [name stringByReplacingOccurrencesOfString: @" has sent you a message." withString:@""];
                                      
                                      [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"fromUserIDName"];
                                      [[NSUserDefaults standardUserDefaults]synchronize];
                                      [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:ALERT_RECIEVED];
                                      [[NSUserDefaults standardUserDefaults]synchronize];
                                      
                                      
                                      if([navController.visibleViewController isKindOfClass:[HomeViewController class]])
                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessNotification" object:nil userInfo:nil];
                                      else
                                          [navController.visibleViewController.navigationController popToRootViewControllerAnimated:NO];
                                  }];
                    
                    [alertController addAction: chatAction];
                     [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
                
            }
            else if([alertType intValue] == 5)
            {
                expiredAction = [UIAlertAction
                              actionWithTitle:@"View Expired Products"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction *action)
                              {
                                
                                  [[NSUserDefaults standardUserDefaults] setObject:@"4" forKey:SCREEN_TO_LOAD];
                                  [[NSUserDefaults standardUserDefaults]synchronize];
                                  
                                 
                                  [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:ALERT_RECIEVED];
                                  [[NSUserDefaults standardUserDefaults]synchronize];
                                  
                                  
                                  if([navController.visibleViewController isKindOfClass:[HomeViewController class]])
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessNotification" object:nil userInfo:nil];
                                  else
                                      [navController.visibleViewController.navigationController popToRootViewControllerAnimated:NO];
                              }];
                
                [alertController addAction: expiredAction];
                [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
            }
            else if([alertType intValue] == 6)
            {
                reviewAction = [UIAlertAction
                                 actionWithTitle:@"View Farm Reviews"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     
                                     [[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:SCREEN_TO_LOAD];
                                     [[NSUserDefaults standardUserDefaults]synchronize];
                                     
                                     
                                     [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:ALERT_RECIEVED];
                                     [[NSUserDefaults standardUserDefaults]synchronize];
                                     
                                     
                                     if([navController.visibleViewController isKindOfClass:[HomeViewController class]])
                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessNotification" object:nil userInfo:nil];
                                     else
                                         [navController.visibleViewController.navigationController popToRootViewControllerAnimated:NO];
                                 }];
                
                [alertController addAction: reviewAction];
                [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
            }
            else
                 [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
        }
        
    
       
  
        
    }
    else
    {
        
        
        
        NSString *alertType = [[userInfo valueForKey:@"aps"]valueForKey:@"alertType"];
        NSString *name = @"";
        switch ([alertType intValue]) {
            case 1:
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:SCREEN_TO_LOAD];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"productID"] forKey:@"productID"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"fromUserID"] forKey:@"fromUserID"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                break;
            case 2:
                [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:SCREEN_TO_LOAD];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"fromUserID"] forKey:@"fromUserID"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [[NSUserDefaults standardUserDefaults] setObject:[[userInfo valueForKey:@"aps"] valueForKey:@"userType"] forKey:@"userType"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
        
                
                name = [[userInfo valueForKey:@"aps"]valueForKey:@"alert"];
                name = [name stringByReplacingOccurrencesOfString: @" has sent you a message." withString:@""];
                
                [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"fromUserIDName"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                 
                break;
            case 3:
                break;
            case 4:
                break;
            case 5://show expired Products
                [[NSUserDefaults standardUserDefaults] setObject:@"4" forKey:SCREEN_TO_LOAD];
                [[NSUserDefaults standardUserDefaults]synchronize];
                break;
            case 6://show Reviews
                [[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:SCREEN_TO_LOAD];
                [[NSUserDefaults standardUserDefaults]synchronize];
                break;
                
        }
        
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:ALERT_RECIEVED];
            [[NSUserDefaults standardUserDefaults]synchronize];
        
            UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
        
            if([navController.visibleViewController isKindOfClass:[HomeViewController class]])
               [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessNotification" object:nil userInfo:nil];
            else
                [navController.visibleViewController.navigationController popToRootViewControllerAnimated:NO];
            
            
        
    
        
    
    }
    
    /*
    NSString *messageID = [[userInfo valueForKey:@"aps"]valueForKey:@"messageID"];
    // UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:messageID delegate:self cancelButtonTitle:@"View" otherButtonTitles: nil];
    //[alert show];
    
    RegistrationModel *registerData = [[RegistrationModel alloc]init];
    
    dispatch_queue_t createQueue = dispatch_queue_create("updateAPNS", NULL);
    dispatch_async(createQueue, ^{
        [registerData sendAPNSResponseForMessage:messageID];
    });
    
    
    //int badgeNumber = [[[NSUserDefaults standardUserDefaults]objectForKey:BADGE_COUNT] intValue];
    
    
    //badgeNumber++;
    
    //[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i", badgeNumber] forKey:BADGE_COUNT];
    //[[NSUserDefaults standardUserDefaults]synchronize];
    
    //[[UIApplication sharedApplication]setApplicationIconBadgeNumber:badgeNumber];
    */
    
    completionHandler(UIBackgroundFetchResultNewData);
}


- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    application.statusBarHidden = YES;
    /* google
   [GIDSignIn sharedInstance].clientID = @"332323791823-1if0ttdi9h1jr1cskpveeibe3su04ip2.apps.googleusercontent.com";
    */
    [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
    
    [FIRApp configure];
    
    //[Firebase defaultConfig].persistenceEnabled = YES;
    /*
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:@"us-east-1:5a183425-2d1c-40b6-8ea0-c7682be77440"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    // Initialize the Cognito Sync client
    AWSCognito *syncClient = [AWSCognito defaultCognito];
    
    // Create a record in a dataset and synchronize with the server
    AWSCognitoDataset *dataset = [syncClient openOrCreateDataset:@"myDataset"];
    [dataset setString:@"myValue" forKey:@"myKey"];
    [[dataset synchronize] continueWithBlock:^id(AWSTask *task) {
        // Your handler code here
        return nil;
    }];
    */
    
    //if([[[NSUserDefaults standardUserDefaults]objectForKey:ACCOUNT_CREATED]boolValue])
    //{
        //-- Set Notification
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        
        
    //}

    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if([[FBSDKApplicationDelegate sharedInstance] application:application
                                                      openURL:url
                                            sourceApplication:sourceApplication
                                                   annotation:annotation])
        return YES;
    /* google
    else if([[GIDSignIn sharedInstance] handleURL:url
                                sourceApplication:sourceApplication
                                       annotation:annotation])
        return YES;
     */   
    return NO;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.farmfresh.Farm_Fresh" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Farm_Fresh" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Farm_Fresh.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
