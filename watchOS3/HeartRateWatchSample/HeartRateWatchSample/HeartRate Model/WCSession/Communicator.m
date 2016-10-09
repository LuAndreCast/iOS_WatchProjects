//
//  Communicator.m
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/7/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "Communicator.h"
@implementation Communicator

@synthesize delegate;
@synthesize session, activationStatus;

-(id)init
{
    self = [super init];
    if (self) {
        session = [WCSession defaultSession];
        activationStatus = notInactive;
    }
    
    return  self;
}//eom

#pragma mark - Setup
-(void)start
{
    if ([WCSession isSupported])
    {
        session .delegate = self;
        [session activateSession];
    }
    else
    {
        activationStatus = notSupported;
        [delegate communicatorActionStatus:activationStatus];
    }
}//eom

#pragma mark - Activation Results
-(void)session:(WCSession *)session
activationDidCompleteWithState:(WCSessionActivationState)activationState
         error:(NSError *)error
{
    if (error != nil)
    {
        activationStatus = failed;
        [delegate communicatorActionStatus:activationStatus];
    }
    else
    {
        switch (activationState) {
            case WCSessionActivationStateNotActivated:
                activationStatus = notInactive;
                break;
            case WCSessionActivationStateInactive:
                activationStatus = inactive;
                break;
            case WCSessionActivationStateActivated:
                activationStatus = activated;
                break;
            default:
                break;
        }
        
        [delegate communicatorActionStatus:activationStatus];
    }
}//eom

#pragma mark - Live Messaging
-(void)session:(WCSession *)session
  didReceiveMessage:(NSDictionary<NSString *,id> *)message
  replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler
{
    if (delegate == nil)
    {
        NSDictionary<NSString *,id> * replyMessage = [[NSDictionary alloc]initWithObjectsAndKeys:@"Failed",@"Received", nil];
        replyHandler(replyMessage);
    }
    else
    {
        NSDictionary<NSString *,id> * reply = [delegate communicatorDidReceivedLiveMessage:message];
        replyHandler(reply);
    }
}//eom

#pragma mark - Background Messaging
-(void)session:(WCSession *)session
    didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext
{
    [delegate communicatorDidReceivedBackgroundMessage:applicationContext];
}//eom

-(void)sendApplicationContext:(NSDictionary<NSString *, id> *) messageToSend
{
    NSError * errorOccurred = nil;
    [session updateApplicationContext:messageToSend error:&errorOccurred];
}//eom

@end
