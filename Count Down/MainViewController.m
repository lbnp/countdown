//
//  MainViewController.m
//  Count Down
//
//  Created by 鴨島 潤 on 12/07/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"

@interface MainViewController ()

@end
@implementation MainViewController

@synthesize flipsidePopoverController = _flipsidePopoverController;
@synthesize countDownPicker;
@synthesize countDownLabel;
@synthesize countDownTimer;
@synthesize notification;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.countDownLabel setHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredBackground:) name:@"didEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredForeground:) name:@"didEnterForeground" object:nil];
    isRunning = false;
    duration = 0.0;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
    if ( [self.countDownTimer isValid] ) {
        [self.countDownTimer invalidate];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

- (IBAction)run:(id)sender
{
    if ( !isRunning ) {
        duration = [self.countDownPicker countDownDuration];
        [self updateDuration:duration];
        [self.countDownLabel setHidden:NO];
        [self.countDownPicker setHidden:YES];
        self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    } else {
        [self.countDownTimer invalidate];
        [self.countDownPicker setHidden:NO];
        [self.countDownLabel setHidden:YES];
    }
    isRunning = !isRunning;
}

- (void)timerFired:(NSTimer *)timer
{
    duration -= [timer timeInterval];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateDuration:duration];
        if (duration <= 0.0) {
            [self.countDownTimer invalidate];
            [self playFinishedSound];
        } else if ((uint32_t)duration % 60 == 0) {
            [self playIntervalSound];
        }
    });
}

- (void)updateDuration:(NSTimeInterval)interval
{
    uint32_t hours = (uint32_t)( duration / 3600.0 );
    uint32_t minutes = (uint32_t)( ( duration - hours * 3600.0 ) / 60 );
    uint32_t seconds = (uint32_t)( duration - hours * 3600.0 - minutes * 60.0 );
    countDownLabel.text = [[NSString alloc] initWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

- (void)playFinishedSound
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (void)playIntervalSound
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)enteredBackground:(NSNotification *)notification
{
    if (isRunning) {
        [self.countDownTimer invalidate];
        date = [NSDate dateWithTimeIntervalSinceNow:duration];
        NSLog([date description]);
        self.notification = [[UILocalNotification alloc] init];
        self.notification.fireDate = date;
        self.notification.timeZone = [NSTimeZone defaultTimeZone];
        self.notification.alertAction = @"timer fired";
        self.notification.alertBody = @"timer fired!";
        self.notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:self.notification];
    }
}

- (void)enteredForeground:(NSNotification *)notification
{
    if (isRunning) {
        NSTimeInterval newDuration = [self.notification.fireDate timeIntervalSinceNow];
        if (newDuration > 0.0) {
            duration = newDuration;
            self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        } else {
            duration = 0.0;
            [self.countDownPicker setHidden:NO];
            [self.countDownLabel setHidden:YES];
            isRunning = !isRunning;
        }
        [self updateDuration:duration];
        [[UIApplication sharedApplication] cancelLocalNotification:self.notification];
    }
}

@end
