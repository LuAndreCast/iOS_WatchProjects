//
//  HeartRateDataService.h
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@protocol healthDateServiceDelegate <NSObject>

/*!
 * @brief This method is called when WCSession activated with status provided
 */
-(void)healthDataServicePollingSamplesReceived:(NSArray<__kindof HKSample *>  *)samples;

@end


@interface HealthDataService : NSObject

#pragma mark - Properties
@property (strong, retain) HKHealthStore * hkStore;
@property (strong, retain) HKUnit * hrUnit;

@property (nonatomic, weak) id<healthDateServiceDelegate> delegate;


#pragma mark - Permission
-(void)requestPermission:( void (^)(BOOL success, NSError * error))completionBlock;

#pragma mark - Heartrate Streaming
-(void)startStreamingHeartratesFromLocalDevice:(NSDate *) date
           completion:( void (^)(NSArray<__kindof HKSample *> * samples, NSError * error))completionBlock;
-(void)stopStreamingHeartrates;

#pragma mark - Heartrate Polling
-(void)startHeartrateWithPollingTime:(NSTimeInterval)pollingInterval
           andSamplesWithSecondsBack:(NSTimeInterval)timeSecondsInterval;
-(void)stopPollingHeartrates;


/*
 //Future release, Should NOT be Used
 
//workouts
-(void)readWorkouts:( void (^)(NSArray<HKWorkout *> * workouts, NSError * error))completionBlock;
-(void)stopReadingWorkouts;
*/

@end
