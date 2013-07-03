//
//  AppDelegate.m
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 14/06/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import "AppDelegate.h"
#import "CenterViewController.h"
#import "GetStaticLists.h"
#import "TwitterLoginViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize navController = _navController;
@synthesize loginViewController = _loginViewController;
@synthesize oAuthLoginView = _oAuthLoginView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
     Suppress FB session
     */
    [FBSession.activeSession closeAndClearTokenInformation];
    
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
    
    /*if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
        [self openSession];
    else
        [self showLoginView];*/
    
    return YES;
}

- (void)showLoginView
{
    _loginViewController = [[LoginViewController alloc] init];
    [_loginViewController.view setFrame:[[UIScreen mainScreen] bounds]];
    [self.viewController.navigationController.view addSubview:_loginViewController.view];
}

#pragma OAuthLoginView events

-(void) loginViewDidFinish:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    if(_loginViewController.isLinkedIn)
        [self linkedInGetProfileInfo];
    else {
        [self twitterGetProfileInfo];
    }
}

#pragma facebook events

- (void)openSession
{
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

- (void)sessionStateChanged:(FBSession*)session state:(FBSessionState)state error:(NSError*)error
{
    switch (state) {
        case FBSessionStateOpen:
            if(_loginViewController) {
                [_loginViewController.view removeFromSuperview];
                [_loginViewController release];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [self.navController popToRootViewControllerAnimated:NO];
            [FBSession.activeSession closeAndClearTokenInformation];            
            [self showLoginView];
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

#pragma LinkedIn events

- (void)linkedInGetProfileInfo
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@people/~", LI_API_BaseUrl]];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:_oAuthLoginView.consumer token:_oAuthLoginView.accessToken callback:nil signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(linkedInGetProfilInfoResult:didFinish:) didFailSelector:@selector(linkedInGetProfilInfoResult:didFail:)];
    [request release];
}

- (void)linkedInGetProfilInfoResult:(OAServiceTicket*)ticket didFinish:(NSData*)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSDictionary *profile = [responseBody objectFromJSONString];
    [responseBody release];
    
    if(profile && [profile objectForKey:@"firstName"])
    {
        NSLog(@"%@", [profile objectForKey:@"firstName"]);
        [_loginViewController.view removeFromSuperview];
        [_loginViewController.view setHidden:YES];
        [_loginViewController release];
    }
    
    // The next thing we want to do is call the network updates
    //[self networkApiCall];
    
}

- (void)linkedInGetProfilInfoResult:(OAServiceTicket*)ticket didFail:(NSData*)error
{
    NSLog(@"%@",[error description]);
}

/*
- (void)networkApiCall
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@people/~/network/updates?scope=self&count=1&type=STAT", LI_API_BaseUrl]];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:_oAuthLoginView.consumer token:_oAuthLoginView.accessToken callback:nil signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(networkApiCallResult:didFinish:) didFailSelector:@selector(networkApiCallResult:didFail:)];
    [request release];
    
}

- (void)networkApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSDictionary *person = [[[[[responseBody objectFromJSONString]
                               objectForKey:@"values"]
                              objectAtIndex:0]
                             objectForKey:@"updateContent"]
                            objectForKey:@"person"];
    
    [responseBody release];
    
    if ( [person objectForKey:@"currentStatus"] )
    {
        
    }
    else {
        
    }
    
    [self.loginViewController dismissViewControllerAnimated:YES completion:nil];
    //    [self dismissModalViewControllerAnimated:YES];
}

- (void)networkApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
}*/

/*
- (IBAction)postButton_TouchUp:(UIButton *)sender
{
    //[statusTextView resignFirstResponder];
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/shares"];
    OAMutableURLRequest *request =
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:_oAuthLoginView.consumer
                                       token:_oAuthLoginView.accessToken
                                    callback:nil
                           signatureProvider:nil];
    
    NSDictionary *update = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [[NSDictionary alloc]
                             initWithObjectsAndKeys:
                             @"anyone",@"code",nil], @"visibility",
                            statusTextView.text, @"comment", nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *updateString = [update JSONString];
    
    [request setHTTPBodyWithString:updateString];
	[request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(postUpdateApiCallResult:didFinish:)
                  didFailSelector:@selector(postUpdateApiCallResult:didFail:)];
    [request release];
}

- (void)postUpdateApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    // The next thing we want to do is call the network updates
    [self networkApiCall];
    
}

- (void)postUpdateApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
}
 */

#pragma twitter events

- (void)twitterGetProfileInfo
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@users/show.json?screen_name=%@", TW_API_BaseUrl, _oAuthLoginView.accessToken.screen_name]];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:_oAuthLoginView.consumer token:_oAuthLoginView.accessToken callback:nil signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(twitterGetProfilInfoResult:didFinish:) didFailSelector:@selector(twitterGetProfilInfoResult:didFail:)];
    [request release];
}

- (void)twitterGetProfilInfoResult:(OAServiceTicket*)ticket didFinish:(NSData*)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *profile = [responseBody objectFromJSONString];
    [responseBody release];
    
    if(profile && [profile objectForKey:@"name"])
    {
        NSLog(@"%@", [profile objectForKey:@"name"]);
        [_loginViewController.view removeFromSuperview];
        [_loginViewController.view setHidden:YES];
        [_loginViewController release];
    }
    
    // The next thing we want to do is call the network updates
    //[self networkApiCall];
    
}

- (void)twitterGetProfilInfoResult:(OAServiceTicket*)ticket didFail:(NSData*)error
{
    NSLog(@"%@",[error description]);
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

#pragma lists

- (NSMutableArray*)getListActivities
{
    if(!self.listActivities) {
        self.listActivities = [[[NSMutableArray alloc] init] autorelease];
        self.listActivities = [GetStaticLists getListActivities];
    }
    
    return self.listActivities;
}

- (NSMutableArray*) getListFriendsSuggestion
{
    if(!self.listFriendsSuggestion) {
        self.listFriendsSuggestion = [[[NSMutableArray alloc] init] autorelease];
        self.listFriendsSuggestion = [GetStaticLists getListFriendsSuggestion];
    }
    
    return self.listFriendsSuggestion;
}

- (NSMutableArray*) getListMessagesForContactID:(NSString*)contactID
{
    if(!self.listMessages) {
        self.listMessages = [[[NSMutableArray alloc] init] autorelease];
        self.listMessages = [GetStaticLists getListMessagesForContactID:contactID];
    }
    
    return self.listMessages;
}

- (NSMutableArray*)getListContacts
{
    if(!self.listContacts) {
        self.listContacts = [[[NSMutableArray alloc] init] autorelease];
        self.listContacts = [GetStaticLists getListContacts];
    }
    return self.listContacts;
}

- (Activity*) getOwnerActivity
{
    if(!self.ownerActivity) {
        self.ownerActivity = [GetStaticLists getOwnerActivity];
    }
    return NULL;
    //return self.ownerActivity;
}

#pragma application life cycle

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)dealloc
{
    self.listActivities = nil;
    self.listFriendsSuggestion = nil;
    self.listMessages = nil;
    _window = nil;
    _viewController = nil;
    _navController = nil;
    _loginViewController = nil;
    _oAuthLoginView = nil;
    [super dealloc];
}

@end
