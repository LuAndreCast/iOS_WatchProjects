//
//  Constants.h
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/4/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <Foundation/Foundation.h>


//Keys
typedef enum {command, state, error} hrModelKey;
#define hrModelKeyToString(enum) [@[@"command",@"state",@"error"] objectAtIndex:enum]

//Values - Command
typedef enum {monitor_start, monitor_end, monitor_status} hrModelCommand;
#define hrModelCommandToString(enum) [@[@"monitor_start",@"monitor_end",@"monitor_status"] objectAtIndex:enum]

//Values - State
typedef enum {state_started, state_ended, state_paused} hrModelState;
#define hrModelStateToString(enum) [@[@"state_started",@"state_paused"] objectAtIndex:enum]

//Values - Error
