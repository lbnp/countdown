//
//  MainViewController.h
//  Count Down
//
//  Created by 鴨島 潤 on 12/07/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "AudioToolbox/AudioServices.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate> {
    BOOL isRunning;
    NSTimeInterval duration;
}

- (IBAction)run:(id)sender;
- (void)timerFired:(NSTimer *)timer;
- (void)updateDuration:(NSTimeInterval)interval;
- (void)playFinishedSound;
- (void)playIntervalSound;

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (strong, nonatomic) IBOutlet UIDatePicker *countDownPicker;
@property (strong, nonatomic) IBOutlet UILabel *countDownLabel;
@property (strong, nonatomic) NSTimer *countDownTimer;

@end
