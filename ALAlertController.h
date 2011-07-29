//
//  ALAlertController.h
//  AutoLogOut
//
//  Created by Joseph_Rafferty on 7/28/11.
//  Copyright 2011 Baylor University. All rights reserved.
//



@interface ALAlertController : NSWindowController {    
    IBOutlet NSTextField *countdownText;    // Label in our alert window which contains the countDown
    
    IBOutlet NSButton *doLogOutButton;      // Log out button
    IBOutlet NSButton *cancelLogOutButton;  // "I'm still here" button
    
    NSTimer *timer;                         // 1-second timer which decrements our countdown
    
    NSInteger countdownDuration;            // How long our countdown will be
    NSInteger seconds;                      // Countdown counter (current time in countdown). countdownText's value in the NIB is bound to this
}

- (void)decrementCountdown;                 // Decrements our countdown and handles the countdown end

- (IBAction)doLogOut:(id)sender;            // Kicks off the logout sequence
- (IBAction)cancelLogOut:(id)sender;        // Quits the app

@property (assign) NSInteger seconds;

@end
