//
//  SidebarViewController.m
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 14/06/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import "LeftSidebarViewController.h"

@implementation LeftSidebarViewController
@synthesize sidebarDelegate;
@synthesize menuItem;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

#pragma view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.menuItem) {
        self.menuItem = [[NSArray alloc] initWithObjects:@"Activity", @"Message", @"Friends", nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.sidebarDelegate respondsToSelector:@selector(lastSelectedIndexPathForSidebarViewController:)]) {
        NSIndexPath *indexPath = [self.sidebarDelegate lastSelectedIndexPathForSidebarViewController:self];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)dealloc {
    [self.menuItem release];
    [self.sidebarDelegate release];
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; // No sections
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuItem count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36.0f; // Smaller than basic to go with background
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    /*
     Use image as background
     */
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundMenuItem.png"]];
    [cell addSubview:background];
    
    /*
     Load image dynamically depending on name of item
     */
    NSString *imageName = [NSString stringWithFormat:@"%@MenuItem.png",[self.menuItem[indexPath.row] description]];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [icon setFrame:CGRectMake(10, 7, 30, 30)];
    [cell addSubview:icon];
    
    /*
     Part to take care of the title
     We use a UILabel because cell.textLabel can't be moved
     */
    
    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(50, 0, cell.frame.size.width - 50, cell.frame.size.height)] autorelease];
    title.text = [self.menuItem[indexPath.row] description];
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont fontWithName:@"Academy Engraved LET Bold" size:14];
    [cell.contentView addSubview:title];
    
    [cell sendSubviewToBack:background]; // otherwise don't see anything
    
    /*
     Release elements in cell
     */
    [background release];
    [icon release];
    [title release];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sidebarDelegate) {
        NSObject *obj = menuItem[indexPath.row];
        [self.sidebarDelegate sidebarViewController:self didSelectObject:obj atIndexPath:indexPath];
    }
}

@end