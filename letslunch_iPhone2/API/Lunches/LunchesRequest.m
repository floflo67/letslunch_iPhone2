//
//  LunchesRequest.m
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 17/07/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import "LunchesRequest.h"
#import "MutableRequest.h"
#import "Activity.h"

@implementation LunchesRequest

#pragma mark - GET lunch

+ (NSDictionary*)getLunchWithToken:(NSString*)token
{
    LunchesRequest *lunchRequest = [[LunchesRequest alloc] init];
    return [lunchRequest getLunchWithToken:token];
}

/*
 URL: http://letslunch.dev.knackforge.com/lunch/show
 Request Type: POST
 Parameters:
    authToken
 */
- (NSDictionary*)getLunchWithToken:(NSString*)token
{
    /*
     Sets the body of the requests
     */
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:token forKey:@"authToken"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@lunch/show",LL_API_BaseUrl]];
    MutableRequest *request = [[MutableRequest alloc] initWithURL:url andParameters:parameters andType:@"POST"];
    
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    return [self settingUpData:data andResponse:response];
}

- (NSDictionary*)settingUpData:(NSData*)data andResponse:(NSURLResponse*)response
{
    _statusCode = [(NSHTTPURLResponse*)response statusCode];
    NSArray *arr = [[NSArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
    if([arr count] == 0)
        _statusCode = 201;
    
    arr = nil;
    
    if(_statusCode == 200) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
        NSLog(@"%@", dict);
        dict = [dict objectForKey:@"lunchAvailabilty"][0];
        return dict;
    }
    else if (_statusCode == 201)
        return nil;
    else {
        NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", response);
        return nil;
    }
}

#pragma mark - ADD lunch

/*
 URL: http://letslunch.dev.knackforge.com/api/lunch/create
 Request Type: POST
 Parameters:
    authToken
    lunchType
    lunchDate
    postingTime
    description
    degreesLatitude
    degreesLongitude
    venueName // can be null - depend on venue
    venueId // can be null - depend on venue
    venueAddress // can be null - depend on venue
 */
- (BOOL)addLunchWithToken:(NSString*)token andActivity:(Activity*)activity
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    NSString *lunchType;
    if(activity.isCoffee)
        lunchType = @"coffee";
    else
        lunchType = @"lunch";
    
    NSString *lunchDate;
    NSString *postingTime;
    NSString *endTime;
    NSDate *date = [NSDate new];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    
    [format setDateFormat:@"YYYY-MM-dd"];
    lunchDate = [format stringFromDate:date];
    
    [format setDateFormat:@"HH:mm:ss"];
    postingTime = [format stringFromDate:date];
    
    NSTimeInterval secondsInThreeHours = 3 * 60 * 60;
    date = [date dateByAddingTimeInterval:secondsInThreeHours];
    endTime = [format stringFromDate:date];
    
    [parameters setValue:token forKey:@"authToken"];
    [parameters setValue:lunchType forKey:@"lunchType"];
    [parameters setValue:lunchDate forKey:@"lunchDate"];
    [parameters setValue:postingTime forKey:@"startTime"];
    [parameters setValue:endTime forKey:@"endTime"];
    [parameters setValue:activity.description forKey:@"description"];
    [parameters setValue:activity.venue.name forKey:@"venueName"];
    [parameters setValue:activity.venue.venueId forKey:@"venueId"];
    [parameters setValue:[NSString stringWithFormat:@"%f", activity.venue.location.coordinate.latitude] forKey:@"degreesLatitude"];
    [parameters setValue:[NSString stringWithFormat:@"%f", activity.venue.location.coordinate.longitude] forKey:@"degreesLongitude"];
    [parameters setValue:activity.venue.location.address forKey:@"venueAddress"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@lunch/create",LL_API_BaseUrl]];
    MutableRequest *request = [[MutableRequest alloc] initWithURL:url andParameters:parameters andType:@"POST"];
    
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    return [self settingUpDataForAdd:data andResponse:response];
}

- (bool)settingUpDataForAdd:(NSData*)data andResponse:(NSURLResponse*)response
{
    _statusCode = [(NSHTTPURLResponse*)response statusCode];
    
    if(_statusCode == 200) {
        return YES;
    }
    else {
        NSDictionary *dictJson = [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
        NSDictionary *dictError = [NSDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithDictionary:[dictJson objectForKey:@"error"]]];
		NSString* response = [dictError objectForKey:@"message"];
        [self showErrorMessage:response];
        return NO;
    }
}

#pragma mark - DELETE lunch

+ (BOOL)suppressLunchWithToken:(NSString*)token andActivityID:(NSString*)activityID
{
    LunchesRequest *lunchRequest = [[LunchesRequest alloc] init];
    return [lunchRequest suppressLunchWithToken:token andActivityID:activityID];
}

/*
 URL: http://letslunch.dev.knackforge.com/api/me/lunch/cancel
 Request Type: POST
 Parameters:
    authToken
    id // to know which is selected
 */
- (BOOL)suppressLunchWithToken:(NSString*)token andActivityID:(NSString*)activityID
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:token forKey:@"authToken"];
    [parameters setValue:activityID forKey:@"id"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@me/lunch/cancel",LL_API_BaseUrl]];
    MutableRequest *request = [[MutableRequest alloc] initWithURL:url andParameters:parameters andType:@"POST"];
    
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    return [self settingUpDataForDelete:data andResponse:response];
}

