//
//  InterfaceController.m
//  HeartRateWatchSample WatchKit Extension
//
//  Created by Luis Castillo on 10/4/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()
{
    WorkoutSessionService * wkService;
    NSDateFormatter * dateF;
}
@end


@implementation InterfaceController

@synthesize wkStartDateLabel, wkEndDateLabel, wkHrValueLabel;
@synthesize startWkButton, endWkButton;

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    //UI setup
    [wkStartDateLabel setText:@"Start: "];
    [wkEndDateLabel setText:@"End:  "];
    [wkHrValueLabel setText:@" . . . "];

    //formatter
    dateF = [[NSDateFormatter alloc]init];
    [dateF setDateStyle:NSDateFormatterNoStyle];
    [dateF setTimeStyle:NSDateFormatterShortStyle];
    
    //models
    wkService = [[WorkoutSessionService alloc]init];
    wkService.delegate = self;
    
    [wkService startWorkout];
}//eom

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    
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
//    if (startedWorkout) {
//        [startWkButton setHidden:true];
//        [endWkButton setHidden:false];
//    } else {
//        [startWkButton setHidden:false];
//        [endWkButton setHidden:true];
//    }
}//eom

#pragma mark - Service Delegates
-(void)WorkoutSessionServiceDidStartWorkoutAtDate:(NSDate *)date
{
    NSString * startedString = [dateF stringFromDate:date];
    startedString = [NSString stringWithFormat:@"Start: %@", startedString];
    
    //Update UI
    [wkStartDateLabel setText:startedString];
    [self updateUI:true];
    
    //TODO: notify phone
}//eom

-(void)WorkoutSessionServiceDidStopWorkoutAtDate:(NSDate *)date
{
    NSString * endedString = [dateF stringFromDate:date];
    endedString = [NSString stringWithFormat:@"End: %@", endedString];
    
    //update UI
    [wkEndDateLabel setText:endedString];
    [self updateUI:false];
    
    //TODO: notify phone
}//eom

-(void)WorkoutSessionServiceDidReceiveHeartrate:(double)hrValue
{
    NSString * hrStringValue = [NSString stringWithFormat:@"%.1f bpm", hrValue];
    [wkHrValueLabel setText:hrStringValue];
    
    //TODO: notify phone
}//eom

-(void)WorkoutSessionServiceErrorOccurred:(NSError *)error
{
    [wkStartDateLabel setText:[error localizedDescription]];
    [self updateUI:false];
}//eom

-(void)WorkoutSessionServiceAnotherSessionAlreadyStarted
{
    
    [wkStartDateLabel setText:@"Already"];
    [wkEndDateLabel setText:@"Started"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wkService startMonitoringHeartrate:[NSDate date]];
    });
    
    
    [startWkButton setBackgroundColor:[UIColor lightGrayColor]];
    
    //TODO: notify phone
}//eom

-(void)WorkoutSessionServiceConfigError:(NSError *)error
{
    [startWkButton setBackgroundColor:[UIColor darkGrayColor]];
}//eom


-(void)WorkoutSessionServiceHealthPermissionFailed:(NSError *)error
{
    [wkEndDateLabel setText:@"Failed Permission"];
    
    if (error != nil) {
        [wkEndDateLabel setText:[error localizedDescription]];
    }
    
    
    [startWkButton setBackgroundColor:[UIColor redColor]];
    
    //TODO: notify phone
}//eom

@end



