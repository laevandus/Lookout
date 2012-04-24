//
//  MainWindowController.m
//  Lookout
//
//  Created by Toomas Vahter on 06.04.12.
//  Copyright (c) 2012 Toomas Vahter. All rights reserved.
//
//  This content is released under the MIT License (http://www.opensource.org/licenses/mit-license.php).
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "MainWindowController.h"
#import "CaptureViewController.h"

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
		[resolutionPopover setContentViewController:[[NSViewController alloc] initWithNibName:@"ResolutionView" bundle:nil]];
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
