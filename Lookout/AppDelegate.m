//
//  AppDelegate.m
//  Lookout
//
//  Created by Toomas Vahter on 06.04.12.
//  Copyright (c) 2012 Toomas Vahter. All rights reserved.
//

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
