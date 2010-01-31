//
//  TESetupAssistant.m
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

#import "TESetupAssistant.h"
#import "NSBundle+Additions.h"
#import "Common.h"

@interface BaseAssistant (Private)
- (void)setParentController:(TESetupAssistant*)aController;
@end
@implementation BaseAssistant (Private)
- (void)setParentController:(TESetupAssistant*)aController { controller = aController; }
@end
@implementation BaseAssistant
+ (id)assistant                 { return [[self new] autorelease]; }
- (OSStatus)prepareAssistant	{ return [NSBundle loadNibNamed:[self assistantNib] owner:self] ? noErr : resNotFound; }
- (void)start					{ /* nothing */ }
- (void)restart					{ [self start]; }
- (void)nextPressed:(id)sender	{ [controller runNextAssistant]; }
- (void)prevPressed:(id)sender	{ [controller runPreviousAssistant]; }
- (NSString *)assistantName		{ return [self className]; }
- (NSString *)assistantNib		{ return [self className]; }
- (NSArray *)orderedSteps		{ return nil; }
- (NSDictionary *)results		{ return nil; }
- (NSView *)view				{ return view; }
- (void)dealloc					{ [view release]; [super dealloc]; }
@end

@interface TESetupAssistant (Private)
- (void)runAssistant:(BaseAssistant*)assistant lastStep:(BOOL)lastStep;
- (void)insertAssistant:(BaseAssistant*)assistant atIndex:(unsigned)index;
@end
@implementation TESetupAssistant

#pragma mark -
#pragma mark Initialization & Destruction Related Things

+ (TESetupAssistant*)assistant
{
	static TESetupAssistant *instance = nil;
	if ( !instance ) instance = [TESetupAssistant new];
	return instance;
}

- (void)awakeFromNib
{
	[window setDelegate:self];
}

- (id)init
{
	if ( (self = [super init]) ) {
		assistants = [NSMutableArray new];
		sessionDict = [NSMutableDictionary new];
	}
	return self;
}

- (id)initMini
{
	if ( (self = [super init]) ) {
		[NSBundle loadNibNamedOrQuit:@"SetupAssistantMini" owner:self];
		assistants = [NSMutableArray new];
		sessionDict = [NSMutableDictionary new];
	}
	return self;
}

- (void)dealloc
{
	[assistants release];
	[window release];
	[super dealloc];
}

- (NSString *)nibName
{
	return @"SetupAssistant";
}

#pragma mark -
#pragma mark Using the Assistant

- (void)addAssistant:(BaseAssistant*)assistant
{
	[self insertAssistant:assistant atIndex:[assistants count]];
}

- (BOOL)run
{
	if ( !window ) [NSBundle loadNibNamedOrQuit:[self nibName] owner:self];
	
	if ( [assistants count] == 0 )
		return NO;
	
	// prepare the stepView, do not allow steps to be added during installation
	NSMutableArray *steps = [NSMutableArray array];
	ENUMERATE(BaseAssistant *, assistant, [assistants objectEnumerator])
		[steps addObjectsFromArray:[assistant orderedSteps]];
	[installStepView setSteps:steps];
	
	// go through all assistants and choose the one with the biggest
	// view size to be the size of the window
	NSRect biggestRect = [window frame];
	NSSize padding = NSMakeSize(NSWidth(biggestRect) - NSWidth([assistantBox frame]),
								NSHeight(biggestRect) - NSHeight([assistantBox frame]));
	biggestRect.size = NSZeroSize;
	
	ENUMERATE(BaseAssistant *, assistant, [assistants objectEnumerator]) {
		NSRect asRect = [[assistant view] frame];
		if ( biggestRect.size.width < asRect.size.width )
			biggestRect.size.width = asRect.size.width;
		if ( biggestRect.size.height < asRect.size.height )
			biggestRect.size.height = asRect.size.height;
	}
	biggestRect.size.height += padding.height;
	biggestRect.size.width  += padding.width;
	[window setFrame:biggestRect display:NO];
	
	// run the first assistant
	[self runAssistant:[assistants objectAtIndex:(currentAssistant = 0)] lastStep:NO];
	[window center];
	[window makeKeyAndOrderFront:self];
	if ( modal ) [NSApp runModalForWindow:window];
	return YES;
}

- (void)reset
{
	[window close];
	if ( modal ) [NSApp stopModal];
	[assistants removeAllObjects];
	[sessionDict removeAllObjects];
	[installStepView clearSteps];
	[assistantBox setContentView:nil];
}

- (BOOL)containsAssistantOfClass:(Class)aClass
{
	ENUMERATE(BaseAssistant *, assistant, [assistants objectEnumerator]) {
		if ( [assistant isMemberOfClass:aClass] )
			return YES;
	}
	return NO;
}

ACC_COMBOP_M(BOOL, modal, Modal)
ACC_COMBOP_M(SEL, userSelector, UserSelector)
ACC_COMBO_M(id, userObject, UserObject)

