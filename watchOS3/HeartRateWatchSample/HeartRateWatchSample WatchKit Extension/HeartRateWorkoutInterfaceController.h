//
//  InterfaceController.h
//  HeartRateWatchSample WatchKit Extension
//
//  Created by Luis Castillo on 10/4/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

#import "WorkoutSessionService.h"
#import "Communicator.h"
#import "HeartRateModelConstants.h"


@interface HeartRateWorkoutInterfaceController : WKInterfaceController<WorkoutSessionServiceDelegate, CommunicatorDelegate>


@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *wkStartDateLabel;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *wkEndDateLabel;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *wkHrValueLabel;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *startWkButton;


@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *endWkButton;




@end
