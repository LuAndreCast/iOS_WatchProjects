//
//  HeartRateModel.m
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/4/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "HeartRateModel.h"

@implementation HeartRateModel
{
    HKHealthStore * hkStore;
    WCSession * wcSession;
}

-(id)init
{
    self = [super init];
    if (self) {
        [self communicationSetup];
    }
    
    return self;
}//eom

+(HeartRateModel *)sharedInstance
{
    static HeartRateModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}//eom

#pragma mark - Setup
-(void)setup
{
    
}//eom

#pragma mark - Communications

#pragma mark Setup
-(void)communicationSetup
{
    wcSession = [WCSession defaultSession];
    wcSession.delegate = self;
    [wcSession activateSession];
}//eom

#pragma mark helpers
-(void)updateStateReceived:(NSString *) state
{
   dispatch_async(dispatch_get_main_queue(), ^{
       
   });
}//eom

-(BOOL)isValidIphoneVersion
{
    NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    NSInteger maxVersion = osVersion.majorVersion;
    //NSInteger minVersion = osVersion.minorVersion;
    
    if (maxVersion >= 10) {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
    
}//eom

#pragma mark - Communications Delegates

#pragma mark Activation | States
-(void)session:(WCSession *)session
activationDidCompleteWithState:(WCSessionActivationState)activationState
         error:(NSError *)error
{
    if (error != nil) {
        NSLog(@"%@", [error localizedDescription]);
    }
    else
    {
        
    }
    
    switch (activationState) {
        case WCSessionActivationStateInactive:
            NSLog(@"WCSESSION - Inactive");
            break;
        case WCSessionActivationStateActivated:
            NSLog(@"WCSESSION - Active");
            
            wcSession = session;
            
            break;
        case WCSessionActivationStateNotActivated:
            NSLog(@"WCSESSION - NOT Activated");
            break;
        default:
            break;
    }
}//eom

-(void)sessionDidDeactivate:(WCSession *)session
{
    NSLog(@"WCSESSION - sessionDidDeactivate");

}//eom

-(void)sessionDidBecomeInactive:(WCSession *)session
{
    NSLog(@"WCSESSION - sessionDidBecomeInactive");
}//eom

#pragma mark Communication
-(void)session:(WCSession *)session
didReceiveMessage:(NSDictionary<NSString *,id> *)message
{
    NSString * stateReceived = [message objectForKey:@"State"];
    [self updateStateReceived:stateReceived];
}//eom

//#pragma mark - HealthKit
//
//#pragma mark Setup
//-(void)healthStoreSetup
//{
//    if (hkStore == nil) {
//        
//        hkStore = [[HKHealthStore alloc]init];
//    }
//    
//    [self requestHeartRatePermissionWithRead:TRUE withWrite:FALSE];
//}//eom
//
//
//#pragma mark Watch Permission
//-(void)handleWatchHealthStoreRequest
//{
//    if (hkStore == nil) {
//        
//        hkStore = [[HKHealthStore alloc]init];
//    }
//    
//    [hkStore handleAuthorizationForExtensionWithCompletion:^(BOOL success, NSError * _Nullable error) {
//        if (error != nil) {
//            NSLog(@"%@", [error localizedDescription]);
//        }
//        else
//        {
//            NSLog(@"healthStoreWatchRequest - success");
//        }
//    }];
//}//eom
//
//
//#pragma mark Permission
//-(void)requestHeartRatePermissionWithRead:(BOOL) isReading
//                                withWrite:(BOOL) isWriting
//{
//    HKObjectType * hrType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
//    HKObjectType * wkType = [HKObjectType workoutType];
//    
//    NSSet<HKObjectType *> * readTypes = nil;
//    NSSet<HKSampleType *> * writeTypes = nil;
//    
//    if (isReading)
//    {
//        readTypes = [[NSSet alloc] initWithObjects:hrType, wkType, nil];
//    }
//    
//    if (isWriting)
//    {
//        writeTypes = [[NSSet alloc] initWithObjects:hrType, wkType, nil];
//    }
//    
//    [hkStore
//     requestAuthorizationToShareTypes:writeTypes
//     readTypes:readTypes
//     completion:^(BOOL success, NSError * _Nullable error)
//     {
//         if (error != nil) {
//             NSLog(@"%@", error);
//         }
//         else
//         {
//             NSLog(@"HK Permission Requested");
//         }
//     }];
//}//eom

#pragma mark Start Watch App
-(void)startMonitoringHeartrate
{
    BOOL validOS = [self isValidIphoneVersion];
    
    //attempt to start watch
    if (validOS) {
        [self startWatchApp];
    }
    //attempt to send message
    else
    {
        [self messageStartMonitoring];
    }
}//eom

-(void)messageStartMonitoring
{
    if (wcSession.reachable)
    {
        NSDictionary<NSString *, id> * messageToSend = [[NSDictionary alloc]
                                initWithObjectsAndKeys:hrModelCommandToString(command),
                                                        hrModelKeyToString(monitor_start), nil];
        
        [wcSession sendMessage:messageToSend
                  replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage)
                {
                    NSLog(@"messageStartMonitoring reply: %@", replyMessage);
                } errorHandler:^(NSError * _Nonnull error)
                {
                    NSLog(@"%@", [error localizedDescription]);
                }];
    }
    else
    {
        //
        NSLog(@"messageStartMonitoring - device not reachable");
    }
}//eom

-(void)startWatchApp
{
    if( (wcSession.activationState == WCSessionActivationStateActivated)
       && (wcSession.isWatchAppInstalled)  )
    {
        HKWorkoutConfiguration * wkConfig = [[HKWorkoutConfiguration alloc]init];
        wkConfig.locationType = HKWorkoutSessionLocationTypeIndoor;
        wkConfig.activityType = HKWorkoutActivityTypeOther;
        
        [hkStore startWatchAppWithWorkoutConfiguration:wkConfig
                                            completion:^(BOOL success, NSError * _Nullable error)
        {
            if( error != nil)
            {
                NSLog(@"%@", [error localizedDescription]);
            }
            else
            {
                if (success)
                {
                    NSLog(@"HK started Watch App");
                }
                else
                {
                    //
                    NSLog(@"unable to start Watch App");
                }
            }
        }];
    }
    else
    {
        
    }
}//eom

@end
