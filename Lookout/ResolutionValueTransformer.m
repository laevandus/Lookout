//
//  ResolutionValueTransformer.m
//  Lookout
//
//  Created by Toomas Vahter on 15.04.12.
//  Copyright (c) 2012 Toomas Vahter. All rights reserved.
//

#import "ResolutionValueTransformer.h"

@implementation ResolutionValueTransformer

+ (Class)transformedValueClass 
{ 
	return [NSString class]; 
}


+ (BOOL)allowsReverseTransformation 
{ 
	return NO; 
}


- (id)transformedValue:(id)value 
{
    return (value == nil) ? nil : [NSString stringWithFormat:@"%lu", [value integerValue]];
}


- (id)reverseTransformedValue:(id)value
{
	return (value == nil) ? nil : [NSNumber numberWithInteger:[value integerValue]];
}


@end
