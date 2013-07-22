//
//  LinkedInViewController.h
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 22/07/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinkedInViewController : UIViewController <UIWebViewDelegate> {
    NSString *access_token;
}

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
