//
//  AppDelegate.m
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

#import "AppDelegate.h"
#import "MainWindowController.h"
#import "CaptureViewController.h" // kLookout

@interface AppDelegate()
- (void)_rebuildCameraMenu;
@end

@implementation AppDelegate

@synthesize cameraMenu = _cameraMenu;

+ (void)initialize
{
	if (self == [AppDelegate class]) 
	{
		NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:640], kLookoutPreferredVideoWidth, [NSNumber numberWithInteger:480], kLookoutPreferredVideoHeight, nil];
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	}
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	mainWindowController = [[MainWindowController alloc] init];
	[mainWindowController showWindow:self];
	
	[self.cameraMenu setAutoenablesItems:NO];
	[self.cameraMenu setDelegate:self];
	[self _rebuildCameraMenu];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_rebuildCameraMenu) name:QTCaptureDeviceWasConnectedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_rebuildCameraMenu) name:QTCaptureDeviceWasDisconnectedNotification object:nil];
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)_rebuildCameraMenu
{	
	[self.cameraMenu removeAllItems];
	
	for (QTCaptureDevice *captureDevice in [QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo]) 
	{
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[captureDevice localizedDisplayName] action:@selector(toggleCameraState:) keyEquivalent:@""];
		[item setRepresentedObject:[captureDevice uniqueID]];
		[item setState:NSOnState];

		[self.cameraMenu addItem:item];
	}
}


- (void)menuNeedsUpdate:(NSMenu *)menu
{
	if (menu == self.cameraMenu) 
	{
		NSArray *disabledDevices = [[NSUserDefaults standardUserDefaults] objectForKey:kLookoutDisabledDeviceIDs];
		
		for (NSMenuItem *item in [menu itemArray]) 
		{
			[item setState:([disabledDevices containsObject:[item representedObject]]) ? NSOffState : NSOnState];
		}
	}
}



@end
