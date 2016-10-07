//
//  HeartRateModel.h
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/4/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import <HealthKit/HealthKit.h>

#import "HeartRateModelConstants.h"
#import "HealthDataService.h"

@interface HeartRateModel : NSObject<WCSessionDelegate>

-(void)setup;


+(HeartRateModel *)sharedInstance;



//-(void)handleWatchHealthStoreRequest;

@end
