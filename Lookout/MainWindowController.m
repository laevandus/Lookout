//
//  MainWindowController.m
//  Lookout
//
//  Created by Toomas Vahter on 06.04.12.
//  Copyright (c) 2012 Toomas Vahter. All rights reserved.
//

#import "MainWindowController.h"
#import "CaptureViewController.h"
#import "ResolutionViewController.h"

@implementation MainWindowController

@synthesize toggleButton = _toggleButton;

- (id)init
{
	return [self initWithWindowNibName:@"MainWindow"];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
	
	contentViewController = [[CaptureViewController alloc] init];
	NSView *captureView = contentViewController.view;
	NSView *contentView = [self.window contentView];
	[captureView setFrame:[[self.window contentView] frame]];
	[contentView addSubview:contentViewController.view];
	
	[captureView setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	NSButton *button = self.toggleButton;
	NSDictionary *views = NSDictionaryOfVariableBindings(captureView, button);
	
	[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[captureView]|" options:0 metrics:nil views:views]];
	[contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[captureView]-60-|" options:0 metrics:nil views:views]];
}


- (IBAction)toggleLookout:(id)sender 
{
	if (contentViewController.isCapturing) 
	{
		[contentViewController stopCapturing];
	}
	else 
	{
		[contentViewController startCapturing];
	}
}


- (IBAction)changeResolution:(id)sender
{
	if (!resolutionPopover) 
	{
		resolutionPopover = [[NSPopover alloc] init];
		resolutionPopover.behavior = NSPopoverBehaviorSemitransient;
		[resolutionPopover setContentViewController:[[ResolutionViewController alloc] init]];
		[resolutionPopover setContentSize:NSMakeSize(327.0, 62.0)];
	}
	
	if (![resolutionPopover isShown]) 
		[resolutionPopover showRelativeToRect:NSZeroRect ofView:sender preferredEdge:NSMinXEdge];
}


- (void)toggleCameraState:(NSMenuItem *)menuitem
{
	NSString *uniqueID = [menuitem representedObject];
	NSMutableArray *disabledDevices = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kLookoutDisabledDeviceIDs]];
	
	if ([disabledDevices containsObject:uniqueID]) 
	{
		// Enable
		[disabledDevices removeObject:uniqueID];
	}
	else 
	{
		// Disable
		[disabledDevices addObject:uniqueID];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:disabledDevices forKey:kLookoutDisabledDeviceIDs];
}

@end
