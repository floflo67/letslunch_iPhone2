//
//  ActivityViewController.h
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 14/06/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray* objects;
@property (nonatomic) BOOL hasActivity;

-(void)loadOwnerActivity;

+(ActivityViewController*)getSingleton;

@end
