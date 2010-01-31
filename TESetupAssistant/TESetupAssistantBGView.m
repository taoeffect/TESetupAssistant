//
//  SetupBGView.m
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

#import "TESetupAssistantBGView.h"
#import "NSImage+Scaling.h"
#import "Common.h"

@implementation TESetupAssistantBGView

- (void)dealloc
{
	[image release];
	[super dealloc];
}

- (void)awakeFromNib
{
	image = [[NSImage imageNamed:@"NSApplicationIcon"] retain];
	opacity = 0.15;
	[self setImageFrame:NSMakeRect(-50, NSHeight([self bounds]) - 412, 512, 512)];
}

- (void)drawRect:(NSRect)rect
{
	NSPoint origin = imageFrame.origin;
	origin.y = NSHeight([self bounds]) - 412;
	[image drawAtPoint:origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:opacity];
}

ACC_RETURN_M(CGFloat, opacity)
ACC_RETURN_M(NSImage *, image)
ACC_RETURN_M(NSRect, imageFrame)

- (void)setOpacity:(CGFloat)val
{
	opacity = val;
}

- (void)setImage:(NSImage*)anImage
{
	if ( anImage == image ) return;
	ASSIGN(image, anImage);
	[image setScalesWhenResized:YES];
	[image setSize:imageFrame.size];
}

- (void)setImageFrame:(NSRect)frame
{
	imageFrame = frame;
	[image setScalesWhenResized:YES];
	[image setSize:imageFrame.size];
}

@end
