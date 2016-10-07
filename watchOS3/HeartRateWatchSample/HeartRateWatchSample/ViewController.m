//
//  ViewController.m
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/4/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    HealthDataService *permission;
}
@end

@implementation ViewController


#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    permission = [[HealthDataService alloc]init];
    [permission requestPermission:^(BOOL success, NSError *error) {
        
    }];
}//eom

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
