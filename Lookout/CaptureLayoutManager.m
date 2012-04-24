//
//  CaptureLayoutManager.m
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

#import "CaptureLayoutManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation CaptureLayoutManager

#define kSublayerSpacing	10.f

// 4:3 ratio is used for sublayers

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
	NSUInteger sublayerCount = [[layer sublayers] count];
	
	if (sublayerCount == 0) 
		return;
	
	// Disable animations
	[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
	
	CGSize superlayerSize = [layer bounds].size;
	CGFloat superlayerRatio = superlayerSize.width / superlayerSize.height;
	NSUInteger columnCount = MIN(ceilf(superlayerRatio), sublayerCount);
	NSUInteger rowCount = ceilf((CGFloat)sublayerCount / (CGFloat)columnCount);
	
	//NSLog(@"ratio = %lf rows = %lu columns = %lu", superlayerRatio, rowCount, columnCount);
	
	CGFloat sublayerWidth = ceilf((superlayerSize.width - (1.0 + (CGFloat)columnCount) * kSublayerSpacing) / (CGFloat)columnCount);
	CGFloat sublayerHeight = ceilf(0.75 * sublayerWidth);
	
	// Does it fit heightwise?
	if ((sublayerHeight * (CGFloat)rowCount + (1.0 + (CGFloat)rowCount) * kSublayerSpacing) > superlayerSize.height) 
	{
		sublayerHeight = ceilf((superlayerSize.height - (1.0 + (CGFloat)rowCount) * kSublayerSpacing) / (CGFloat)rowCount);
		sublayerWidth = ceilf(1.25 * sublayerHeight);
	}
	
	// Calculate margins
	CGFloat marginX = ceilf((superlayerSize.width - (sublayerWidth * (CGFloat)columnCount + (1.0 + (CGFloat)columnCount) * kSublayerSpacing)) / 2.0);
	CGFloat marginY = ceilf((superlayerSize.height - (sublayerHeight * (CGFloat)rowCount + (1.0 + (CGFloat)rowCount) * kSublayerSpacing)) / 2.0);
	
	__block NSUInteger currentRow = 0;
	__block NSUInteger currentColumn = 0;
	__block CGRect sublayerFrame = CGRectMake(0.0, 0.0, sublayerWidth, sublayerHeight);
	
	[layer.sublayers enumerateObjectsUsingBlock:^(CALayer *sublayer, NSUInteger idx, BOOL *stop) 
	{
		sublayerFrame.origin.x = ceilf(marginX + (1.0 + (CGFloat)currentColumn) * kSublayerSpacing + (CGFloat)currentColumn * sublayerWidth);
		sublayerFrame.origin.y = ceilf(marginY + (1.0 + (CGFloat)currentRow) * kSublayerSpacing + (CGFloat)currentRow * sublayerHeight);
		
		sublayer.frame = sublayerFrame;
		
		currentColumn++;
		
		if (currentColumn == columnCount) 
		{
			currentColumn = 0;
			currentRow++;
		}
	}];
}

@end
