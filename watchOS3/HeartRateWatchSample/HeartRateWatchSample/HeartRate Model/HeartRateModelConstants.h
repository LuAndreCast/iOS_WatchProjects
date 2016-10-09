//
//  Constants.h
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/4/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - messenger

//Keys
typedef enum {monitor_key, monitorKey_Command, monitorKey_Response, monitorKey_Error} hrModelKeys;
#define hrModelKeysToString(enum) [@[@"monitor_key",@"Command",@"Response",@"Error"] objectAtIndex:enum]

//Command
typedef enum {monitor_Command, monitorCommand_start, monitorCommand_end, monitorCommand_status} hrModelMonitorCommand;
#define hrModelCommandToString(enum) [@[@"monitor_Command",@"start",@"end",@"status"] objectAtIndex:enum]

//Response
typedef enum {monitor_Response, monitorResponse_started, monitorResponse_ended, monitorResponse_notStarted} hrModelMonitorResponse;
#define hrModelResponseToString(enum) [@[@"monitor_Response",@"started",@"ended",@"notStarted"] objectAtIndex:enum]

//Error
typedef enum {monitor_Error, monitorError_workout, monitorError_healthkit, monitorError_communicator} hrModelMonitorError;
#define hrModelErrorToString(enum) [@[@"monitor_Error",@"workout",@"healthkit",@"communicator"] objectAtIndex:enum]

#pragma mark - workout - watch only
typedef enum {
    error_healthkit = -3,
    error_communicator = -2,
    error_workout = -1,
    notActivated = 0,
    ended = 1,
    started = 2,
    alreadyStarted = 3
} workoutStatus;

