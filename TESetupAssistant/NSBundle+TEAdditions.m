//
//  NSBundle+Additions.m
//  Espionage
//
//  Created by Greg Slepak on 12/3/08.
//  Copyright 2008 Tao Effect LLC. All rights reserved.
//

#import <CoreServices/CoreServices.h>
#import "NSBundle+TEAdditions.h"
#import "Common.h"

@implementation NSBundle (TEAdditions)
+ (void)loadNibNamedOrQuit:(NSString *)aNibName owner:(id)owner
{
	if ( ! [self loadNibNamed:aNibName owner:owner] ) {
		[NSApp activateIgnoringOtherApps:YES];
		NSRunCriticalAlertPanel(@"Missing Resource", @"Couldn't load the file %@.nib!"
								"\n\nThis can happen if you move Espionage after running it.", @"OK", nil, nil, aNibName);
		[NSApp terminate:self];
	}
}

+ (NSBundle*)locateAppBundleWithIdentifier:(NSString *)bundleID
{
	NSBundle *bundle = nil;
	NSURL *bundleURL = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:bundleID];
	FAIL_IFQ(!bundleURL, log_err("couldn't get URL for app with bundleID: %@", bundleID));
	bundle = [NSBundle bundleWithURL:bundleURL];
fail_label:
	return bundle;
}

//+ (NSBundle*)locateAppBundleWithName:(NSString *)name
//{
//	NSBundle *bundle = nil;
//	NSURL *bundleURL = nil;
//	OSStatus err = LSFindApplicationForInfo(kLSUnknownCreator, NULL, (CFStringRef)name, NULL, (CFURLRef*)&bundleURL);
//	FAIL_IFQ(err == kLSApplicationNotFoundErr);
//	FAIL_IFQ(err != noErr, log_err("LSFindApplicationForInfo returned %d for bundle: %@", err, name));
//	FAIL_IFQ(!bundleURL, log_err("LSFindApplicationForInfo didn't give us the bundleURL!"));
//	
//	bundle = [NSBundle bundleWithPath:[bundleURL path]];
//	[bundleURL release]; // see docs for LSFindApplicationForInfo, says so
//	
//fail_label:
//	return bundle;
//}

+ (NSBundle*)locationResistantBundle
{
	static NSBundle *lastGoodBundle = nil;
	static FSRef bundleRef;
	NSURL *ourURL = nil;
	
	if ( __unlikely(!lastGoodBundle) )
	{
		ourURL = [[self mainBundle] bundleURL];
		
		if ( !CFURLGetFSRef((__bridge CFURLRef)ourURL, &bundleRef) )
			 log_err("Couldn't get URL for our bundle!");
		else
			lastGoodBundle = [self mainBundle];
		
		return lastGoodBundle;
	}
	
	ourURL = (__bridge NSURL*)CFURLCreateFromFSRef(NULL, &bundleRef);
	
	if ( __unlikely(![ourURL isEqual:[lastGoodBundle bundleURL]]) )
		lastGoodBundle = [NSBundle bundleWithURL:ourURL];
	
	return lastGoodBundle;
}

+ (BOOL)safeLoadNibNamed:(NSString *)nibName owner:(id)owner
{
	NSNib *nib = [[NSNib alloc] initWithNibNamed:nibName bundle:[self locationResistantBundle]];
	BOOL result = [nib instantiateNibWithOwner:owner topLevelObjects:nil];
//	[nib release]; // from "Departments and Employees" sample code. I know, docs don't say anything.
	return result;
}
@end
