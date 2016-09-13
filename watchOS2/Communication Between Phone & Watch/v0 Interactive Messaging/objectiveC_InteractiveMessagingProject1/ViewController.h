//
//  ViewController.h
//  objectiveC_InteractiveMessagingProject1
//
//  Created by Luis Castillo on 1/8/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WatchConnectivity;


@interface ViewController : UIViewController<WCSessionDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *messageTextfield;

@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;

@property (weak, nonatomic) IBOutlet UILabel *replyFromWatchLabel;

@property (weak, nonatomic) IBOutlet UILabel *isWatchReachableLabel;



@end

