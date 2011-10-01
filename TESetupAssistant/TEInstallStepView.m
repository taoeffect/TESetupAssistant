//
//  TEInstallStepView.m
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

#import "TEInstallStepView.h"
#import "Common.h"

#define VERTICAL_OFFSET 25.0 // 25 appears to be what installer uses

@interface TEInstallStepView (Private)
- (void)calculateSizes;
@end

@implementation TEInstallStepView

@synthesize desiredSpacing, verticalTextOffset;
@synthesize prevStepImg, currStepImg, nextStepImg;
@synthesize prevStepTextAttrs, currStepTextAttrs, nextStepTextAttrs;

- (id)initWithFrame:(NSRect)frame
{
	if ( (self = [super initWithFrame:frame]) ) {
		cell = [TEInstallStepCell new];
		prevStepImg = [NSImage imageNamed:@"GrayDot"];
		currStepImg = [NSImage imageNamed:@"BlueDot"];
		nextStepImg = [NSImage imageNamed:@"DisabledGrayDot"];
		desiredSpacing = 25;
		[self setFocusRingType:NSFocusRingTypeNone];
		
		// customize the cell with default values
		[cell setVerticalTextOffset:2.0];
		
		NSShadow *shadow = [NSShadow new];
		[shadow setShadowColor:[NSColor whiteColor]];
		[shadow setShadowOffset:NSMakeSize(0, -1.0)];
		
		prevStepTextAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSFont boldSystemFontOfSize:13.0], NSFontAttributeName,
							  shadow, NSShadowAttributeName, nil];
		currStepTextAttrs = prevStepTextAttrs;
		nextStepTextAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSFont systemFontOfSize:13.0], NSFontAttributeName,
							  [NSColor darkGrayColor], NSForegroundColorAttributeName,
							  shadow, NSShadowAttributeName,nil];
	}
	return self;
}


#pragma mark Interface implementation
- (void)clearSteps
{
	steps = nil;
	currentStep = nil;
}

- (void)setSteps:(NSArray *)theSteps
{
	steps = theSteps;
    currentStep = [steps objectAtIndex:0];
	if ( [steps count] > 0 ) [self calculateSizes]; // careful, don't want to divide by 0!
	[self setNeedsDisplay:YES];
}

- (void)setVerticalTextOffset:(CGFloat)offset
{
	[cell setVerticalTextOffset:offset];
}

- (CGFloat)verticalTextOffset
{
	return [cell verticalTextOffset];
}

- (OSStatus)selectStep:(NSString *)stepName
{
	if ( [steps containsObject:stepName] == NO ) {
		log_err("bad step: %@", stepName);
		return resNotFound;
	}
	currentStep = stepName;
	return noErr;
}

- (NSString*)currentStep;
{
	return currentStep;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	if ( [steps count] == 0 ) return;
	
	int stepType = -1; // -1, 0, 1
	NSRect bounds = [self bounds];
	NSRect drawRect;
	drawRect.size = bounds.size;
	drawRect.origin = NSMakePoint(0, NSHeight(bounds) - cellHeight - VERTICAL_OFFSET);
	
	for (NSString *step in steps)
	{
		// prepare the cell to draw the correct image and string
		if ( [step isEqualToString:currentStep] ) {
			if ( stepType == -1 )
				++stepType;
		}
		else if ( stepType == 0 )
			++stepType;
		
		if ( stepType == -1 ) {
			[cell setImage:prevStepImg];
			[cell setStringAttributes:prevStepTextAttrs];
		} else if ( stepType == 0 ) {
			[cell setImage:currStepImg];
			[cell setStringAttributes:currStepTextAttrs];
		} else {
			[cell setImage:nextStepImg];
			[cell setStringAttributes:nextStepTextAttrs];
		}
		
		[cell setStringValue:step];
		[cell drawWithFrame:drawRect inView:self];
		drawRect.origin.y -= calculatedSpacing;
	}
}

@end

@implementation TEInstallStepView (Private)
- (void)calculateSizes
{
	// ensure a valid cell before calling cellSize
	[cell setImage:prevStepImg];
	[cell setStringValue:@"FOO"];
	cellHeight = [cell cellSize].height;
	
	NSUInteger stepCount = [steps count];
	CGFloat availableHeight = NSHeight([self bounds]) - (cellHeight * stepCount) - VERTICAL_OFFSET;
	CGFloat maxHeight = availableHeight / stepCount;
	calculatedSpacing = MAX(MIN(desiredSpacing, maxHeight), cellHeight);
	
	log_debug("calculated: cellHeight: %f, spacing: %f", cellHeight, calculatedSpacing);
}
@end

