//
//  InterfaceController.m
//  HeartRateWatch WatchKit Extension
//
//  Created by Luis Castillo on 7/27/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()
{
    HeartRateManager * manager;

}
@end


@implementation InterfaceController


#pragma mark loading
- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    manager = [[HeartRateManager alloc]init];
    manager.delegate = self;
    
    BOOL result = [manager start];
    if (result == false) {
        NSLog(@"un-able to get auth");
    }
    else
    {
        [manager startStreamingQuery];
    }
}//eom

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


#pragma mark delegates
-(void)heartRateManager_results:(HKQuantitySample *)quantitySample
{
    NSLog(@"[watch] %@ ", quantitySample);
}//eom


@end



