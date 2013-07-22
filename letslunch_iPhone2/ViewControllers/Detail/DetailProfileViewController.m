//
//  DetailProfileViewController.m
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 22/07/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import "DetailProfileViewController.h"
#import "ProfileDetailsRequest.h"

@interface DetailProfileViewController ()

@end

@implementation DetailProfileViewController
@synthesize profileDetailRequest;

- (id)initWithContactID:(NSString*)contactID
{
    self = [super init];
    if(self) {
        if(!_objects) {
            if(!profileDetailRequest)
                profileDetailRequest = [[ProfileDetailsRequest alloc] init];

            _objects = [[[NSMutableDictionary alloc] initWithDictionary:[profileDetailRequest getProfileWithToken:[AppDelegate getObjectFromKeychainForKey:kSecAttrAccount] andID:contactID]] retain];
            
            profileDetailRequest = nil;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)dealloc
{
    [_objects release];
    [_tableView release];
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_objects count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [_objects allValues];
    NSArray *subsec = keys[section];
    if([subsec count] > 0)
        return [subsec count];
    else
        return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *keys = [_objects allKeys];
    return keys[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *object = [_objects allValues];
    
    if([[object[indexPath.section] class] isSubclassOfClass:[NSDictionary class]]) {
        NSArray *keys = [object[indexPath.section] allKeys];
        NSArray *value = [object[indexPath.section] allValues];
        cell.textLabel.text = [keys[indexPath.row] description];
        cell.detailTextLabel.text = [value[indexPath.row] description];        
    }
    else if ([[object[indexPath.section] class] isSubclassOfClass:[NSArray class]]) {
        if([object[indexPath.section] count] > 0) {
            cell.textLabel.text = [object[indexPath.section][indexPath.row] description];            
        }
        else {
            cell.textLabel.text = @"None listed";
            cell.detailTextLabel.text = @"";
        }
    }
    
    
    return cell;
}

@end
