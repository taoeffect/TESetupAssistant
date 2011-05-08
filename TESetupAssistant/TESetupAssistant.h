//
//  SetupAssistantController.h
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
//

#import <Cocoa/Cocoa.h>
#import "TEInstallStepView.h"
#import "Common.h"

#define TEAssistantDidFinishNotification			@"TEAssistantDidFinishNotification"
#define TESetupAssistantFinishedNotification		@"TESetupAssistantFinishedNotification"
#define TESetupAssistantWasDismissedNotification	@"TESetupAssistantWasDismissedNotification"

@class TESetupAssistant;

// TEBaseAssistant is configured by default to behave as if it has only one view
// if your assistant has multiple views you probably want to override the
// last three methods: startWithView, nextPressed, and prevPressed
@interface TEBaseAssistant : NSObject {
	IBOutlet NSView *view;			// this is released for you on dealloc
	TESetupAssistant *controller;	// not retained
}

+ (id)assistant; // calls new] autorelease]

// TESetupAssistant <-(gets-from) TEBaseAssistant
- (NSView *)view;
- (NSString *)assistantName;	// used for error info. default returns [self className]
- (NSString *)assistantNib;		// CHECK! (default is [self className])
- (NSArray *)orderedSteps;		// OVERRIDE!
- (NSDictionary *)results;      // this is returned as part of userInfo dict for TEAssistantDidFinishNotification

// TESetupAssistant ->(tells) TEBaseAssistant
- (OSStatus)prepareAssistant;	// default simply loads the nib returned by assistantNib
- (void)start;					// called when it's this assistant's turn to go, default does nothing
- (void)restart;				// called when go-back button is pressed, default calls start
- (void)nextPressed:(id)sender;	// calls runNextAssistant (override if doing multiple steps)
- (void)prevPressed:(id)sender;	// calls runPreviousAssistant (override if doing multiple steps)
@end

#ifndef MAC_OS_X_VERSION_10_6
@protocol NSWindowDelegate <NSObject> @end
#endif

@interface TESetupAssistant : NSObject <NSWindowDelegate> {
	IBOutlet NSWindow *window; // the TESetupAssistant instance is set as the window's delegate
	IBOutlet NSButton *nextButton;
	IBOutlet NSButton *prevButton;
	IBOutlet TEInstallStepView *installStepView;
	IBOutlet NSBox *assistantBox;
	IBOutlet NSTextField *stepTitle;
	IBOutlet NSView *specialView;
	
	NSMutableArray *assistants;
	NSMutableDictionary *sessionDict; // used by assistants to share data
	int currentAssistant;
	BOOL modal;
	id userObject; // retained
	SEL userSelector;
}

+ (TESetupAssistant *)assistant;
- (id)initMini;
- (NSString *)nibName; // for subclasses to overwrite if they want custom window

// actions
- (IBAction)nextPressed:(id)sender;
- (IBAction)prevPressed:(id)sender;
- (IBAction)dismissAssistant:(id)sender; // unhooked by default

// using the setup assistant
- (void)addAssistant:(TEBaseAssistant*)assistant; // the order in which they are added is the order they are run
- (BOOL)containsAssistantOfClass:(Class)aClass;
- (BOOL)run;									// returns YES if any assistants were run
- (void)reset;									// automatically called after last assistant finishes

ACC_COMBO_H(BOOL, modal, Modal)
ACC_COMBO_H(id, userObject, UserObject)
ACC_COMBO_H(SEL, userSelector, UserSelector)

// TEBaseAssistant ->(tells) TESetupAssistant
- (OSStatus)selectStep:(NSString *)stepName;
- (void)runNextAssistant;
- (void)runPreviousAssistant;
- (void)insertNextAssistant:(TEBaseAssistant *)assistant;
- (void)setObject:(id)obj forKey:(id)key; // these manipulate the sessionDict
- (id)objectForKey:(id)key;

// Accessors
- (NSWindow *)window;
- (NSButton *)prevButton;
- (NSButton *)nextButton;
- (NSView *)specialView;
- (NSBox *)assistantBox;
- (NSArray *)assistants;
- (TEBaseAssistant *)prevAssistant;
- (TEBaseAssistant *)nextAssistant;
- (TEBaseAssistant *)currAssistant;
@end
