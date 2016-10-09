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
    HeartrateModel_Phone *hrModel;
    NSDateFormatter * df;
}
@end

@implementation ViewController

@synthesize hrValueLabel,hrStartDateLabel, hrEndDateLabel;

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    hrValueLabel .text = @" ";
    hrStartDateLabel .text = @" ";
    hrEndDateLabel .text = @" ";
    
    df = [[NSDateFormatter alloc]init];
    df.dateStyle = NSDateFormatterShortStyle;
    df.timeStyle = NSDateFormatterMediumStyle;
    
    hrModel = [ [HeartrateModel_Phone alloc] init];
    hrModel.delegate = self;
    
    //permission
    [hrModel requestPermission:^(BOOL success, NSError *error)
    {
        
    }];
    
    //request to start workout
    [hrModel start];
}//eom

#pragma mark - HR Model Delegates
-(void)heartrateModelDidReceiveHeartrate:(double)hrValue
                           withStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate
{
    NSString * hr    = [NSString stringWithFormat:@"%.1f bpm", hrValue];
    NSString * sdate = [df stringFromDate:startDate];
    NSString * edate = [df stringFromDate:endDate];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        hrValueLabel .text = hr;
        hrStartDateLabel .text = sdate;
        hrEndDateLabel .text = edate;
    });
    
    NSLog(@"%@ | Sdate: %@ | Edate: %@", hr, sdate, edate);
}//eom

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
