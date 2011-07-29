//
//  AutoLogOutAppDelegate.h
//  AutoLogOut
//
//  Created by Joseph_Rafferty on 7/28/11.
//  Copyright 2011 Baylor University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ALAlertController.h>

@interface AutoLogOutAppDelegate : NSObject <NSApplicationDelegate> {
    ALAlertController *alertController;
}

- (IBAction)showAlertPanel:(id)sender;

@end
