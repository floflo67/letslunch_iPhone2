//
//  LoginViewController.m
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 27/06/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import "LoginViewController.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "LinkedInViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma view life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!_loginRequest)
        _loginRequest = [[LoginRequests alloc] init];
    
    /*
     Sets delegate of UITextField
     */
    self.textFieldPassword.delegate = self;
    self.textFieldUsername.delegate = self;
    _loginRequest.delegate = self;
    
    /*
     Sets action on button click
     */
    [self.buttonFacebook addTarget:self action:@selector(logInWithFacebook) forControlEvents:UIControlEventTouchDown];
    [self.buttonTwitter addTarget:self action:@selector(logInWithTwitter) forControlEvents:UIControlEventTouchDown];
    [self.buttonLinkedIn addTarget:self action:@selector(logInWithLinkedIn) forControlEvents:UIControlEventTouchDown];
    [self.buttonLogIn addTarget:self action:@selector(buttonLogInClick) forControlEvents:UIControlEventTouchDown];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_textFieldUsername release];
    [_textFieldPassword release];
    [_buttonLogIn release];
    [_buttonTwitter release];
    [_buttonFacebook release];
    [_buttonLinkedIn release];
    [super dealloc];
}

#pragma text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.textFieldUsername) {
        [textField resignFirstResponder];
        [self.textFieldPassword becomeFirstResponder];
    }
    else if (textField == self.textFieldPassword) {
        [textField resignFirstResponder];
        [self buttonLogInClick];
    }
    return YES;
}

#pragma button action

- (void)logInWithFacebook
{
    ACAccountStore* store = [[ACAccountStore alloc] init];
    ACAccountType* facebookAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSArray* objects = [NSArray arrayWithObjects:FB_OAUTH_KEY,@[@"publish_stream"],ACFacebookAudienceEveryone, nil];
    NSArray* keys = [NSArray arrayWithObjects:ACFacebookAppIdKey,ACFacebookPermissionsKey,ACFacebookAudienceKey, nil];
    NSDictionary* options = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    
    
    [store requestAccessToAccountsWithType:facebookAccountType options:options completion:^void(BOOL granted, NSError* error) {
        NSArray* facebookAccounts = [store accountsWithAccountType:facebookAccountType];
        if([facebookAccounts count] > 0)
        {
            ACAccount* account = [facebookAccounts objectAtIndex:0];
            NSLog(@"%@", account.username);
        }
    }];
}

- (void)logInWithTwitter
{
    ACAccountStore* store = [[ACAccountStore alloc] init];
    ACAccountType* twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [store requestAccessToAccountsWithType:twitterAccountType options:nil completion:^void(BOOL granted, NSError* error) {
        NSArray* twitterAccounts = [store accountsWithAccountType:twitterAccountType];
        if(twitterAccounts && [twitterAccounts count] > 0)
        {
            ACAccount* account = [twitterAccounts objectAtIndex:0];
            NSLog(@"%@", account.username);
        }
        else {
            NSLog(@"No accounts");
            /*
            self.isLinkedIn = NO;
            OAuthLoginView* oAuthLoginView = [[OAuthLoginView alloc] initWithTwitter];
            AppDelegate *app = [UIApplication sharedApplication].delegate;
            app.oAuthLoginView = oAuthLoginView;
            
            // register to be told when the login is finished
            [[NSNotificationCenter defaultCenter] addObserver:app selector:@selector(loginViewDidFinish:) name:@"loginViewDidFinish" object:oAuthLoginView];
            [self presentViewController:oAuthLoginView animated:YES completion:nil];
            */
        }
    }];
}

- (void)logInWithLinkedIn
{
    LinkedInViewController *linkedinViewController = [[LinkedInViewController alloc] init];
    [self.view addSubview:linkedinViewController.view];
}

- (BOOL)buttonLogInClick
{
    return [self logInWithUsername:self.textFieldUsername.text andPassword:self.textFieldPassword.text];
}

- (BOOL)logInWithUsername:(NSString*)username andPassword:(NSString*)password
{
    username = @"florian@letslunch.com";
    password = @"developer";
    return [_loginRequest loginWithUserName:username andPassword:password];
}

#pragma login request delegate

- (void)showErrorMessage:(NSString*)message withErrorStatus:(NSInteger)errorStatus
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL message:NULL delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.title = [NSString stringWithFormat:@"Error: %i", errorStatus];
    alert.message = message;
    [alert show];
    [alert release];
}

- (void)successfullConnection
{
    [((AppDelegate*)[UIApplication sharedApplication].delegate) loginSuccessfull];
}

@end
