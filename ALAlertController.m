//
//  ALAlertController.m
//  AutoLogOut
//
//  Created by Joseph_Rafferty on 7/28/11.
//  Copyright 2011 Baylor University. All rights reserved.
//

#import "ALAlertController.h"
#include <CoreServices/CoreServices.h>
#include <Carbon/Carbon.h>

static OSStatus SendAppleEventToSystemProcess(AEEventID EventToSend);

@implementation ALAlertController

@synthesize seconds;

- (id)init
{
    self = [super initWithWindowNibName:@"Alert"];
    if (self) {
        
        // Pull the time we should count down from a preference file (for MCX control)
        NSInteger defaultDuration = [[NSUserDefaults standardUserDefaults] integerForKey:@"countdownDuration"];
        
        countdownDuration = (defaultDuration && defaultDuration > 0) ? defaultDuration : 120;
        seconds = countdownDuration;
    }
    return self;
}

- (void)windowDidLoad
{    
    // Brings window front and center (and in focus)
    [self.window makeKeyAndOrderFront:self];      
    
    // Puts window order above most others (forcing the user to act)
    [self.window setLevel:NSFloatingWindowLevel]; 
    
    // Default button simply closes the app in case the use actually is there
    [self.window setDefaultButtonCell:[cancelLogOutButton cell]]; 
    
    // Play a beep to try and get the user's attention if they aren't looking at the screen
    // Note: if the user's volume is muted, no beep will audiate.
    // Therefore, it is recommended to turn on Universal Access's "Flash the screen when an alert sound occurs" (com.apple.universalaccess flashScreen -bool yes)

    NSBeep();
    
    // Decrement the countdown every second. (Note: this is NOT precisely once per second.)
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(decrementCountdown) userInfo:nil repeats:YES];
}

- (IBAction)doLogOut:(id)sender
{
    // Some apps will terminate the log out sequence if they return NSTerminateCancel (ie. if they have unsaved changes).
    // To prevent this, we want to force terminate these applications.
    
    // Get a list of currently running applications in our session
    NSArray *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
    
    for (NSRunningApplication *app in runningApps) {
        
        // Exclude ourselves (we will exit normally) and Finder from this list
        if (![[app localizedName] isEqualToString:@"Finder"] && ![[app localizedName] isEqualToString:[[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleName"]]) {
            NSLog(@"Killing: %@", [app localizedName]);
            [app forceTerminate]; // Terminates the app without giving it a chance to confirm with the user
        }
    }
    
    // Send Apple Event to log out
    SendAppleEventToSystemProcess(kAEReallyLogOut);
}

- (IBAction)cancelLogOut:(id)sender
{
    NSLog(@"User terminated auto log out sequence");
    // The user is there or has come back - we have nothing left to do, so exit
    [NSApp terminate:nil];
}

- (void)decrementCountdown
{
    // Decrement the seconds counter
    self.seconds = seconds - 1;

    // Handle when out counter runs all the way down
    if (seconds < 0) {
        
        // Stop the timer (loop)
        [timer invalidate];
        
        // Notify the user what we're doing (even though it may only appear for a split second, its a nice gesture ;))
        [countdownText setStringValue:[NSString stringWithString:@"Force quitting all applications and logging out..."]];
        
        // Kick off the log out process
        [self doLogOut:self];
    }
    
}

// Handles sending the Apple event to the system process
// Source: http://developer.apple.com/library/mac/#qa/qa1134/_index.html

OSStatus SendAppleEventToSystemProcess(AEEventID EventToSend)
{
    AEAddressDesc targetDesc;
    static const ProcessSerialNumber kPSNOfSystemProcess = { 0, kSystemProcess };
    AppleEvent eventReply = {typeNull, NULL};
    AppleEvent appleEventToSend = {typeNull, NULL};
    
    OSStatus error = noErr;
    
    error = AECreateDesc(typeProcessSerialNumber, &kPSNOfSystemProcess, 
                         sizeof(kPSNOfSystemProcess), &targetDesc);
    
    if (error != noErr)
    {
        return(error);
    }
    
    error = AECreateAppleEvent(kCoreEventClass, EventToSend, &targetDesc, 
                               kAutoGenerateReturnID, kAnyTransactionID, &appleEventToSend);
    
    AEDisposeDesc(&targetDesc);
    if (error != noErr)
    {
        return(error);
    }
    
    error = AESend(&appleEventToSend, &eventReply, kAENoReply, 
                   kAENormalPriority, kAEDefaultTimeout, NULL, NULL);
    
    AEDisposeDesc(&appleEventToSend);
    if (error != noErr)
    {
        return(error);
    }
    
    AEDisposeDesc(&eventReply);
    
    return(error); 
}

@end
