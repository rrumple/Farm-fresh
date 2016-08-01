//
//  Constants.h
//  Farm Fresh
//
//  Created by Randall Rumple on 3/11/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <UIKit/UIKit.h>


static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.4;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 225;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static const NSInteger MAX_HEIGHT = 2000;

#define BASE_REF @"https://farm-fresh.firebaseio.com"
#define USERS_REF @""
#define BASE_URL @"http://www.farmfresh.io/iPhone_php/"
#define PHP_SEND_SUPPORT_EMAIL @"support_email.php"
#define PHP_SEND_PDF_TO_FARMER @"send_pdf_to_farmer.php"

#define USER_PUSH_NOTIFICATION_PIN @"userPushPin"
#define ALERT_RECIEVED @"alertRecieved"
#define SCREEN_TO_LOAD @"screenToLoad"


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


//Pickers
typedef enum
{
    zPickerState = 100,
    zPickerCategories,
    zPickerScheduleLocations,
    zPickerOverrideLocations,
    zPickerProblem
} PickerType;

typedef enum{
    editMainProfileImageMode,
    editFarmProfileImageMode
    
} EditImageMode;

typedef enum
{
    GOOGLE,
    FACEBOOK,
    PASSWORD,
    PROVIDER_COUNT
} Auth_Providers;
