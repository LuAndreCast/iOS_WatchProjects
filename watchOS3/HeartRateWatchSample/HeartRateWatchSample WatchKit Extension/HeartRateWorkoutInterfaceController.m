//
//  InterfaceController.m
//  HeartRateWatchSample WatchKit Extension
//
//  Created by Luis Castillo on 10/4/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "HeartRateWorkoutInterfaceController.h"


@interface HeartRateWorkoutInterfaceController()
{
    WorkoutSessionService * wkService;
    NSDateFormatter * dateF;
    workoutStatus wkStatus;
    
    Communicator * comm;
    communicatorStatus commStatus;
}
@end


@implementation HeartRateWorkoutInterfaceController

@synthesize wkStartDateLabel, wkEndDateLabel, wkHrValueLabel;
@synthesize startWkButton, endWkButton;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    //communicator
    comm = [[Communicator alloc]init];
    comm .delegate = self;
    [comm start];
    
    //UI setup
    [wkStartDateLabel setText:@"Start: "];
    [wkEndDateLabel setText:@"End:  "];
    [wkHrValueLabel setText:@". . ."];

    //formatter
    dateF = [[NSDateFormatter alloc]init];
    [dateF setDateStyle:NSDateFormatterNoStyle];
    [dateF setTimeStyle:NSDateFormatterShortStyle];
    
    //default status
    wkStatus = notActivated;
    commStatus = inactive;
    
    //workout
    wkService = [[WorkoutSessionService alloc]init];
    wkService.delegate = self;
    [wkService startWorkout];
    
}//eom

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
//    [wkService startWorkout];
}//eom

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}//eom


#pragma mark - Actions
- (IBAction)StartWorkout {
    [wkService startWorkout];
}//eo-a

- (IBAction)EndWorkout {
    [wkService endWorkout];
}//eo-a

-(void)updateUI:(BOOL)startedWorkout
{
    /*
    if (startedWorkout) {
        [startWkButton setHidden:true];
        [endWkButton setHidden:false];
    } else {
        [startWkButton setHidden:false];
        [endWkButton setHidden:true];
    }
     */
}//eom

#pragma mark - Service Delegates
-(void)WorkoutSessionServiceDidStartWorkoutAtDate:(NSDate *)date
{
    dispatch_async(dispatch_get_main_queue(),
   ^{
        //update UI
        NSString * startedString = [dateF stringFromDate:date];
        startedString = [NSString stringWithFormat:@"Start: %@", startedString];
        [wkStartDateLabel setText:startedString];
        [self updateUI:true];
   });
    
    //status to phone
    wkStatus = started;
    [self sendPhoneWorkoutStatus];
}//eom

-(void)WorkoutSessionServiceDidStopWorkoutAtDate:(NSDate *)date
{
    dispatch_async(dispatch_get_main_queue(),
   ^{
        //update UI
        NSString * endedString = [dateF stringFromDate:date];
        endedString = [NSString stringWithFormat:@"End: %@", endedString];
        [wkEndDateLabel setText:endedString];
        [self updateUI:false];
   });
    
    //status to phone
    wkStatus = ended;
    [self sendPhoneWorkoutStatus];
}//eom

-(void)WorkoutSessionServiceDidReceiveHeartrate:(double)hrValue
{
    //ui update
    NSString * hrStringValue = [NSString stringWithFormat:@"%.1f bpm", hrValue];
    [wkHrValueLabel setText:hrStringValue];
    
    //TODO: notify phone
}//eom

-(void)WorkoutSessionServiceErrorOccurred:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(),
   ^{
       //ui update
       [self updateUI:false];
        [wkStartDateLabel setText:[error localizedDescription]];
   });
    
    //status to phone
    wkStatus = error_workout;
    [self sendPhoneWorkoutStatus];
}//eom

-(void)WorkoutSessionServiceAnotherSessionAlreadyStarted
{
    
    //ui update
    [wkStartDateLabel setText:@"Already"];
    [wkEndDateLabel setText:@"Started"];
    [startWkButton setBackgroundColor:[UIColor lightGrayColor]];
    
    //start monitoring
    dispatch_async(dispatch_get_main_queue(), ^{
        [wkService startMonitoringHeartrate:[NSDate date]];
    });
    
    //status to phone
    wkStatus = alreadyStarted;
    [self sendPhoneWorkoutStatus];
}//eom

