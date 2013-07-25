//
//  GetStaticLists.m
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 13/06/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import "GetStaticLists.h"
#import "Contacts.h"
#import "FSVenue.h"
#import "Messages.h"
#import "LunchesRequest.h"
#import "VisitorsRequest.h"

@implementation GetStaticLists

+ (NSArray*)getListActivities
{
    NSMutableArray* listActivities = [[NSMutableArray alloc] init];
    Contacts *c = [[Contacts alloc] initWithID:@"1" firstname:@"first" lastname:@"last" jobTitle:@"headline" andPictureURL:nil];
    FSVenue *v = [[FSVenue alloc] init];
    
    v.name = @"The Grove";
    v.venueId = @"4b7ef75cf964a520ee0c30e3";
    v.location.address = @"690 Mission St";
    NSNumber *num = [NSNumber numberWithInt:403];
    v.location.distance = num;
    v.distance = v.location.distance;
    [v.location setCoordinate:CLLocationCoordinate2DMake([@"37.78653398485857" doubleValue], [@"-122.401921749115" doubleValue])];
    
    BOOL b = YES;
    Activity *act1 = [[Activity alloc] initWithID:@"1234" contact:c venue:v description:@"desc1" startTime:@"2:00 PM" endTime:@"3:00 PM" andIsCoffee:b];
    
    [listActivities addObject:act1];
    [listActivities addObject:@"Activity2"];
    [listActivities addObject:@"Activity3"];
    [listActivities addObject:@"Activity4"];
    [listActivities addObject:@"Activity5"];
    [listActivities addObject:@"Activity6"];
    
    return listActivities;
}

+ (Activity*)getOwnerActivityWithToken:(NSString*)token
{
    NSDictionary *dict = [LunchesRequest getLunchWithToken:token];
    if(!dict)
        return NULL;
    else {
        Activity *act = [[Activity alloc] initWithDict:dict];
        return act;
        /*
        Contacts *c = [[Contacts alloc] initWithID:@"1" firstname:@"first" lastname:@"last" jobTitle:@"headline" andPictureURL:nil];
        FSVenue *v = [[FSVenue alloc] init];
        
        v.name = @"The Grove";
        v.venueId = @"4b7ef75cf964a520ee0c30e3";
        v.location.address = @"690 Mission St";
        NSNumber *num = [NSNumber numberWithInt:403];
        v.location.distance = num;
        v.distance = v.location.distance;
        [v.location setCoordinate:CLLocationCoordinate2DMake([@"37.78653398485857" doubleValue], [@"-122.401921749115" doubleValue])];
        
        BOOL b = YES;
        if([[dict objectForKey:@"type"] isEqualToString:@"Lunch"])
            b = NO;
        
        Activity *act1 = [[Activity alloc] initWithID:[dict objectForKey:@"id"] contact:c venue:v description:[dict objectForKey:@"starttime"] andIsCoffee:b];
        
        return act1;*/
    }
}


+ (NSMutableArray*)getListFriendsSuggestion
{
    NSMutableArray* listFriendsSuggestion = [[NSMutableArray alloc] init];
    
    [listFriendsSuggestion addObject:@"Suggestion1"];
    [listFriendsSuggestion addObject:@"Suggestion2"];
    [listFriendsSuggestion addObject:@"Suggestion3"];
    
    
    return listFriendsSuggestion;
}

+ (NSMutableArray*)getListMessagesForContactID:(NSString*)contactID
{
    NSMutableArray* listMessages = [[NSMutableArray alloc] init];
    
    Messages *mess1 = [[Messages alloc] initWithDescription:@"content1" From:contactID To:@"1" date:[NSDate new]];
    Messages *mess2 = [[Messages alloc] initWithDescription:@"content2" From:contactID To:@"1" date:[NSDate new]];
    Messages *mess3 = [[Messages alloc] initWithDescription:@"content3" From:contactID To:@"1" date:[NSDate new]];
    Messages *mess4 = [[Messages alloc] initWithDescription:@"content4" From:@"1" To:contactID date:[NSDate new]];
    Messages *mess5 = [[Messages alloc] initWithDescription:@"content5" From:@"1" To:contactID date:[NSDate new]];
    Messages *mess6 = [[Messages alloc] initWithDescription:@"content6" From:contactID To:@"1" date:[NSDate new]];
    Messages *mess7 = [[Messages alloc] initWithDescription:@"content7" From:contactID To:@"1" date:[NSDate new]];
    Messages *mess8 = [[Messages alloc] initWithDescription:@"content8" From:contactID To:@"1" date:[NSDate new]];
    Messages *mess9 = [[Messages alloc] initWithDescription:@"content9" From:contactID To:@"1" date:[NSDate new]];
    Messages *mess10 = [[Messages alloc] initWithDescription:@"content10" From:contactID To:@"1" date:[NSDate new]];
    Messages *mess11 = [[Messages alloc] initWithDescription:@"content11" From:contactID To:@"1" date:[NSDate new]];
    Messages *mess12 = [[Messages alloc] initWithDescription:@"content12" From:contactID To:@"1" date:[NSDate new]];
    
    [listMessages addObject:mess1];
    [listMessages addObject:mess2];
    [listMessages addObject:mess3];
    [listMessages addObject:mess4];
    [listMessages addObject:mess5];
    [listMessages addObject:mess6];
    [listMessages addObject:mess7];
    [listMessages addObject:mess8];
    [listMessages addObject:mess9];
    [listMessages addObject:mess10];
    [listMessages addObject:mess11];
    [listMessages addObject:mess12];
    
    
    return listMessages;    
}

+ (NSMutableArray*)getListVisitors
{
    NSMutableArray* listVisitors = [[NSMutableArray alloc] init];
    listVisitors = [VisitorsRequest getVisitorsWithToken:[AppDelegate getObjectFromKeychainForKey:(__bridge id)(kSecAttrAccount)]];
    return listVisitors;
}

+ (NSMutableArray*)getListContacts
{
    NSMutableArray* listContacts = [[NSMutableArray alloc] init];
    
    Contacts *cont1 = [[Contacts alloc] initWithID:@"1" firstname:@"first1" lastname:@"last1" jobTitle:@"headline" andPictureURL:nil];
    Contacts *cont2 = [[Contacts alloc] initWithID:@"2" firstname:@"first2" lastname:@"last2" jobTitle:@"headline" andPictureURL:nil];
    Contacts *cont3 = [[Contacts alloc] initWithID:@"3" firstname:@"first3" lastname:@"last3" jobTitle:@"headline" andPictureURL:nil];
    
    [listContacts addObject:cont1];
    [listContacts addObject:cont2];
    [listContacts addObject:cont3];
    
    
    return listContacts;
}

@end
