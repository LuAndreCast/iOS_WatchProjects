//
//  HeartRateDataService.m
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/5/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "HealthDataService.h"


@implementation HealthDataService
{
    //workouts
    HKSampleQuery * workOutsQuery;
    
    //heartrate - streaming
    HKQueryAnchor * hrAnchor;
    HKAnchoredObjectQuery * hrAnchorQuery;
    
    //heartrate - sample query
    HKSampleQuery * hrSampleQuery;
    NSTimer * hrQueryTimer;
}
@synthesize hkStore;
@synthesize hrUnit;
@synthesize delegate;

#pragma mark Init
-(id)init
{
    self = [super init];
    if (self) {
        hkStore = [[HKHealthStore alloc]init];
        hrUnit = [HKUnit unitFromString:@"count/min"];
        hrQueryTimer = nil;
        hrSampleQuery = nil;
        hrAnchor = nil;
        hrAnchorQuery = nil;
        workOutsQuery = nil;
    }
    
    return self;
}//eom


#pragma mark - Permission
-(void)requestPermission:( void (^)(BOOL success, NSError * error))completionBlock
{
    //types
    HKObjectType * energyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKObjectType * cyclingType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
    HKObjectType * runningType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKObjectType * hrType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    //read / write sets
    NSSet<HKObjectType *> * readTypes  = [[NSSet alloc] initWithObjects:energyType,cyclingType,runningType, hrType, nil];
    NSSet<HKSampleType *> * writeTypes = nil;
    
    [hkStore requestAuthorizationToShareTypes:writeTypes  readTypes:readTypes
     completion:^(BOOL success, NSError * _Nullable error)
     {
         completionBlock(success, error);
     }];
}//eom


#pragma mark - Heartrate Streaming Query
/*!
 * @discussion Heartrate Streaming Query
 * brief Query from local device
 */
-(void)startStreamingHeartratesFromLocalDevice:(NSDate *) date
           completion:( void (^)(NSArray<__kindof HKSample *> * samples, NSError * error))completionBlock
{
    HKQuantityType * hrType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    NSCompoundPredicate * predicate = [self genericSamplePredicateWithStartDate:date withLocalDevice:TRUE withSource:FALSE withPredicateType:NSAndPredicateType];
    
    NSUInteger queryLimit = HKObjectQueryNoLimit;
    
    hrAnchorQuery = [[HKAnchoredObjectQuery alloc]initWithType:hrType
                                                predicate:predicate
                                                anchor:hrAnchor
                                                limit:queryLimit
    resultsHandler:^(HKAnchoredObjectQuery * _Nonnull query,
                     NSArray<__kindof HKSample *> * _Nullable sampleObjects,
                     NSArray<HKDeletedObject *> * _Nullable deletedObjects,
                     HKQueryAnchor * _Nullable newAnchor,
                     NSError * _Nullable error)
        {
            hrAnchor = newAnchor;
            completionBlock(sampleObjects, error);
    }];
    
    hrAnchorQuery.updateHandler = ^(HKAnchoredObjectQuery * _Nonnull query,
                            NSArray<__kindof HKSample *> * _Nullable sampleObjects,
                            NSArray<HKDeletedObject *> * _Nullable deletedObjects,
                            HKQueryAnchor * _Nullable newAnchor,
                            NSError * _Nullable error)
    {
        hrAnchor = newAnchor;
        completionBlock(sampleObjects, error);
    };
    
    [hkStore executeQuery:hrAnchorQuery];
}//eom

-(void)stopStreamingHeartrates
{
    if (hrAnchorQuery != nil) {
        [hkStore stopQuery:hrAnchorQuery];
    }
}//eom

#pragma mark - Heartrate Polling Query
/*!
* @discussion Heartrate Polling Query
* brief Generic query, ideal from iphone or watch
*/
-(void)startHeartrateWithPollingTime:(NSTimeInterval)pollingInterval
              andSamplesWithSecondsBack:(NSTimeInterval)timeSecondsInterval
{
    if (hrQueryTimer == nil)
    {
        //sample
        HKSampleType * hrSampleType = [HKSampleType quantityTypeForIdentifier: HKQuantityTypeIdentifierHeartRate];
        
        //predicate
        NSDate * startDate = [NSDate dateWithTimeIntervalSinceNow:timeSecondsInterval];
        NSDate * endDate = nil;
        HKQueryOptions queryOptions = HKQueryOptionNone;
        NSPredicate * queryPredicate =  [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:queryOptions];
        
        hrQueryTimer = [NSTimer
                        scheduledTimerWithTimeInterval:pollingInterval
                        repeats:true
        block:^(NSTimer * _Nonnull timer)
        {
            [self querySampleWithType:hrSampleType withPredicate:queryPredicate];
        }];
    }
}//eom

