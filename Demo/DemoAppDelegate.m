//
//  DemoAppDelegate.m
//  Demo
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

#import "DemoAppDelegate.h"
#import "TESetupAssistant.h"
#import "ReadmeAssistant.h"
#import "LicenseAssistant.h"
#import "InstallAssistant.h"
#import "MiniAssistant.h"
#import "Common.h"

@implementation DemoAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	OBSERVE_NOTIF(self, TESetupAssistantFinishedNotification, @selector(finished:));
	[self setValue:NSYES forKey:@"enabled"];
}

- (IBAction)showFullAssistant:sender
{
	TESetupAssistant *sa = [TESetupAssistant assistant];
	ReadmeAssistant *readme = [ReadmeAssistant assistant];
	LicenseAssistant *license = [LicenseAssistant assistant];
	[readme setReadmePath:[[NSBundle mainBundle] pathForResource:@"Readme" ofType:@"rtf"]];
	[license setLicensePath:[[NSBundle mainBundle] pathForResource:@"License" ofType:@"rtf"]];
	[sa addAssistant:readme];
	[sa addAssistant:license];
	[sa addAssistant:[InstallAssistant assistant]];
	// we can't run this assistant modally because it uses
	// performSelector:withDelay: and that timer isn't placed on the right NSRunLoop
	// if it's run modally. Instead we use KVO on 'enabled' to disable the buttons
	[sa run];
	[self setValue:NSNO forKey:@"enabled"];
}

- (IBAction)showMiniAssistant:sender
{
	TESetupAssistant *sa = [[TESetupAssistant alloc] initMini];
	[sa setModal:YES];
	[sa addAssistant:[MiniAssistant assistant]];
	[sa run];
}

- (void)finished:(NSNotification *)note
{
	[self setValue:NSYES forKey:@"enabled"];
}

ACC_COMBOP_M(BOOL, enabled, Enabled)

@end
