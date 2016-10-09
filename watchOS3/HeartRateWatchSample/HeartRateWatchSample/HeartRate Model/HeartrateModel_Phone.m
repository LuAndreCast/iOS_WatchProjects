 //
//  Communicator_Phone.m
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/7/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "HeartrateModel_Phone.h"

@implementation HeartrateModel_Phone
{
    Communicator * comm;
    communicatorStatus commStatus;
    
    HealthDataService * hkService;
    workoutStatus monitoringStatus;
}

@synthesize delegate;

-(id)init
{
    self = [super init];
    if (self)
    {
        comm = [[Communicator alloc]init];
        hkService = [[HealthDataService alloc]init];
        
        comm .delegate = self;
        hkService.delegate = self;
        
        [comm start];
        
        monitoringStatus = notActivated;
    }
    return self;
}//eom

#pragma mark - Setup | Chart
-(void)start
{
    NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo]operatingSystemVersion];
    NSInteger currOSVersion = osVersion.majorVersion;
    
    if (currOSVersion >= 10)
    {
        if( ((comm .session) .isPaired)
           && ((comm .session) .isWatchAppInstalled) )
        {
            HKWorkoutConfiguration * wkConfig = [[HKWorkoutConfiguration alloc]init];
            wkConfig.activityType = HKWorkoutActivityTypeOther;
            wkConfig.locationType = HKWorkoutSessionLocationTypeUnknown;
            
            [(hkService .hkStore) startWatchAppWithWorkoutConfiguration:wkConfig
                      completion:^(BOOL success, NSError * _Nullable error)
             {
                 [delegate heartrateModelStartWorkResult:success withError:error];
                 
                 if (success){
                     [self startReading_HeartrateData];
                     [self messageStartWorkout];
                 }
             }];
        }
        else
        {
            //communication not possible
            NSErrorDomain errorDomain= @"";
            NSInteger errorCode = 1111;
            NSError * error = [NSError errorWithDomain:errorDomain
                                                  code:errorCode
                                              userInfo:nil];
            [delegate heartrateModelStartWorkResult:false  withError:error];
        }
    }
    else
    {
        [self messageStartWorkout];
    }
}//eom

-(void)end
{
    [self stopReading_HeartrateData];
    [self messageEndWorkout];
}//eom

#pragma mark - Live Message Start Workout
-(void)messageStartWorkout
{
    NSDictionary<NSString *, id> * messageToSend = [[NSDictionary alloc]initWithObjectsAndKeys:
                                                    hrModelKeysToString(monitorKey_Command), hrModelKeysToString(monitor_key),
                                                    hrModelCommandToString(monitorCommand_start),hrModelCommandToString(monitor_Command), nil];
    
    [(comm .session) sendMessage:messageToSend
                    replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage)
     {
         
     } errorHandler:^(NSError * _Nonnull error) {
         //communication not possible
         [delegate heartrateModelStartWorkResult:false  withError:error];
     }];
}//eom

-(void)messageEndWorkout
{
    NSDictionary<NSString *, id> * messageToSend = [[NSDictionary alloc]initWithObjectsAndKeys:
    hrModelKeysToString(monitorKey_Command), hrModelKeysToString(monitor_key),
    hrModelCommandToString(monitorCommand_end),hrModelCommandToString(monitor_Command), nil];
    
    [(comm .session) sendMessage:messageToSend
                    replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage)
     {
         NSLog(@"reply message: %@", replyMessage);
     } errorHandler:^(NSError * _Nonnull error)
     {
         [comm sendApplicationContext:messageToSend];
     }];
}//eom

#pragma mark - Health Store Permission
-(void)requestPermission:(void (^)(BOOL success, NSError *error)) completionBlock
{
    [hkService requestPermission:^(BOOL success, NSError *error)
    {
        completionBlock(success, error);
    }];
}//eom

#pragma mark - Communicator Delegates
-(void)communicatorActionStatus:(communicatorStatus)status
{
    commStatus = status;
}//eom

