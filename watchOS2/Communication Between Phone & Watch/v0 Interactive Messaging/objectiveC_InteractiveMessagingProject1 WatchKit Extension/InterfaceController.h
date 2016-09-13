//
//  InterfaceController.h
//  objectiveC_InteractiveMessagingProject1 WatchKit Extension
//
//  Created by Luis Castillo on 1/8/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
@import WatchConnectivity;

@interface InterfaceController : WKInterfaceController<WCSessionDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *messageFromIphoneLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *sendMessageButton;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *phoneReachableLabel;

@end
