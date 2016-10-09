//
//  Communicator_Phone.h
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/7/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Communicator.h"
#import "HeartRateModelConstants.h"
#import "HealthDataService.h"


@protocol HeartrateModelDelegate <NSObject>

/*!
 * @brief This method is called when an anchored query receives new heart rate data
 */
-(void)heartrateModelDidReceiveHeartrate:(double) hrValue
                           withStartDate:(NSDate *)startDate
                              andEndDate:(NSDate *)endDate;


@end



@interface HeartrateModel_Phone : NSObject<CommunicatorDelegate, healthDateServiceDelegate>


@property (nonatomic, weak) id<HeartrateModelDelegate> delegate;



-(void)requestPermission:(void (^)(BOOL success, NSError *error)) completionBlock;
-(void)start;





@end
