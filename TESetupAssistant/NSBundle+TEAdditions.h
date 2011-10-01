//
//  NSBundle+Additions.h
//  Espionage
//
//  Created by Greg Slepak on 12/3/08.
//  Copyright 2008 Tao Effect LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBundle (TEAdditions)
+ (void)loadNibNamedOrQuit:(NSString *)aNibName owner:(id)owner;
+ (NSBundle*)locateAppBundleWithIdentifier:(NSString *)bundleID;
//+ (NSBundle*)locateAppBundleWithName:(NSString *)name;

// call this once at the start of your program in your main thread
// and use it in place of mainBundle for loading nibs
+ (NSBundle*)locationResistantBundle;

// this uses the above to load the nib safely
+ (BOOL)safeLoadNibNamed:(NSString *)nibName owner:(id)owner;
@end