-(void)WorkoutSessionServiceConfigError:(NSError *)error
{
    //ui update
    [startWkButton setBackgroundColor:[UIColor darkGrayColor]];
    
    //status to phone
    wkStatus = error_workout;
    [self sendPhoneWorkoutStatus];
}//eom


-(void)WorkoutSessionServiceHealthPermissionFailed:(NSError *)error
{
    //ui update
    [wkEndDateLabel setText:@"Failed Permission"];
    [startWkButton setBackgroundColor:[UIColor redColor]];
    if (error != nil)
    {
        [wkEndDateLabel setText:[error localizedDescription]];
    }
    
    //status to phone
    wkStatus = error_healthkit;
    [self sendPhoneWorkoutStatus];
}//eom


#pragma mark - Communicator Delegates
-(void)communicatorActionStatus:(communicatorStatus)status
{
    commStatus = status;
    
}//eom

-(NSDictionary<NSString *, id> *)communicatorDidReceivedLiveMessage:(NSDictionary<NSString *,id> *)message
{
    [self handleMessageReceived:message];
    
    NSDictionary<NSString *, id> * reply = [[NSDictionary alloc]initWithObjectsAndKeys:@"Success", @"Received", nil];
    
    return reply;
}//eom

-(void)communicatorDidReceivedBackgroundMessage:(NSDictionary<NSString *,id> *)message
{
    [self handleMessageReceived:message];
}//eom

#pragma mark - Communicator Helpers

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
        NSString * errorReceived = [messageRcvd objectForKey:hrModelErrorToString(monitor_Error)];
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
    //nothing to do - not implemented to received responses
}//eom


-(void)handleMessage_Error:(NSString *)errorRcvd
{
    //nothing to do - not implemented to receive errors
}//eom


-(void)handleMessage_Command:(NSString *)commandRcvd
{
    dispatch_async(dispatch_get_main_queue(),
   ^{
       if ([commandRcvd isEqualToString:hrModelCommandToString(monitorCommand_start)])
       {
           [wkService startWorkout];
       }
       else  if ([commandRcvd isEqualToString:hrModelCommandToString(monitorCommand_end)])
       {
           [wkService endWorkout];
       }
       else  if ([commandRcvd isEqualToString:hrModelCommandToString(monitorCommand_status)])
       {
           [self sendPhoneWorkoutStatus];
       }
   });
}//eom

-(void)sendPhoneWorkoutStatus
{
    NSDictionary<NSString *, id> * messageToSend = [[NSDictionary alloc]initWithObjectsAndKeys:
       hrModelKeysToString(monitorKey_Response), hrModelKeysToString(monitor_key),
       hrModelResponseToString(monitorResponse_notStarted),hrModelKeysToString(monitor_Response), nil];
    
    switch (wkStatus)
    {
        case ended:
            messageToSend = [[NSDictionary alloc]initWithObjectsAndKeys:
         hrModelKeysToString(monitorKey_Response), hrModelKeysToString(monitor_key),
         hrModelResponseToString(monitorResponse_ended), hrModelResponseToString(monitor_Response), nil];
            break;
        case started:
            messageToSend = [[NSDictionary alloc]initWithObjectsAndKeys:
        hrModelKeysToString(monitorKey_Response), hrModelKeysToString(monitor_key),
        hrModelResponseToString(monitorResponse_started),hrModelResponseToString(monitor_Response), nil];
            break;
        case alreadyStarted:
            messageToSend = [[NSDictionary alloc]initWithObjectsAndKeys:
        hrModelKeysToString(monitorKey_Response), hrModelKeysToString(monitor_key),
        hrModelResponseToString(monitorResponse_started),hrModelResponseToString(monitor_Response), nil];
            break;
        case error_workout:
            messageToSend = [[NSDictionary alloc]initWithObjectsAndKeys:
     hrModelKeysToString(monitorKey_Error),hrModelKeysToString(monitor_key),
     hrModelErrorToString(monitorError_workout),hrModelErrorToString(monitor_Error), nil];
            break;
        case error_healthkit:
            messageToSend = [[NSDictionary alloc]initWithObjectsAndKeys:
     hrModelKeysToString(monitorKey_Error), hrModelKeysToString(monitor_key),
     hrModelErrorToString(monitorError_healthkit),hrModelErrorToString(monitor_Error), nil];
            break;
        default:
            break;
    }
    
    [(comm .session)
     sendMessage:messageToSend
         replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage)
         {
             //nothing to do
         }
         errorHandler:^(NSError * _Nonnull error)
         {
             //nothing to do
         }];
}//eom


@end



