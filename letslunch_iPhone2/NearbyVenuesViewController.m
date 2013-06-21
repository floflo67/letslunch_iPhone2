//
//  NearbyVenuesViewController.m
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 20/06/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import "NearbyVenuesViewController.h"
#import "Foursquare2.h"
#import "FSVenue.h"
#import "FSConverter.h"

@interface NearbyVenuesViewController ()

@end

@implementation NearbyVenuesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isSearching = NO;
    self.query = @"food";
    self.navigationItem.title = @"Choose place";
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search:)];
    search.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem = search;
    [search release];
}

- (void)search:(id)sender
{
    int y = 40;
    if(self.isSearching) {
        self.isSearching = NO;
        self.segment.frame = CGRectMake(0, self.segment.frame.origin.y - y, self.segment.frame.size.width, self.segment.frame.size.height);
        self.tableView.frame = CGRectMake(0, self.tableView.frame.origin.y - y, self.tableView.frame.size.width, self.tableView.frame.size.height);
        [self.textFieldSearch removeFromSuperview];
    }
    else {
        self.isSearching = YES;
        self.segment.frame = CGRectMake(0, self.segment.frame.origin.y + y, self.segment.frame.size.width, self.segment.frame.size.height);
        self.tableView.frame = CGRectMake(0, self.tableView.frame.origin.y + y, self.tableView.frame.size.width, self.tableView.frame.size.height);
        self.textFieldSearch = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, self.view.frame.size.width - 10, y - 10)];
        self.textFieldSearch.placeholder = @"Tape search";
        [self.textFieldSearch setBorderStyle:UITextBorderStyleRoundedRect];
        self.textFieldSearch.returnKeyType = UIReturnKeySearch;
        [self.view addSubview:self.textFieldSearch];
        [self.textFieldSearch release];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

-(void)getVenuesForLocation:(CLLocation*)location
{
    self.nearbyVenues = nil;
    self.nearbyVenues = [[NSMutableArray alloc] init];
    
    [Foursquare2 searchVenuesNearByLatitude:@(location.coordinate.latitude)
								  longitude:@(location.coordinate.longitude)
									  query:self.query
									 intent:intentCheckin
                                     radius:@(500)
								   callback:^(BOOL success, id result) {
									   if (success) {
										   NSDictionary *dic = result;
										   NSArray* venues = [dic valueForKeyPath:@"response.venues"];
                                           FSConverter *converter = [[FSConverter alloc] init];
                                           self.nearbyVenues = [converter convertToObjects:venues];
                                           [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
									   }
								   }];
    [self.tableView reloadData];
}
- (IBAction)valueChanged:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl*)sender;
    switch (seg.selectedSegmentIndex) {
        case 0:
            self.query = @"food";
            break;
        case 1:
            self.query = @"coffee";
            break;
        case 2:
            self.query = @"restaurant";
            break;
        default:
            self.query = @"food";
            break;
    }
    [self getVenuesForLocation:_locationManager.location];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [_locationManager stopUpdatingLocation];
    [self getVenuesForLocation:newLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.nearbyVenues.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.nearbyVenues.count) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [self.nearbyVenues[indexPath.row] name];
    FSVenue *venue = self.nearbyVenues[indexPath.row];
    if (venue.location.address) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@m, %@", venue.location.distance, venue.location.address];
    }
    else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@m", venue.location.distance];
    }
    return cell;
}



#pragma mark - Table view delegate

/*
-(void)userDidSelectVenue{
    if ([Foursquare2 isAuthorized]) {
        [self checkin];
	}else{
        [Foursquare2 authorizeWithCallback:^(BOOL success, id result) {
            if (success) {
				[Foursquare2  getDetailForUser:@"self"
									  callback:^(BOOL success, id result){
										  if (success) {
                                              [self addRightButton];
											  [self checkin];
										  }
									  }];
			}
        }];
    }
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selected = self.nearbyVenues[indexPath.row];
    //[self userDidSelectVenue];
}

- (void)viewDidUnload
{
    [self.segment release];
    [super viewDidUnload];
}

- (void)dealloc {
    [self.textFieldSearch release];
    [self.nearbyVenues release];
    [self.selected release];
    [self.query release];
    [self.segment release];
    [super dealloc];
}
@end