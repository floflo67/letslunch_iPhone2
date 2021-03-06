//
//  CenterViewController.h
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 14/06/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import "JTRevealSidebarV2Delegate.h"

// Orientation changing is not an officially completed feature,
// The main thing to fix is the rotation animation and the
// necessarity of the container created in AppDelegate. Please let
// me know if you've got any elegant solution and send me a pull request!
// You can change EXPERIEMENTAL_ORIENTATION_SUPPORT to 1 for testing purpose
#define EXPERIEMENTAL_ORIENTATION_SUPPORT 1

@interface CenterViewController : UIViewController <JTRevealSidebarV2Delegate, UITableViewDelegate>

-(void)closeView;
-(void)pushCreateActivityViewController:(id)sender;
-(void)ActivityConfiguration;

@end
