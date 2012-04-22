//
//  AppDelegate.m
//  Lookout
//
//  Created by Toomas Vahter on 06.04.12.
//  Copyright (c) 2012 Toomas Vahter. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@implementation AppDelegate

+ (void)initialize
{
	if (self == [AppDelegate class]) 
	{
		NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:640], @"MaximumVideoWidth", [NSNumber numberWithInteger:480], @"MaximumVideoHeight", nil];
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	}
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	mainWindowController = [[MainWindowController alloc] init];
	[mainWindowController showWindow:self];
}

@end