-(NSDictionary<NSString *,id> *)communicatorDidReceivedLiveMessage:(NSDictionary<NSString *,id> *)message
{
    [self handleMessageReceived:message];
    
    NSDictionary<NSString *, id> * reply = [[NSDictionary alloc]
        initWithObjectsAndKeys:@"Success", @"Received", nil];
    
    return reply;
}//eom

-(void)communicatorDidReceivedBackgroundMessage:(NSDictionary<NSString *,id> *)message
{
    //notthing to do - not implemented for phone to received background messages
}//eom

#pragma mark Communication Helpers

-(void)handleMessageReceived:(NSDictionary<NSString *,id> *)messageRcvd
{
    NSLog(@"[hrModel] message RCVD %@", [messageRcvd debugDescription]);
    
    NSString * keyReceived = [messageRcvd objectForKey:hrModelKeysToString(monitor_key)];
    
    //response / status
    if ([keyReceived isEqualToString: hrModelKeysToString(monitorKey_Response)])
    {
        NSString * responseReceived = [messageRcvd objectForKey:hrModelResponseToString(monitor_Response)];
        [self handleMessage_Response:responseReceived];
    }
    //error
    else if ([keyReceived isEqualToString: hrModelKeysToString(monitorKey_Error)])
    {
        NSString * errorReceived = [messageRcvd objectForKey:hrModelErrorToString(monitor_Response)];
        [self handleMessage_Error:errorReceived];
    }
    //Command
    else if ([keyReceived isEqualToString: hrModelKeysToString(monitorKey_Command)])
    {
        NSString * commandReceived = [messageRcvd objectForKey:hrModelCommandToString(monitor_Command)];
        [self handleMessage_Command:commandReceived];
    }
}//eom

-(void)handleMessage_Response:(NSString *)responseRcvd
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
        if ([responseRcvd isEqualToString:hrModelResponseToString(monitorResponse_started)])
        {
            monitoringStatus = started;
            [self startReading_HeartrateData];
        }
        else  if ([responseRcvd isEqualToString:hrModelResponseToString(monitorResponse_ended)])
        {
            monitoringStatus = ended;
            [self stopReading_HeartrateData];
        }
        else  if ([responseRcvd isEqualToString:hrModelResponseToString(monitorResponse_notStarted)])
        {
            monitoringStatus = notActivated;
            //TODO: ???
        }
    });
}//eom


-(void)handleMessage_Error:(NSString *)errorRcvd
{
    monitoringStatus = notActivated;
    
    dispatch_async(dispatch_get_main_queue(),
   ^{
        if ([errorRcvd isEqualToString:hrModelErrorToString(monitorError_workout)])
        {
            monitoringStatus = error_workout;
        }
        else  if ([errorRcvd isEqualToString:hrModelErrorToString(monitorError_healthkit)])
        {
            monitoringStatus = error_healthkit;
        }
        else  if ([errorRcvd isEqualToString:hrModelErrorToString(monitorError_communicator)])
        {
            monitoringStatus = error_communicator;
        }
   });
}//eom


-(void)handleMessage_Command:(NSString *)commandRcvd
{
    //nothing to do - not implemented to received commands
}//eom

#pragma mark - Health Store Heartrate Reading
-(void)startReading_HeartrateData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [hkService startHeartrateWithPollingTime:1.5
                   andSamplesWithSecondsBack:-25.0];
    });
}//eom

-(void)stopReading_HeartrateData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [hkService stopPollingHeartrates];
   });
}//eom

#pragma mark - HealthData Service Delegates
-(void)healthDataServicePollingSamplesReceived:(NSArray<__kindof HKSample *> *)samples
{
    dispatch_async(dispatch_get_main_queue(), ^{
        HKQuantitySample * lastHrSample = [samples firstObject];
        
        //value
        HKQuantity * hrValue = lastHrSample.quantity;
        double hr = [hrValue doubleValueForUnit:hkService.hrUnit];

        //dates
        NSDate * startDate = lastHrSample.startDate;
        NSDate * endDate = lastHrSample.endDate;
        
        [delegate heartrateModelDidReceiveHeartrate:hr
                                      withStartDate:startDate
                                         andEndDate:endDate];
    });
}//eom

@end
