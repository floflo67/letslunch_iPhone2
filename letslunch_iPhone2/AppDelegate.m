//
//  AppDelegate.m
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 14/06/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import "CenterViewController.h"
#import "GetStaticLists.h"
#import "KeychainWrapper.h"
#import "ActivityViewController.h"
#import "ContactViewController.h"
#import "ProfileViewController.h"
#import "VisitorsViewController.h"
#import "ProfileRequest.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SocialConnectionRequest.h"

@interface AppDelegate()
@property (strong, nonatomic) NSMutableArray *listActivities;
@property (strong, nonatomic) NSMutableArray *listFriendsSuggestion;
@property (strong, nonatomic) NSMutableArray *listMessages;
@property (strong, nonatomic) NSMutableArray *listContacts;
@property (strong, nonatomic) NSMutableArray *listVisitors;

@property (strong, nonatomic) LoginViewController *loginViewController;

@property (nonatomic, strong) KeychainWrapper *tokenItem;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize navController = _navController;
@synthesize loginViewController = _loginViewController;

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    self.tokenItem = [[KeychainWrapper alloc] initWithIdentifier:@"LetsLunchToken" accessGroup:nil];
    /*if(![[self getObjectFromKeychainForKey:kSecAttrAccount] isEqualToString:@"token"])
     [self.tokenItem resetKeychainItem];*/
    
    /*
     Sets window
     */
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    
    /*
     Sets center controller
     */
    CenterViewController *controller = [[CenterViewController alloc] init];
    controller.title = @"ViewController";
    
    /*
     Sets navigation controller
     */
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [navController.navigationBar setTintColor:[UIColor orangeColor]];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    _viewController = controller;
    _navController = navController;
    
    if([[self getToken] isEqualToString:@"token"])
        [self showLoginView];
    else
        [self loginSuccessfull];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    [[FBSession activeSession] handleDidBecomeActive];
}

- (void)loginSuccessfull
{
    /*
     To get current location
     */
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    [SocialConnectionRequest getSocialConnectionWithToken:[self getToken]];
    [self hideLoginView];
    [self setupOwnerContactInfo];
    [self.viewController ActivityConfiguration];
}

- (void)showLoginView
{
    _loginViewController = [[LoginViewController alloc] init];
    [_loginViewController.view setFrame:[[UIScreen mainScreen] bounds]];
    [self.viewController.navigationController.view addSubview:_loginViewController.view];
}

- (void)hideLoginView
{
    [_loginViewController.view removeFromSuperview];
    [_loginViewController.view setHidden:YES];
    _loginViewController = nil;
}

- (void)setupOwnerContactInfo
{
    self.ownerContact = [[Contacts alloc] initWithDictionary:[ProfileRequest getProfileWithToken:[self getToken] andLight:YES]];
}

#pragma custom functions

+ (UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma keychain

+ (NSString*)getToken
{
    return [(AppDelegate*)[UIApplication sharedApplication].delegate getToken];
}

- (NSString*)getToken
{
    return [self getObjectFromKeychainForKey:(__bridge id)kSecAttrAccount];
}

+ (void)writeObjectToKeychain:(id)object forKey:(id)key
{
    [(AppDelegate*)[UIApplication sharedApplication].delegate writeObjectToKeychain:object forKey:key];
}

- (void)writeObjectToKeychain:(id)object forKey:(id)key
{
    [self.tokenItem mySetObject:object forKey:key];
}

+ (id)getObjectFromKeychainForKey:(id)key
{
    return [(AppDelegate*)[UIApplication sharedApplication].delegate getObjectFromKeychainForKey:key];
}

- (id)getObjectFromKeychainForKey:(id)key
{
    return [self.tokenItem myObjectForKey:key];
}

+ (void)logout
{
    [(AppDelegate*)[UIApplication sharedApplication].delegate logout];
}

- (void)logout
{
    [ProfileRequest logoutWithToken:[AppDelegate getToken]];
    [self.tokenItem resetKeychainItem];
    [self suppressDataOnLogout];
    [ActivityViewController suppressSingleton];
    [ContactViewController suppressSingleton];
    [ProfileViewController suppressSingleton];
    [VisitorsViewController suppressSingleton];
    [self showLoginView];
}

- (void)suppressDataOnLogout
{
    self.ownerActivity = nil;
    self.ownerContact = nil;
    self.listActivities = nil;
    self.listContacts = nil;
    self.listFriendsSuggestion = nil;
    self.listMessages = nil;
    self.listVisitors = nil;
    self.locationManager = nil;
    self.consumer = nil;
    self.token = nil;
}

#pragma lists

- (NSMutableArray*)getListActivitiesAndForceReload:(BOOL)shouldReload
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [format stringFromDate:[NSDate new]];
    
    if(!self.listActivities) {
        self.listActivities = [[NSMutableArray alloc] init];
        self.listActivities = [GetStaticLists getListActivitiesWithToken:[AppDelegate getToken] latitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude andDate:date];
    }
    else if(shouldReload)
        self.listActivities = [GetStaticLists getListActivitiesWithToken:[AppDelegate getToken] latitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude andDate:date];
    
    return self.listActivities;
}

- (NSMutableArray*)getListFriendsSuggestionAndForceReload:(BOOL)shouldReload
{
    if(!self.listFriendsSuggestion) {
        self.listFriendsSuggestion = [[NSMutableArray alloc] init];
        self.listFriendsSuggestion = [GetStaticLists getListFriendsSuggestion];
    }
    else if(shouldReload)
        self.listFriendsSuggestion = [GetStaticLists getListFriendsSuggestion];
    
    return self.listFriendsSuggestion;
}

- (NSMutableArray*)getListVisitorsAndForceReload:(BOOL)shouldReload
{
    if(!self.listVisitors) {
        self.listVisitors = [[NSMutableArray alloc] init];
        self.listVisitors = [GetStaticLists getListVisitors];
    }
    else if(shouldReload)
        self.listVisitors = [GetStaticLists getListVisitors];
    
    return self.listVisitors;
}

- (NSMutableArray*)getListMessagesForThreadID:(NSString*)threadID andForceReload:(BOOL)shouldReload
{
    if(!self.listMessages) {
        self.listMessages = [[NSMutableArray alloc] init];
        self.listMessages = [GetStaticLists getListMessagesForContactID:threadID];
    }
    else if(shouldReload)
        self.listMessages = [GetStaticLists getListMessagesForContactID:threadID];
    
    return self.listMessages;
}

- (NSMutableArray*)getListContactsAndForceReload:(BOOL)shouldReload
{
    if(!self.listContacts) {
        self.listContacts = [[NSMutableArray alloc] init];
        self.listContacts = [GetStaticLists getListContacts];
    }
    else if(shouldReload)
        self.listContacts = [GetStaticLists getListContacts];
    
    return self.listContacts;
}

- (Activity*)getOwnerActivityAndForceReload:(BOOL)shouldReload
{
    if(!self.ownerActivity) {
        self.ownerActivity = [GetStaticLists getOwnerActivityWithToken:[self getToken]];
    }
    else if(shouldReload)
        self.ownerActivity = [GetStaticLists getOwnerActivityWithToken:[self getToken]];
    //return NULL;
    return self.ownerActivity;
}

#pragma mark - getter and setter

@end
