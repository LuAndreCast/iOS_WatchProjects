//
//  Communicator.h
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/7/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>


typedef enum {
    notSupported = -2,
    failed = -1,
    notInactive = 0,
    inactive = 1,
    activated = 2
} communicatorStatus;

@protocol CommunicatorDelegate <NSObject>

/*!
 * @brief This method is called when WCSession activated with status provided
 */
-(void)communicatorActionStatus:(communicatorStatus)status;


#pragma mark - Live messages
/*!
 * @brief This method is called when a Live message has been received
 */
-(NSDictionary<NSString *,id> *)communicatorDidReceivedLiveMessage:(NSDictionary<NSString *,id> *)message;


#pragma mark - Background messages
/*!
 * @brief This method is called when a background message has been received
 */

-(void)communicatorDidReceivedBackgroundMessage:(NSDictionary<NSString *,id> *)message;

@end


@interface Communicator : NSObject<WCSessionDelegate>

@property (nonatomic, weak) id<CommunicatorDelegate> delegate;
@property (nonatomic, readonly) communicatorStatus activationStatus;
@property (nonatomic, retain) WCSession * session;


-(void)start;

#pragma mark - Background messages
-(void)sendApplicationContext:(NSDictionary<NSString *, id> *) messageToSend;

@end
