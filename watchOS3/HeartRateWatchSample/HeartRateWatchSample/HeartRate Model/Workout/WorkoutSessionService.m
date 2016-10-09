//
//  WorkoutSessionService.m
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "WorkoutSessionService.h"


@implementation WorkoutSessionService
{
    HealthDataService * healthService;
    HKWorkoutSession * session;
    NSDate * startDate;
    NSDate * endDate;
}

@synthesize delegate;


#pragma mark - Setup
-(id)init
{
    self = [super init];
    if (self) {
        healthService = [[HealthDataService alloc]init];
    }
    
    return self;
}//eom

-(void)setupWorkoutConfigAndStartworkout
{
    NSError * errorWithConfig = nil;
    
    HKWorkoutConfiguration * wkConfig = [[HKWorkoutConfiguration alloc]init];
    wkConfig .activityType = HKWorkoutActivityTypeOther;
    wkConfig .locationType = HKWorkoutSessionLocationTypeUnknown;
    
    HKWorkoutSession * tempSession = [[HKWorkoutSession alloc]initWithConfiguration:wkConfig error:&errorWithConfig];
    
    if (errorWithConfig != nil)
    {
        [delegate WorkoutSessionServiceConfigError:errorWithConfig];
    }
    else
    {
        session = tempSession;
        
        session.delegate = self;
        [healthService.hkStore startWorkoutSession:session];
    }
    
}//eom

#pragma mark - Start workout
-(void)startWorkout
{
    [healthService requestPermission:^(BOOL success, NSError *error)
    {
        if (success)
        {
            [self setupWorkoutConfigAndStartworkout];
        }
        else
        {
            [delegate WorkoutSessionServiceHealthPermissionFailed:error];
        }
    }];
    
}//eom

-(void)endWorkout
{
    [healthService.hkStore endWorkoutSession:session];
}//eom


#pragma mark - Workout Delegates
-(void)workoutSession:(HKWorkoutSession *)workoutSession
     didFailWithError:(NSError *)error
{
    if ( [[error localizedDescription]
         isEqual: @"Workout session already running"] )
    {
        [delegate WorkoutSessionServiceAnotherSessionAlreadyStarted];
    }
    else
    {
        [delegate WorkoutSessionServiceErrorOccurred:error];
    }
    
    
    //end session
    [self sessionEnded:[NSDate date]];
}//eom

-(void)workoutSession:(HKWorkoutSession *)workoutSession
     didChangeToState:(HKWorkoutSessionState)toState
            fromState:(HKWorkoutSessionState)fromState
                 date:(NSDate *)date
{
    dispatch_async(dispatch_get_main_queue(), ^{
       switch (toState) {
            case HKWorkoutSessionStateRunning:
                [self sessionStarted:date];
            break;
            case HKWorkoutSessionStateEnded:
                [self sessionEnded:date];
            break;
            case HKWorkoutSessionStatePaused:
                //TODO: handle
            break;
            case HKWorkoutSessionStateNotStarted:
               //TODO: handle
            break;
            default:
                break;
        }
    });
}//eom


#pragma mark - Workout Delegates Handlers
-(void)sessionStarted:(NSDate *)date
{
    startDate = date;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [delegate WorkoutSessionServiceDidStartWorkoutAtDate:date];
    });
    
    //start monitoring data
    [self startMonitoringHeartrate:date];
}//eom

-(void)startMonitoringHeartrate:(NSDate *)date
{
    //start monitoring data
    [healthService startStreamingHeartratesFromLocalDevice:date
       completion:^(NSArray<__kindof HKSample *> *samples, NSError *error) {
        if([samples count] > 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                HKQuantitySample * lastHrSample = [samples lastObject];
                HKQuantity * hrValue = lastHrSample.quantity;
                double hr = [hrValue doubleValueForUnit:healthService.hrUnit];
                
                [delegate WorkoutSessionServiceDidReceiveHeartrate:hr];
            });
        }
    }];

}//eom

-(void)sessionEnded:(NSDate *)date
{
    endDate = date;
    
    //stop monitoring data
    [healthService stopStreamingHeartrates];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [delegate WorkoutSessionServiceDidStopWorkoutAtDate:date];
    });
}//eom

@end
