//
//  DBFriendInviter.h
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 10/07/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface DBFriendInviter : NSObject

/** 
 * Like [DBFriendInviter mostImportantContacts].
 *
 * Additionally, a set of ignored ABRecordIDs (wrapped in NSNumbers)
 * can be specified. All ABRecordIDs within this set are not included in the returned list of
 * the user's most-important contacts. This is useful to blacklist contacts that were already invited
 * or that belong to the user.
 *
 * Up to `maxResults` results will be returned by the method.
 */
+(NSArray*)mostImportantContactsWithIgnoredRecordIDs:(NSSet*)ignoredRecordIDs maxResults:(NSUInteger)maxResults;
+(NSArray*)mostImportantContacts;

@end