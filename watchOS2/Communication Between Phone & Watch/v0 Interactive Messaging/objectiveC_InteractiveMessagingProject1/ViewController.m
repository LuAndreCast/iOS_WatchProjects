//
//  ViewController.m
//  objectiveC_InteractiveMessagingProject1
//
//  Created by Luis Castillo on 1/8/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()


@end

@implementation ViewController

@synthesize messageTextfield, sendMessageButton, replyFromWatchLabel;
@synthesize isWatchReachableLabel;


//MARK:
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}//eom

-(void)viewWillAppear:(BOOL)animated
{
    if( WCSession.isSupported )
    {
        NSLog(@"[iphone] wcsession supported");

        [WCSession defaultSession] .delegate = self;
        [[WCSession defaultSession] activateSession];
    }
}//eom

//MARK:
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}//eom

//MARK: Send Message
- (IBAction)sendMessage:(UIButton *)sender
{
    
    //just in case
    [self.messageTextfield resignFirstResponder];
    
    if ( [WCSession defaultSession] .isReachable )
    {
        [self.isWatchReachableLabel setHidden:false];
        
        NSString * messageToSend = self.messageTextfield.text;
        self.messageTextfield.text = @"";
        
        [[WCSession defaultSession] sendMessage:@{ @"coolMessageFromIphone": messageToSend }
                                   replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage)
            {
                //receive reply
                NSLog(@"reply from watch: %@", replyMessage);
                
                NSString * replyMsg = [replyMessage objectForKey:@"Confirmation"];
                
                //update UI
                self.replyFromWatchLabel.text   = replyMsg;
                
            }//eo-reply
            errorHandler:^(NSError * _Nonnull error)
            {
                NSLog(@"[iphone] error occurred!! %@", error);
            }];//eo-error
    }
    else
    {
        
        [self.isWatchReachableLabel setHidden:true];
    }
}//eoa

//MARK: Session Delegate

-(void)session:(WCSession *)session
didReceiveMessage:(NSDictionary<NSString *,id> *)message
  replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler
{
    //receive message
    NSString * messageReceived = [message objectForKey:@"messageFromWatch"];
    
    //send reply to sender
    replyHandler(@{@"Confirmation" : @"Message was received. Sincerely, your iPhone"});
    
    //update UI
    self.replyFromWatchLabel.text = messageReceived;
    
}//eom






//MARK: textfield delegates

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField becomeFirstResponder];
    
    //clearing UI
    [self.isWatchReachableLabel setHidden:true];
    self.replyFromWatchLabel.text   = @"";
    
}//eom


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
}//eom

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:true];

}//eom



@end
