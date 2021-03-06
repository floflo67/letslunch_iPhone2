//
//  CreateActivityViewController.m
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 14/06/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import "CreateActivityViewController.h"
#import "NearbyVenuesViewController.h"
#import "ActivityViewController.h"

@interface CreateActivityViewController ()

@property (nonatomic, weak) Activity *activity;
@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) LunchesRequest *lunchRequest;

@property (nonatomic, weak) IBOutlet UITextField *textFieldDescription;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segment;
@property (nonatomic, weak) IBOutlet UILabel *labelBroadcast;
@property (nonatomic, weak) IBOutlet UIView *viewContent;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *viewSubview;
@property (nonatomic, strong) UIButton *buttonClear;

@end

@implementation CreateActivityViewController

#pragma mark - managing singleton

static CreateActivityViewController *sharedSingleton = nil;
+ (CreateActivityViewController*)getSingleton
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

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Create";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveActivity:)];
    
    /*
     Change font and size of segmentControl's titles
     */
    UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:UITextAttributeFont];
    [self.segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    /*
     Clears background of table view
     */
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
}

/*
 Loads the view with an activity if existing
 */
- (void)loadViewWithActivity:(Activity*)activity
{
    if(activity) {
        /*
         Sets local variables
         */
        self.activity = activity;
        if(activity.venue.location.coordinate.latitude != 0 && activity.venue.location.coordinate.longitude != 0) {
            self.venue = activity.venue;
            [self addMap:activity.venue];
        }
        self.textFieldDescription.text = activity.description;
        if(activity.isCoffee)
            self.segment.selectedSegmentIndex = 0;
        else
            self.segment.selectedSegmentIndex = 1;
        
        /*
         Adding clear button
         */
        self.buttonClear = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.buttonClear addTarget:self action:@selector(clearBroadcast:) forControlEvents:UIControlEventTouchDown];
        self.buttonClear.frame = (CGRect){20, 5, 280, 40};
        [self.buttonClear setTitle:@"Clear broadcast" forState:UIControlStateNormal];
        [self.view addSubview:self.buttonClear];
        
        /*
         Changing frame of subview to leave place for clear button
         */
        self.viewSubview.frame = CGRectMake(0, self.viewSubview.frame.origin.y + 50, 320, self.viewSubview.frame.size.height - 50);
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if(self.buttonClear)
       [self clearBroadcast:nil];
    else
        [self resetView];
    [super viewDidDisappear:animated];
}

#pragma mark - mapView

- (void)addMap:(FSVenue*)venue
{
    /*
     Sets the MKMapView
     No scroll, no zoom
     */
    int y = 110;
    int height = 150;
    if(!self.map)
        self.map = [[MKMapView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, height)];
    self.map.zoomEnabled = self.map.scrollEnabled = NO;
    self.map.region = [self setupMapForLocation:venue.location];
    [self.map addAnnotations:[NSArray arrayWithObject:venue]];
    
    /*
     Moves view content
     */
    self.viewContent.frame = CGRectMake(0, self.viewContent.frame.origin.y + height - 25, 320, self.viewContent.frame.size.height);
    [self.viewSubview addSubview:self.map];
    [self.viewSubview sendSubviewToBack:self.map];
    
    /*
     Adding comment in description if no text
     Comment = "Meet me at [name]!"
     */
    if(self.textFieldDescription.text.length == 0) {
        self.textFieldDescription.text = [NSString stringWithFormat:@"Meet me at %@!", [self.venue name]];
    }
    
    [self.tableView reloadData];
}

- (MKCoordinateRegion)setupMapForLocation:(FSLocation*)newLocation
{
    /*
     Define size of zoom
     */
    MKCoordinateSpan span;
    span.latitudeDelta = 0.002;
    span.longitudeDelta = 0.002;
    
    /*
     Define origin
     Center = location of venue
     */
    CLLocationCoordinate2D location;
    location.latitude = newLocation.coordinate.latitude;
    location.longitude = newLocation.coordinate.longitude;
    
    MKCoordinateRegion region;
    region.span = span;
    region.center = location;
    return region;
}

/*
 Suppress map if existing
 Return view to former position
 */
