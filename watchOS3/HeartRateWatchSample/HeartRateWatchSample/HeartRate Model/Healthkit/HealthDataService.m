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
    
    //heartrate
    HKQueryAnchor * hrAnchor;
    HKAnchoredObjectQuery * hrQuery;
}
@synthesize hkStore;
@synthesize hrUnit;

#pragma mark Init
-(id)init
{
    self = [super init];
    if (self) {
        hkStore = [[HKHealthStore alloc]init];
        hrUnit = [HKUnit unitFromString:@"count/min"];
    }
    
    return self;
}//eom


#pragma mark Permission
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
         
         //TODO: REMOVE ME
         if (error != nil) {
             NSLog(@"%@", [error localizedDescription]);
         }
         else
         {
             NSLog(@"HK Permission Requested");
         }
         //
     }];
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
        
        //TODO: REMOVE ME
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else
        {
            NSLog(@"%@", results);
        }
        //
        
        completionBlock(workouts, error);
    }];
    [hkStore executeQuery:workOutsQuery];
    
}//eom

-(void)stopReadingWorkouts
{
    [hkStore stopQuery:workOutsQuery];
}//eom

#pragma mark Heartrate
-(void)readHeartrates:(NSDate *) date
           completion:( void (^)(NSArray<__kindof HKSample *> * samples, NSError * error))completionBlock
{
    HKQuantityType * hrType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    NSCompoundPredicate * predicate = [self genericSamplePredicateWithStartDate:date withLocalDevice:TRUE withSource:FALSE withPredicateType:NSAndPredicateType];
    
    NSUInteger queryLimit = HKObjectQueryNoLimit;
    
    hrQuery = [[HKAnchoredObjectQuery alloc]initWithType:hrType
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
            
            //TODO: REMOVE ME
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
            else
            {
                NSLog(@"%@", sampleObjects);
            }
            //
            
    }];
    
    
    hrQuery.updateHandler = ^(HKAnchoredObjectQuery * _Nonnull query,
                            NSArray<__kindof HKSample *> * _Nullable sampleObjects,
                            NSArray<HKDeletedObject *> * _Nullable deletedObjects,
                            HKQueryAnchor * _Nullable newAnchor,
                            NSError * _Nullable error)
    {
        hrAnchor = newAnchor;
        completionBlock(sampleObjects, error);
        
        //TODO: REMOVE ME
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else
        {
            NSLog(@"%@", sampleObjects);
        }
        //
    };
    
    [hkStore executeQuery:hrQuery];
}//eom

-(void)stopReadingHeartrates
{
    [hkStore stopQuery:hrQuery];
}//eom


#pragma mark - Helpers

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

@end
