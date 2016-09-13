//
//  AppDelegate.m
//  objectiveC_InteractiveMessagingProject1
//
//  Created by Luis Castillo on 1/8/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


-(void)applicationDidFinishLaunching:(UIApplication *)application
{
    if ([WCSession isSupported])
    {
        [WCSession defaultSession].delegate = self;
        [[WCSession defaultSession] activateSession];
    }
}//eom


- (void)session:(nonnull WCSession *)session
didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message
   replyHandler:(nonnull void (^)(NSDictionary<NSString *,id> * __nonnull))replyHandler
{
    /*
     A background task is started since this method will most likely be called when the app is in the
     background. By having the background task, it ensures
     that the app is not suspended before it has a chance to send its reply.
     */
    
    UIApplication *application = [UIApplication sharedApplication];
    
    __block UIBackgroundTaskIdentifier identifier = UIBackgroundTaskInvalid;
    
    dispatch_block_t endBlock = ^
    {
        
        if (identifier != UIBackgroundTaskInvalid)
        {
            //ending background task
            [application endBackgroundTask:identifier];
        }
        //resetting the identifier
        identifier = UIBackgroundTaskInvalid;
    };
    
    identifier = [application beginBackgroundTaskWithExpirationHandler:endBlock];
    
    // Re-assign the "reply" block to include a call to "endBlock" after "reply" is called.
    replyHandler = ^(NSDictionary *replyInfo) {
        replyHandler(replyInfo);
        
        endBlock();
    };
    
    // Receives text input result from the WatchKit app extension.
    NSLog(@"Message: %@", message);
    
    // Sending confirmation message to the WatchKit app extension
    replyHandler(@{@"Confirmation" : @"Hey I was in the background but i still recieved your Message -Your Cool Iphone"});
    
}//eom


//
//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    // Override point for customization after application launch.
//    return YES;
//}
//
//- (void)applicationWillResignActive:(UIApplication *)application {
//    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//}
//
//- (void)applicationDidEnterBackground:(UIApplication *)application {
//    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//}
//
//- (void)applicationWillEnterForeground:(UIApplication *)application {
//    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//}
//
//- (void)applicationDidBecomeActive:(UIApplication *)application {
//    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//}
//
//- (void)applicationWillTerminate:(UIApplication *)application {
//    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//}

@end
