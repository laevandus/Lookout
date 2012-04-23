//
//  AppDelegate.h
//  Lookout
//
//  Created by Toomas Vahter on 06.04.12.
//  Copyright (c) 2012 Toomas Vahter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
{
	MainWindowController *mainWindowController;
}

@property (weak) IBOutlet NSMenu *cameraMenu;

@end
