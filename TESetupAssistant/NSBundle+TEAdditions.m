//
//  NSBundle+Additions.m
//
//  Copyright (c) 2010 Tao Effect LLC
// 	
//  You are free to use this software and associated materials
//  (the "Software") however you like so long as you:
// 	
//  1) Provide attribution to the original author and include
//     a hyperlink to original website of the Software in any
//     application using the Software.
//  2) Include the above copyright notice and this agreement in
//     all copies or substantial portions of the Software.
// 	
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
//  KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
//  THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <CoreServices/CoreServices.h>
#import "NSBundle+Additions.h"
#import "Common.h"

@implementation NSBundle (TEAdditions)
+ (void)loadNibNamedOrQuit:(NSString *)aNibName owner:(id)owner
{
	if ( ! [self loadNibNamed:aNibName owner:owner] ) {
		[NSApp activateIgnoringOtherApps:YES];
		NSRunCriticalAlertPanel(@"Missing Resource", @"Couldn't load the file %@.nib!"
								@"\n\nThis can happen if you move %@ after running it.",
								@"OK", nil, nil,
								aNibName, [[self mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]);
		[NSApp terminate:self];
	}
}

+ (NSBundle*)locateAppBundleWithIdentifier:(NSString *)bundleID
{
	NSBundle *bundle = nil;
	NSURL *bundleURL = nil;
	OSStatus err = LSFindApplicationForInfo(kLSUnknownCreator, (CFStringRef)bundleID, NULL, NULL, (CFURLRef*)&bundleURL);
	FAIL_IFQ(err == kLSApplicationNotFoundErr);
	FAIL_IFQ(err != noErr, log_err("LSFindApplicationForInfo returned %d for bundle: %@", err, bundleID));
	FAIL_IFQ(!bundleURL, log_err("LSFindApplicationForInfo didn't give us the bundleURL!"));
	
	bundle = [NSBundle bundleWithPath:[bundleURL path]];
	[bundleURL release]; // see docs for LSFindApplicationForInfo, says so
	
fail_label:
	return bundle;
}

+ (NSBundle*)locateAppBundleWithName:(NSString *)name
{
	NSBundle *bundle = nil;
	NSURL *bundleURL = nil;
	OSStatus err = LSFindApplicationForInfo(kLSUnknownCreator, NULL, (CFStringRef)name, NULL, (CFURLRef*)&bundleURL);
	FAIL_IFQ(err == kLSApplicationNotFoundErr);
	FAIL_IFQ(err != noErr, log_err("LSFindApplicationForInfo returned %d for bundle: %@", err, name));
	FAIL_IFQ(!bundleURL, log_err("LSFindApplicationForInfo didn't give us the bundleURL!"));
	
	bundle = [NSBundle bundleWithPath:[bundleURL path]];
	[bundleURL release]; // see docs for LSFindApplicationForInfo, says so
	
fail_label:
	return bundle;
}

+ (NSBundle*)locationResistantBundle
{
	static NSBundle *lastGoodBundle = nil;
	static FSRef bundleRef;
	NSURL *ourURL = nil;
	
	if ( __unlikely(!lastGoodBundle) )
	{
		ourURL = [NSURL fileURLWithPath:[[self mainBundle] bundlePath]];
		
		if ( !CFURLGetFSRef((CFURLRef)ourURL, &bundleRef) )
			 log_err("Couldn't get URL for our bundle!");
		else
			lastGoodBundle = [[self mainBundle] retain];
		
		return lastGoodBundle;
	}
	
	ourURL = (NSURL*)CFURLCreateFromFSRef(NULL, &bundleRef);
	
	if ( __unlikely(![[ourURL path] isEqual:[lastGoodBundle bundlePath]]) )
		ASSIGN(lastGoodBundle, [NSBundle bundleWithPath:[ourURL path]]);
	
	[ourURL release];
	return lastGoodBundle;
}

+ (BOOL)safeLoadNibNamed:(NSString *)nibName owner:(id)owner
{
	NSNib *nib = [[NSNib alloc] initWithNibNamed:nibName bundle:[self locationResistantBundle]];
	BOOL result = [nib instantiateNibWithOwner:owner topLevelObjects:nil];
	[nib release]; // from "Departments and Employees" sample code. I know, docs don't say anything.
	return result;
}
@end
