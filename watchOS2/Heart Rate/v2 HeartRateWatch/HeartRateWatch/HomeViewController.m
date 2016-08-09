//
//  ViewController.m
//  HeartRateWatch
//
//  Created by Luis Castillo on 7/27/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()
{
    HeartRateManager * heartRateModel;
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    heartRateModel = [[HeartRateManager alloc]init];
    heartRateModel.delegate = self;
    
    BOOL result = [heartRateModel start];
    if (result == false) {
        NSLog(@"un-able to start Heart Rate");
    }
    else
    {
        [heartRateModel startStreamingQuery];
    }
}//eom


#pragma mark: Delegates
-(void)heartRateManager_results:(HKQuantitySample *)quantitySample
{
    NSLog(@"%@", quantitySample);
}//eom

#pragma mark: Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
