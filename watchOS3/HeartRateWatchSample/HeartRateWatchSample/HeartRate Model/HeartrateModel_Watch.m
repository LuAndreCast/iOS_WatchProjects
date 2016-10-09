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
    HealthDataService * hkService;
}

@synthesize delegate;

-(id)init
{
    self = [super init];
    if (self) {
        comm = [[Communicator alloc]init];
        hkService = [[HealthDataService alloc]init];
    }
    return self;
}//eom

#pragma mark - Setup | Chart
-(void)start
{
    [comm start];
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
    switch (status) {
        case notSupported:
            
            break;
        case failed:
            
            break;
        case notInactive:
            
            break;
        case inactive:
            
            break;
        case activated:
            
            break;
        default:
            break;
    }
}//eom

-(NSDictionary<NSString *,id> *)communicatorDidReceivedLiveMessage:(NSDictionary<NSString *,id> *)message
{
    [self handleMessageReceived:message];
    
    NSDictionary<NSString *, id> * reply = [[NSDictionary alloc]initWithObjectsAndKeys:@"Success", @"Received", nil];
    
    return reply;
}//eom

#pragma mark Communication Helpers

-(void)handleMessageReceived:(NSDictionary<NSString *,id> *)messageRcvd
{
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
            [self startReading_HeartrateData];
        }
        else  if ([responseRcvd isEqualToString:hrModelResponseToString(monitorResponse_ended)])
        {
            [self stopReading_HeartrateData];
        }
        else  if ([responseRcvd isEqualToString:hrModelResponseToString(monitorResponse_notStarted)])
        {
            //TODO: ???
        }
    });
}//eom


-(void)handleMessage_Error:(NSString *)errorRcvd
{
    dispatch_async(dispatch_get_main_queue(),
   ^{
        if ([errorRcvd isEqualToString:hrModelErrorToString(monitorError_workout)])
        {
            //TODO: handle error
        }
        else  if ([errorRcvd isEqualToString:hrModelErrorToString(monitorError_healthkit)])
        {
            //TODO: handle error
        }
        else  if ([errorRcvd isEqualToString:hrModelErrorToString(monitorError_communicator)])
        {
            //TODO: handle error
        }
   });
}//eom


-(void)handleMessage_Command:(NSString *)commandRcvd
{
     //nothing to do - not implemented for iphone to received commands
}//eom

#pragma mark - Health Store Heartrate Reading
-(void)startReading_HeartrateData
{
    [hkService readHeartrates:[NSDate date] completion:
    ^(NSArray<__kindof HKSample *> *samples, NSError *error)
    {
        if([samples count] > 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                HKQuantitySample * lastHrSample = [samples lastObject];
                HKQuantity * hrValue = lastHrSample.quantity;
                double hr = [hrValue doubleValueForUnit:hkService.hrUnit];
                
                [delegate HeartrateModelDidReceiveHeartrate:hr];
            });
        }
    }];
}//eom

-(void)stopReading_HeartrateData
{
    [hkService stopReadingHeartrates];
}//eom



@end