- (void)resetView
{
    if(self.map) {
        int height = 150;
        [self.map removeAnnotations:[NSArray arrayWithObject:self.venue]];
        [self.map removeFromSuperview];
        self.map = nil;
        self.viewContent.frame = CGRectMake(0, self.viewContent.frame.origin.y - height + 25, 320, self.viewContent.frame.size.height);
    }
    
    self.textFieldDescription.text = @"";
    self.venue = nil;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(self.venue == nil) {
        cell.textLabel.text = @"Suggest a place";
        cell.detailTextLabel.text = @"optional";
    }
    else {
        cell.textLabel.text = [self.venue name];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[[self.venue location] address]];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self.navigationController pushViewController:[[NearbyVenuesViewController alloc] init] animated:YES];
    [self resetView];
}

#pragma mark - segment events

- (IBAction)segmentValueChanged:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl*)sender;
    
    if(seg.selectedSegmentIndex == 0)
        self.labelBroadcast.text = @"This broadcast will expire in 180 minutes.";
    else
        self.labelBroadcast.text = @"This broadcast will expire at 11:00 P.M.";
}

#pragma mark - button event

- (void)saveActivity:(id)sender
{
    AppDelegate *app = [AppDelegate getAppDelegate];
    NSString *description = self.textFieldDescription.text;
    if(self.activity && [description isEqualToString:@""]) {
        //delete
        if(![LunchesRequest suppressLunchWithToken:[AppDelegate getToken] andActivityID:self.activity.activityID])
            return;
        else
            [app setOwnerActivity:nil];
    }
    else if(!self.activity && [description isEqualToString:@""]) {
        
    }
    else {
        NSDate *current = [NSDate new];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"h:mm a"];
        NSTimeInterval threeHours = 60 * 60 * 3;
        
        NSString *start = [format stringFromDate:current];
        NSString *end = [format stringFromDate:[current dateByAddingTimeInterval:threeHours]];
        NSString *activityTime = [NSString stringWithFormat:@"%@ - %@", start, end];
        
        // update
        if(app.ownerActivity) {
            [app.ownerActivity setDescription:description isCoffee:self.segment.selectedSegmentIndex venue:self.venue andTime:activityTime];
            [[[LunchesRequest alloc] init] updateLunchWithToken:[AppDelegate getToken] andActivity:app.ownerActivity];
            [[ActivityViewController getSingleton] loadOwnerActivity];
        }
        // add
        else {
            Activity *activity = [[Activity alloc] init];
            [activity setDescription:description isCoffee:self.segment.selectedSegmentIndex venue:self.venue andTime:activityTime];
            NSDictionary *dict = [[[LunchesRequest alloc] init] addLunchWithToken:[AppDelegate getToken] andActivity:activity];
            if(![dict objectForKey:@"success"]) {
                return;
            }
            else {
                [activity setActivityID:[dict objectForKey:@"lunchId"]];
                [app setOwnerActivity:activity];
            }
            activity = nil;
            format = nil;
        }
        
        [app.ownerActivity setContact:app.ownerContact];
    }
    if(self.activity)
        self.activity = nil;
    
    [[ActivityViewController getSingleton] loadOwnerActivity];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [CreateActivityViewController suppressSingleton];
}

- (void)clearBroadcast:(id)sender
{
    self.buttonClear.hidden = YES;
    self.buttonClear = nil;
    self.viewSubview.frame = CGRectMake(0, self.viewSubview.frame.origin.y - 50, 320, self.viewSubview.frame.size.height + 50);
    [self resetView];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if(textField.isFirstResponder)
       [textField resignFirstResponder];
    return YES;
}

@end


#pragma mark - custom TextField

@interface MYTextField : UITextField

@end

@implementation MYTextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    int margin = 10;
    CGRect inset = CGRectMake(bounds.origin.x + margin, bounds.origin.y + margin, bounds.size.width - margin, bounds.size.height - margin);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    int margin = 10;
    CGRect inset = CGRectMake(bounds.origin.x + margin, bounds.origin.y + margin, bounds.size.width - margin, bounds.size.height - margin);
    return inset;
}

@end