-(void)querySampleWithType:(HKSampleType *)sampleType
             withPredicate:(NSPredicate *)queryPredicate
{
    //sorter
    NSSortDescriptor * querySort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:false];
    NSArray<NSSortDescriptor *> * querySortDesc = [[NSArray alloc]initWithObjects:querySort, nil];
    
    //limit
    NSUInteger queryLimit = HKObjectQueryNoLimit;
    
    hrSampleQuery = [[HKSampleQuery alloc]
                        initWithSampleType:sampleType
                        predicate:queryPredicate
                        limit:queryLimit
                        sortDescriptors:querySortDesc
        resultsHandler:^(HKSampleQuery * _Nonnull query,
                         NSArray<__kindof HKSample *> * _Nullable results,
                         NSError * _Nullable error)
        {
            if ([results count] > 0) {
                [delegate healthDataServicePollingSamplesReceived:results];
            }
        }];
    [hkStore executeQuery:hrSampleQuery];
}//eom

-(void)stopPollingHeartrates
{
    [hkStore stopQuery:hrSampleQuery];
    [hrQueryTimer invalidate];
    hrQueryTimer = nil;
}//eom

#pragma mark - Query Helpers
-(NSCompoundPredicate *)genericSamplePredicateWithStartDate:(NSDate *)startDate
                           withLocalDevice:(BOOL)localDevice
                             withSource:(BOOL)defualtSource
                             withPredicateType:(NSCompoundPredicateType)compoundPredicate
{
    NSMutableArray<NSPredicate *> * predicateList = [[NSMutableArray alloc]init];
    
    //date
    NSPredicate *datePredicate = [HKQuery predicateForSamplesWithStartDate:startDate
                                                                   endDate:nil
                                                                   options:HKQueryOptionStrictStartDate];
    [predicateList addObject:datePredicate];
    
    //device
    if (localDevice)
    {
        NSSet<HKDevice *> * devices = [[NSSet alloc]initWithObjects:[HKDevice localDevice], nil];
        NSPredicate * devicePredicate = [HKQuery predicateForObjectsFromDevices:devices];
        [predicateList addObject:devicePredicate];
    }
    
    //source
    if (defualtSource)
    {
        NSPredicate * sourcePredicate = [HKQuery predicateForObjectsFromSource:[HKSource defaultSource]];
        [predicateList addObject:sourcePredicate];
    }
    NSCompoundPredicate * compound = [[NSCompoundPredicate alloc]
                                      initWithType:compoundPredicate subpredicates:predicateList];
    
    return compound;
}//eom



#pragma mark - Read Data (Samples)
#pragma mark Workouts
-(void)readWorkouts:( void (^)(NSArray<HKWorkout *> * workouts, NSError * error))completionBlock
{
    //this app
    NSPredicate *sourcePredicate = [HKQuery predicateForObjectsFromSource:[HKSource defaultSource]];
    
    //amount of time
    NSPredicate * workOutPredicates = [HKQuery predicateForWorkoutsWithOperatorType:NSGreaterThanPredicateOperatorType duration:0];
    
    NSArray<NSPredicate *> * predicateList = [[NSArray alloc]
                                              initWithObjects:sourcePredicate, workOutPredicates, nil];
    
    NSCompoundPredicate * predicate = [[NSCompoundPredicate alloc]
                                       initWithType:NSAndPredicateType subpredicates:predicateList];
    
    //type
    HKSampleType * sampleType = [HKWorkoutType workoutType];
    
    //limit
    NSUInteger queryLimit = 0;
    
    //sort
    NSSortDescriptor * querySort = [[NSSortDescriptor alloc]initWithKey:HKSampleSortIdentifierStartDate
                                                              ascending:false];
    NSArray<NSSortDescriptor *> * queryDescriptors = [[NSArray alloc] initWithObjects:querySort, nil];
    
    
    //query
    workOutsQuery =  [[HKSampleQuery alloc]initWithSampleType:sampleType
                                                    predicate:predicate
                                                        limit:queryLimit
                                              sortDescriptors:queryDescriptors
                                               resultsHandler:^(HKSampleQuery * _Nonnull query,
                                                                NSArray<__kindof HKSample *> * _Nullable results,
                                                                NSError * _Nullable error)
                      {
                          NSArray<HKWorkout *> * workouts = results;
                          completionBlock(workouts, error);
                      }];
    [hkStore executeQuery:workOutsQuery];
    
}//eom

-(void)stopReadingWorkouts
{
    [hkStore stopQuery:workOutsQuery];
}//eom

@end
