//
//  MainWindowController.h
//  Lookout
//
//  Created by Toomas Vahter on 06.04.12.
//  Copyright (c) 2012 Toomas Vahter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@class CaptureViewController;

@interface MainWindowController : NSWindowController
{
	NSPopover *resolutionPopover;
	
	CaptureViewController *contentViewController;
	
	QTCaptureSession *captureSession;
	QTCaptureDeviceInput *deviceInput;
}

@property (weak) IBOutlet id toggleButton;

- (IBAction)toggleLookout:(id)sender;
- (IBAction)changeResolution:(id)sender;

@end
