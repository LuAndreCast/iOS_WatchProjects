//
//  InterfaceController.h
//  HeartRateWatch WatchKit Extension
//
//  Created by Luis Castillo on 7/27/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "HeartRateWatch_WatchKit_Extension-Swift.h"
#import <HealthKit/HealthKit.h>

@interface InterfaceController : WKInterfaceController<HeartRateManagerDelegate>

@end
