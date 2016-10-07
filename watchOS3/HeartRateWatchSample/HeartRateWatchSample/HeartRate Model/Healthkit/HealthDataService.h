//
//  HeartRateDataService.h
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@interface HealthDataService : NSObject


@property (strong, retain) HKHealthStore * hkStore;
@property (strong, retain) HKUnit * hrUnit;

//permission
-(void)requestPermission:( void (^)(BOOL success, NSError * error))completionBlock;

//workouts
-(void)readWorkouts:( void (^)(NSArray<HKWorkout *> * workouts, NSError * error))completionBlock;
-(void)stopReadingWorkouts;

//heartrates
-(void)readHeartrates:(NSDate *) date
           completion:( void (^)(NSArray<__kindof HKSample *> * samples, NSError * error))completionBlock;
-(void)stopReadingHeartrates;

@end
