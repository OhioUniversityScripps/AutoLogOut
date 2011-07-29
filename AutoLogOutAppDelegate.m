//
//  AutoLogOutAppDelegate.m
//  AutoLogOut
//
//  Created by Joseph_Rafferty on 7/28/11.
//  Copyright 2011 Baylor University. All rights reserved.
//
//  Not concerned with memory leaks since most of time we'll only be running for 0.05 seconds

#import "AutoLogOutAppDelegate.h"
#import "ALAlertController.h"

@implementation AutoLogOutAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Default behavior should be TO perform the automatic logout.
    BOOL disableAutoLogOut = [[NSUserDefaults standardUserDefaults] boolForKey:@"disableAutoLogOut"];
    
    if (disableAutoLogOut) {
        // Someone said we shouldn't log out automatically. We have nothing left to do
        [NSApp terminate:nil];
    }
    
    // Get our current idleTime (time since any HID activity)
    CFTimeInterval idleTime = CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateHIDSystemState, kCGAnyInputEventType);
    
    // Check preference file for the idle time threshold. 15 minute default if nothing is specified
    NSInteger defaultIdleTimeThreshold = [[NSUserDefaults standardUserDefaults] integerForKey:@"idleTimeBeforeAutoLogOut"];
    NSInteger idleTimeThreshold = (defaultIdleTimeThreshold) ? defaultIdleTimeThreshold : 900;
    
    if (idleTime > idleTimeThreshold) {
        
        // Kick off the automatic log out alert
        [self showAlertPanel:self];
        
    } else {
        
        // Haven't been idle long enough. Nothing left to do, quit the app
        [NSApp terminate:nil];
        
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    exit(0);
}

- (IBAction)showAlertPanel:(id)sender
{
    if (!alertController) {
        alertController = [[ALAlertController alloc] init];
    }
    
    // Show the log out alert window
    [alertController showWindow:self];
}
@end
