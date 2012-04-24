//
//  CaptureViewController.m
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

#import "CaptureViewController.h"
#import "CaptureLayoutManager.h"

#import <QTKit/QTKit.h>
#import <QuartzCore/QuartzCore.h>


@interface CaptureViewController ()

@property (nonatomic, readwrite, getter = isCapturing) BOOL capturing;

- (void)_enableLayerBacking;

- (void)didConnectDevice:(NSNotification *)notification;
- (void)didDisconnectDevice:(NSNotification *)notification;
- (void)_updatePixelBufferAttributesForSession:(QTCaptureSession *)session;

- (void)_startObservingUserDefaults;
- (void)_stopObservingUserDefaults;
@end

@implementation CaptureViewController

@synthesize capturing = _capturing;

- (id)init
{
	return [self initWithNibName:@"CaptureView" bundle:nil];
}


- (void)dealloc
{
	[self _stopObservingUserDefaults];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark Loading View

- (void)loadView
{
	[super loadView];
	
	[self _enableLayerBacking];
	[self _startObservingUserDefaults];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectDevice:) name:QTCaptureDeviceWasConnectedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnectDevice:) name:QTCaptureDeviceWasDisconnectedNotification object:nil];
}


- (void)_enableLayerBacking
{
	CALayer *layer = [CALayer layer];
	CGColorRef color = CGColorCreateGenericGray(0.5, 1.0);
	layer.backgroundColor = color;
	CGColorRelease(color);
	
	[layer setLayoutManager:[[CaptureLayoutManager alloc] init]];
	
	[self.view setLayer:layer];
	[self.view setWantsLayer:YES];
}


#pragma mark -
#pragma mark Device Configuration

- (void)didConnectDevice:(NSNotification *)notification
{
	if (self.isCapturing) 
	{
		[self stopCapturing];
		[self startCapturing];
	}
}


- (void)didDisconnectDevice:(NSNotification *)notification
{
	if (self.isCapturing) 
	{
		[self stopCapturing];
		[self startCapturing];
	}
}


- (void)_updatePixelBufferAttributesForSession:(QTCaptureSession *)session
{
	/*
	 http://www.mailinglistarchive.com/quicktime-api@lists.apple.com/msg03515.html
	 David Underwood (QuickTime Engineering):
	 "The short answer is that there is currently no API in QTKit for directly configuring the camera. As others have noted, QTKit will automatically adjust the camera resolution to best accommodate the requirements of all of the outputs connected to a session. For example setting the compression options of a movie file output or the pixel buffer attributes of a decompressed video output can cause the camera resolution to be adjusted for optimal performance. In general, if you are interested in configuring the camera because you want your output video to be at a specific resolution it makes more sense to configure your outputs directly and not worry about the camera settings, which is the functionality currently provided by QTKit. If you want access to the camera controls for other reasons, we don't currently provide a solution in QTKit (we are taking enhancement requests that have been filed under consideration, however)."
	 */
	NSNumber *preferredHeight = [[NSUserDefaults standardUserDefaults] objectForKey:kLookoutPreferredVideoHeight];
	NSNumber *preferredWidth = [[NSUserDefaults standardUserDefaults] objectForKey:kLookoutPreferredVideoWidth];
	
	for (QTCaptureVideoPreviewOutput *output in [session outputs]) 
	{
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:preferredWidth, (id)kCVPixelBufferWidthKey, preferredHeight, (id)kCVPixelBufferHeightKey, nil];
		[output setPixelBufferAttributes:attributes];
	}
}


#pragma mark -
#pragma mark KVO

static void *VideoResolutionContext = "VideoResolutionContext";
static void *DeviceContext = "DeviceContext";

- (void)_startObservingUserDefaults
{
	if (!isObservingUserDefaults) 
	{
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.PreferredVideoHeight" options:0 context:VideoResolutionContext];
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.PreferredVideoWidth" options:0 context:VideoResolutionContext];
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.DisabledDeviceIDs" options:0 context:DeviceContext];
		
		isObservingUserDefaults = YES;
	}
}


- (void)_stopObservingUserDefaults
{
	if (isObservingUserDefaults) 
	{
		[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:@"values.PreferredVideoHeight"];
		[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:@"values.PreferredVideoWidth"];
		[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:@"values.DisabledDeviceIDs"];
		
		isObservingUserDefaults = NO;
	}
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
    if (context == VideoResolutionContext) 
	{
		if ([object isKindOfClass:[NSUserDefaultsController class]]) 
		{
			for (QTCaptureLayer *captureLayer in [[self.view layer] sublayers]) 
			{			
				[self _updatePixelBufferAttributesForSession:[captureLayer session]];
			}
		}
    } 
	else if (context == DeviceContext)
	{
		if ([object isKindOfClass:[NSUserDefaultsController class]]) 
		{
			if (self.isCapturing) 
			{
				[self stopCapturing];
				[self startCapturing];
			}
		}
	}
	else 
	{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark -
#pragma mark Starting/Stopping

- (void)startCapturing
{			
	self.capturing = YES;
	
	NSArray *disabledDevices = [[NSUserDefaults standardUserDefaults] objectForKey:kLookoutDisabledDeviceIDs];
	
	for (QTCaptureDevice *captureDevice in [QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo]) 
	{
		NSError *error = nil;
		
		if (![disabledDevices containsObject:[captureDevice uniqueID]]) 
		{
			if ([captureDevice open:&error])
			{
				QTCaptureDeviceInput *deviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:captureDevice];
				QTCaptureSession *captureSession = [[QTCaptureSession alloc] init];
				
				if ([captureSession addInput:deviceInput error:&error])
				{
					QTCaptureLayer *sublayer = [QTCaptureLayer layerWithSession:captureSession];
					
					CGColorRef color = CGColorCreateGenericGray(0.8, 1.0);
					sublayer.backgroundColor = color;
					CGColorRelease(color);
					
					[[self.view layer] addSublayer:sublayer];
					
					[captureSession startRunning];
					
					[self _updatePixelBufferAttributesForSession:captureSession];
				}
				else 
				{
					NSLog(@"%s Failed adding input device to session (device = %@, session = %@) with error (%@)", __func__, [captureDevice localizedDisplayName], captureSession, [error localizedDescription]);
				}
			}
		}
		else 
		{
			NSLog(@"%s Failed opening device (%@) with error (%@)", __func__, [captureDevice localizedDisplayName], [error localizedDescription]);
		}
	}
}


- (void)stopCapturing
{
	self.capturing = NO;
	
	QTCaptureLayer *captureLayer = nil;
	
	for (captureLayer in [[self.view layer] sublayers]) 
	{
		[[captureLayer session] stopRunning];
		
		for (QTCaptureDeviceInput *input in [[captureLayer session] inputs]) 
		{
			[[input device] close];
		}
	}
	
	[[[self.view layer] sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
}

@end

// UserDefaults

const NSString *kLookoutDisabledDeviceIDs = @"DisabledDeviceIDs";
const NSString *kLookoutPreferredVideoHeight = @"PreferredVideoHeight";
const NSString *kLookoutPreferredVideoWidth = @"PreferredVideoWidth";

