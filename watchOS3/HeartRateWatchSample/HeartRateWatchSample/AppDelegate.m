//
//  AppDelegate.m
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/4/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "AppDelegate.h"
#import <HealthKit/HealthKit.h>

@interface AppDelegate ()
{
    HKHealthStore * hkStore;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

#pragma mark - Health Store
-(void)applicationShouldRequestHealthAuthorization:(UIApplication *)application
{
    hkStore = [[HKHealthStore alloc]init];
    [hkStore handleAuthorizationForExtensionWithCompletion:^(BOOL success, NSError * _Nullable error)
    {
        if (success)
        {
            NSLog(@"applicationShouldRequestHealthAuthorization - SUCCESS");
        }
        else
        {
            if(error != nil)
            {
                NSLog(@"%@", error);
            }
            else
            {
                NSLog(@"applicationShouldRequestHealthAuthorization - FAILED");
            }
        }
    }];
}//eom


@end
