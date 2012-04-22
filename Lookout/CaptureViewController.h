//
//  CaptureViewController.h
//  Lookout
//
//  Created by Toomas Vahter on 06.04.12.
//  Copyright (c) 2012 Toomas Vahter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CaptureViewController : NSViewController
{
	BOOL isObservingUserDefaults;
}

@property (nonatomic, readonly, getter = isCapturing) BOOL capturing;

- (void)startCapturing;
- (void)stopCapturing;

@end
