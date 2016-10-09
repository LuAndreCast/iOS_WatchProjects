//
//  WorkoutSessionService.h
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <HealthKit/HealthKit.h>
#import "HealthDataService.h"


@protocol WorkoutSessionServiceDelegate <NSObject>

/*!
 * @brief This method is called when an HKWorkoutSession is correctly started
 */
-(void)WorkoutSessionServiceDidStartWorkoutAtDate:(NSDate *) date;

/*!
 * @brief This method is called when an HKWorkoutSession is correctly stopped
 */
-(void)WorkoutSessionServiceDidStopWorkoutAtDate:(NSDate *) date;

/*!
* @brief This method is called when an anchored query receives new heart rate data
*/
-(void)WorkoutSessionServiceDidReceiveHeartrate:(double) hrValue;

/*!
 * @brief This method is called when an errors occurs
 */
-(void)WorkoutSessionServiceErrorOccurred:(NSError *) error;

/*!
 * @brief This method is called when an session has
 */
-(void)WorkoutSessionServiceAnotherSessionAlreadyStarted;

/*!
 * @brief This method is called when an errors occurs
 */
-(void)WorkoutSessionServiceHealthPermissionFailed:(NSError *) error;

/*!
 * @brief This method is called when
 */
-(void)WorkoutSessionServiceConfigError:(NSError *) error;


@end



@interface WorkoutSessionService : NSObject<HKWorkoutSessionDelegate>

@property (nonatomic, weak) id<WorkoutSessionServiceDelegate> delegate;

-(void)startWorkout;
-(void)endWorkout;

-(void)startMonitoringHeartrate:(NSDate *)date;

@end
