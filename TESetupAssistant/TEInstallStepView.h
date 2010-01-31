//
//  TEInstallStepView.h
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
#import "TEInstallStepCell.h"
#import "Common.h"

@interface TEInstallStepView : NSView {
	NSArray *steps;
	NSString *currentStep;
	
	TEInstallStepCell *cell;
	
	NSImage *prevStepImg;
	NSImage *currStepImg;
	NSImage *nextStepImg;
	NSDictionary *prevStepTextAttrs;
	NSDictionary *currStepTextAttrs;
	NSDictionary *nextStepTextAttrs;
	
	CGFloat desiredSpacing;
	CGFloat calculatedSpacing;
	CGFloat cellHeight;
}

- (void)clearSteps;
- (void)setSteps:(NSArray *)theSteps;
- (OSStatus)selectStep:(NSString *)stepName;
- (NSString*)currentStep;

ACC_COMBO_H(CGFloat, desiredSpacing, DesiredSpacing)
ACC_COMBO_H(CGFloat, verticalTextOffset, VerticalTextOffset)
ACC_COMBO_H(NSImage *, prevStepImg, PrevStepImg)
ACC_COMBO_H(NSImage *, currStepImg, CurrStepImg)
ACC_COMBO_H(NSImage *, nextStepImg, NextStepImg)
ACC_COMBO_H(NSDictionary *, prevStepTextAttrs, PrevStepTextAttrs)
ACC_COMBO_H(NSDictionary *, currStepTextAttrs, CurrStepTextAttrs)
ACC_COMBO_H(NSDictionary *, nextStepTextAttrs, NextStepTextAttrs)
@end