- (BOOL)settingUpDataForDelete:(NSData*)data andResponse:(NSURLResponse*)response
{
    _statusCode = [(NSHTTPURLResponse*)response statusCode];
    
    if(_statusCode == 200) {
        return YES;
    }
    else {
        NSDictionary *dictJson = [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
        NSDictionary *dictError = [NSDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithDictionary:[dictJson objectForKey:@"error"]]];
		NSString* response = [dictError objectForKey:@"message"];
        [self showErrorMessage:response];
        return NO;
    }
}

#pragma mark - UPDATE lunch

/*
 URL: http://letslunch.dev.knackforge.com/api/lunch/edit
 Request Type: POST
 Parameters:
    authToken
    lunchType
    availabilityID // to know which is selected
    postingTime
    description
    degreesLatitude
    degreesLongitude
    name // can be null - depend on venue
    id // can be null - depend on venue
    address // can be null - depend on venue
 */
- (void)updateLunchWithToken:(NSString *)token andActivity:(Activity *)activity
{
    if (_connection == nil) {
		_data = [NSMutableData new];
        NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
        
        NSString *lunchType;
        if(activity.isCoffee)
            lunchType = @"coffee";
        else
            lunchType = @"lunch";
        
        NSString *postingTime;
        NSString *endTime;
        NSString *lunchDate;
        NSDate *date = [NSDate new];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        
        [format setDateFormat:@"YYYY-MM-dd"];
        lunchDate = [format stringFromDate:date];
        
        [format setDateFormat:@"HH:mm:ss"];
        postingTime = [format stringFromDate:date];
        
        NSTimeInterval secondsInThreeHours = 3 * 60 * 60;
        date = [date dateByAddingTimeInterval:secondsInThreeHours];
        endTime = [format stringFromDate:date];
        
        [parameters setValue:token forKey:@"authToken"];
        [parameters setValue:lunchType forKey:@"lunchType"];
        [parameters setValue:postingTime forKey:@"startTime"];
        [parameters setValue:endTime forKey:@"endTime"];
        [parameters setValue:lunchDate forKey:@"lunchDate"];
        [parameters setValue:activity.description forKey:@"description"];
        [parameters setValue:activity.venue.name forKey:@"venueName"];
        [parameters setValue:activity.venue.venueId forKey:@"venueId"];
        [parameters setValue:[NSString stringWithFormat:@"%f", activity.venue.location.coordinate.latitude] forKey:@"degreesLatitude"];
        [parameters setValue:[NSString stringWithFormat:@"%f", activity.venue.location.coordinate.longitude] forKey:@"degreesLongitude"];
        [parameters setValue:activity.venue.location.address forKey:@"venueAddress"];
        [parameters setValue:activity.activityID forKey:@"availabilityID"];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@lunch/edit",LL_API_BaseUrl]];
        MutableRequest *request = [[MutableRequest alloc] initWithURL:url andParameters:parameters andType:@"POST"];
        
        _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
}

#pragma mark - custom function

- (void)showErrorMessage:(NSString*)error
{
    [_delegate showErrorMessage:error withErrorStatus:_statusCode];
}

#pragma connection delegate

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
	[_data appendData:data];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response
{
	_statusCode = [response statusCode];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
	_connection = nil;
	_data = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
	if (_statusCode != 200) {
        NSDictionary *dictJson = [NSDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:_data options:0 error:nil]];
        NSDictionary *dictError = [NSDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithDictionary:[dictJson objectForKey:@"error"]]];
		NSString* response = [dictError objectForKey:@"message"];
        [self showErrorMessage:response];
	}
	
	_connection = nil;
	_data = nil;
}

#pragma lifecycle


@end
