//
//  InterfaceController.m
//  objectiveC_InteractiveMessagingProject1 WatchKit Extension
//
//  Created by Luis Castillo on 1/8/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()

@end

@implementation InterfaceController

@synthesize messageFromIphoneLabel, sendMessageButton, phoneReachableLabel;

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        [WCSession defaultSession] .delegate = self;
        [[WCSession defaultSession] activateSession];
    }
    return self;
}//eo-c

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

//MARK: Send
- (IBAction)sendMessageToIphone
{
    [ self presentTextInputControllerWithSuggestions:@[@"Watch Me!",@"Time?", @"How are you", @"Yes" , @"No", @"Maybe"] allowedInputMode: WKTextInputModeAllowEmoji completion:^(NSArray * _Nullable results)
        {
            if (results.firstObject != nil)
            {
                //reachable
                if ([[WCSession defaultSession] isReachable])
                {
                    [phoneReachableLabel setHidden:false];
                    
                    [[WCSession defaultSession] sendMessage:@{ @"messageFromWatch": results.firstObject} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage)
                     {
                         //receive reply message
                         NSLog(@"[watch] reply from phone %@", replyMessage);
                         NSString * replyMsg = [replyMessage objectForKey:@"Confirmation"];
                         
                         //update UI
                         [self.messageFromIphoneLabel setText:@""];
                         [self.messageFromIphoneLabel setText:replyMsg];
                         
                     }//eo-reply
                                               errorHandler:^(NSError * _Nonnull error)
                     {
                         NSLog(@"[watch] error occurred! %@", error);
                     }];

                }//eo-reachable
                else
                {
                    [phoneReachableLabel setHidden:true];
                }
            }//eo-non empty data
        }];
}//eo-a

//MARK: Recieve
-(void)session:(WCSession *)session
didReceiveMessage:(NSDictionary<NSString *,id> *)message
  replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler
{
    
    [phoneReachableLabel setHidden:false];
    
    //receive message
    NSLog(@"[watch] message from iphone  %@", message);
    NSString * messageReceived = [message objectForKey:@"coolMessageFromIphone"];
    
    //send reply to sender
    replyHandler(@{@"Confirmation" : @"Message was received. Sincerely, your watch"});
    
    //update UI
    [self.messageFromIphoneLabel setText:messageReceived];
    
}//eom

@end



