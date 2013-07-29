//
//  MessageRequest.h
//  letslunch_iPhone2
//
//  Created by Florian Reiss on 29/07/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageRequest : NSObject {
    NSURLConnection* _connection;
    NSMutableData* _data;
    NSInteger _statusCode;
}

+(void)sendMessage:(NSString*)message withToken:(NSString*)token toUser:(NSString*)userID;
-(void)sendMessage:(NSString*)message withToken:(NSString*)token toUser:(NSString*)userID;

@end
