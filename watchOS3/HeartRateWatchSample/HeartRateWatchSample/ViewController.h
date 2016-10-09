//
//  ViewController.h
//  HeartRateWatchSample
//
//  Created by Luis Castillo on 10/4/16.
//  Copyright © 2016 LC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HeartrateModel_Phone.h"

@interface ViewController : UIViewController<HeartrateModelDelegate>



@property (weak, nonatomic) IBOutlet UILabel *hrValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *hrStartDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *hrEndDateLabel;

@end