#pragma mark -
#pragma mark Delegate Methods

// NOTE: this is shit. and don't use windowWillClose, that leads to an inifite loop
//- (void)windowDidChangeScreen:(NSNotification *)note
//{
//	log_debug("%s", __func__);
//	if ( ![window isVisible] ) [self dismissAssistant:self];
//}

#pragma mark -
#pragma mark Assitant Callbacks

- (OSStatus)selectStep:(NSString *)stepName;
{
	[stepTitle setStringValue:stepName];
	OSStatus err = [installStepView selectStep:stepName];
	[installStepView setNeedsDisplay:YES];
	return err;
}

- (void)runNextAssistant
{
	BaseAssistant *assistant = [assistants objectAtIndex:currentAssistant];
	[[NSNotificationCenter defaultCenter] postNotificationName:TEAssistantDidFinishNotification object:assistant];
	
	if ( ++currentAssistant == [assistants count] ) {
		log_debug("all assistants finished");
		[self reset];
		[[NSNotificationCenter defaultCenter] postNotificationName:TESetupAssistantFinishedNotification object:self];
		return;
	}
	
	[self runAssistant:[assistants objectAtIndex:currentAssistant] lastStep:NO];
}

- (void)runPreviousAssistant
{
	BOOL lastStep = NO; // if this is first assistant tell it to start over from the beginning
	
	if ( currentAssistant > 0 ) {
		currentAssistant--;
		lastStep = YES;
	}
	
	[self runAssistant:[assistants objectAtIndex:currentAssistant] lastStep:lastStep];
}

- (void)insertNextAssistant:(BaseAssistant *)assistant
{
	[self insertAssistant:assistant atIndex:currentAssistant+1];
}

- (void)setObject:(id)obj forKey:(id)key
{
	[sessionDict setObject:obj forKey:key];
}

- (id)objectForKey:(id)key
{
	return [sessionDict objectForKey:key];
}

#pragma mark -
#pragma mark Actions

- (IBAction)nextPressed:(id)sender
{
	[[assistants objectAtIndex:currentAssistant] nextPressed:sender];
}

- (IBAction)prevPressed:(id)sender
{
	[[assistants objectAtIndex:currentAssistant] prevPressed:sender];
}

- (IBAction)dismissAssistant:(id)sender
{
	// check to prevent windowDidClose from resulting in multiple calls to this
	if ( [window isVisible] || [assistants count] != 0 ) {
		log_debug("setupassistant dismissed");
		[[NSNotificationCenter defaultCenter] postNotificationName:TESetupAssistantWasDismissedNotification object:self];
		[self reset];
	}
}

#pragma mark -
#pragma mark Accessors
- (BaseAssistant *)prevAssistant
{
	return ( currentAssistant == 0 ) ? nil : [assistants objectAtIndex:currentAssistant-1];
}

- (BaseAssistant *)nextAssistant
{
	return ( currentAssistant+1 >= [assistants count] ) ? nil : [assistants objectAtIndex:currentAssistant+1];
}

- (BaseAssistant *)currAssistant
{
	return [assistants count] > 0 ? [assistants objectAtIndex:currentAssistant] : nil;
}

ACC_RETURN_M(NSWindow *, window)
ACC_RETURN_M(NSButton *, prevButton)
ACC_RETURN_M(NSButton *, nextButton)
ACC_RETURN_M(NSView   *, specialView)
ACC_RETURN_M(NSBox    *, assistantBox)
ACC_RETURN_M(NSArray  *, assistants)
@end


@implementation TESetupAssistant (Private)
- (void)runAssistant:(BaseAssistant*)assistant lastStep:(BOOL)lastStep
{
	NSDisableScreenUpdates();
	
	// reset any possible, innocent changes made from previous assisants
	[prevButton setTitle:@"Go Back"];
	[prevButton setTarget:self];
	[prevButton setAction:@selector(prevPressed:)];
	[nextButton setTitle:@"Next"];
	[nextButton setTarget:self];
	[nextButton setAction:@selector(nextPressed:)];
	[prevButton setEnabled:(currentAssistant != 0)];
	[nextButton setEnabled:YES];
	
	[assistantBox setContentView:[assistant view]];
	[window makeFirstResponder:[assistant view]];
	[self selectStep:[[assistant orderedSteps] objectAtIndex:0]];
	lastStep ? [assistant restart] : [assistant start];
	NSEnableScreenUpdates();
}

- (void)insertAssistant:(BaseAssistant*)assistant atIndex:(unsigned)index
{
	OSStatus err;
	if ( [assistant view] )
	{
		log_warn("%@ has already been prepared", [assistant assistantName]);
	}
	else if ( (err = [assistant prepareAssistant]) != noErr )
	{
		NSRunCriticalAlertPanel(@"Error", @"%@ failed to setup with error: %d. Please contact support.", @"OK",
								nil, nil, [assistant assistantName], err);
		return;
	}
	[assistants insertObject:assistant atIndex:index];
	[assistant setParentController:self];
}
@end


