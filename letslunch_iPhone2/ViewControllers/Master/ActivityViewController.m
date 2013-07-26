//
//  ActivityViewController.m
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 14/06/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import "ActivityViewController.h"
#import "DetailProfileViewController.h"
#import "ActivityCell.h"

@interface ActivityViewController ()

@end

@implementation ActivityViewController

static ActivityViewController *sharedSingleton = nil;
+ (ActivityViewController*)getSingleton
{
    if (sharedSingleton != nil)
        return sharedSingleton;
    @synchronized(self)
    {
        if (sharedSingleton == nil)
            sharedSingleton = [[self alloc] init];
    }
    return sharedSingleton;
}

+ (void)suppressSingleton
{
    if (sharedSingleton != nil)
        sharedSingleton = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [AppDelegate colorWithHexString:@"f0f0f0"];
    
    if(!_objects) {
        AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        _objects = [[NSMutableArray alloc] init];
        
        if([app getOwnerActivityAndForceReload:NO]) {
            _objects[0] = [app getOwnerActivityAndForceReload:NO];
            self.hasActivity = YES;
        }
        else {
            _objects[0] = @"NIL";
            self.hasActivity = NO;
        }
        if([app getListActivitiesAndForceReload:NO])
            _objects[1] = [app getListActivitiesAndForceReload:NO];
        else
            _objects[1] = @"NIL";
    }
    
    [self.tableView reloadData];
}

- (void)loadOwnerActivity
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if([app getOwnerActivityAndForceReload:NO]) {
        _objects[0] = [app getOwnerActivityAndForceReload:NO];
        self.hasActivity = YES;
    }
    else {
        _objects[0] = @"NIL";
        self.hasActivity = NO;
    }
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    else if([[_objects[section] description] isEqualToString:@"NIL"]) {
        return 1;
    }
    return [_objects[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
        return 120.0f;
    else {
        if([[_objects[indexPath.section] description] isEqualToString:@"NIL"])
            return 44.0f;
        else
            return 120.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActivityCell";
    ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ActivityCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.labelUserJobTitle.textColor = [AppDelegate colorWithHexString:@"f88836"];
    cell.LabelTime.textColor = [AppDelegate colorWithHexString:@"5e5e5e"];
    cell.labelUserName.textColor = [AppDelegate colorWithHexString:@"6a6a6a"];
    cell.labelVenueName.textColor = [AppDelegate colorWithHexString:@"5e5e5e"];
    
    [cell.labelUserName setHidden:NO];
    [cell.labelUserJobTitle setHidden:NO];
    [cell.LabelTime setHidden:NO];
    [cell.userPicture setHidden:NO];
    [cell.labelVenueName setHidden:NO];
    
    if(indexPath.section == 1) {
        if([[_objects[indexPath.section] description] isEqualToString:@"NIL"]) {            
            NSLog(@"empty");
        }
        else {
            Activity *activity = _objects[indexPath.section][indexPath.row];
            cell.labelUserName.text = [NSString stringWithFormat:@"%@ %@", activity.contact.firstname, activity.contact.lastname];
            cell.labelUserJobTitle.text = activity.contact.jobTitle;
            cell.LabelTime.text = activity.time;
            cell.labelVenueName.text = activity.venue.name;
            cell.imageView.image = activity.contact.image;
        }
    }
    else {
        if([[_objects[indexPath.section] description] isEqualToString:@"NIL"]) {
            
            self.pushButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.pushButton addTarget:self action:@selector(pushViewController:)
                 forControlEvents:UIControlEventTouchDown];
            self.pushButton.frame = (CGRect){0, - 3, 320, 51};
            
            [cell.labelUserName setHidden:YES];
            [cell.labelUserJobTitle setHidden:YES];
            [cell.LabelTime setHidden:YES];
            [cell.userPicture setHidden:YES];
            [cell.labelVenueName setHidden:YES];
            
            [self.pushButton setBackgroundImage:[UIImage imageNamed:@"buttonBroadcastAvailability"] forState:UIControlStateNormal];
            [cell addSubview:self.pushButton];
            self.pushButton = nil;
        }
        else {
            Activity *activity = _objects[indexPath.section];
            
            cell.labelUserName.text = [NSString stringWithFormat:@"%@ %@", activity.contact.firstname, activity.contact.lastname];
            cell.labelUserJobTitle.text = activity.contact.jobTitle;
            cell.LabelTime.text = activity.time;
            cell.labelVenueName.text = activity.venue.name;
            cell.imageView.image = activity.contact.image;
        }
    }
    
    return cell;
}

- (void)pushViewController:(id)sender
{
    CenterViewController* center = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).viewController;
    if([sender class] == [UIButton class])
        [center pushCreateActivityViewController:nil];
    else if([sender class] == [Activity class])
        [center pushCreateActivityViewController:sender];
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1) {
        //Activity *activity = _objects[indexPath.section][indexPath.row];
        NSString *contactID = @"16";
        DetailProfileViewController *detail = [[DetailProfileViewController alloc] initWithContactID:contactID];
        [((AppDelegate*)[UIApplication sharedApplication].delegate).viewController.navigationController pushViewController:detail animated:YES];
        detail = nil;
    }
    else if(![[_objects[indexPath.section] description] isEqualToString:@"NIL"]) {
        Activity* act = (Activity*)_objects[indexPath.row];
        [self pushViewController:act];
    }
}

@end
