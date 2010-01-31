//
//  TEInstallStepCell.m
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

#import "TEInstallStepCell.h"

#define SPACING_BW_IMG_TXT 5.0
//#define IMG_SIZE 20.0

@interface TEInstallStepCell (Private)
- (void)calculateCellSize;
@end


@implementation TEInstallStepCell

- (void)dealloc
{
	[stringAttributes release];
	[attrString release];
	[image release];
	[super dealloc];
}

- (id)init
{
	if ( (self = [super init]) ) {
		imageSize = textSize = cellSize = NSZeroSize;
	}
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// this is so that both text and image are vertically centered
	NSPoint imagePoint = NSMakePoint(cellFrame.origin.x,
									 cellFrame.origin.y + (cellSize.height - imageSize.height) / 2);
	NSPoint textPoint = NSMakePoint(cellFrame.origin.x + SPACING_BW_IMG_TXT + imageSize.width,
									cellFrame.origin.y + (cellSize.height - textSize.height) / 2 + verticalTextOffset);
	
	[controlView lockFocus];
	[image drawAtPoint:imagePoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[attrString drawAtPoint:textPoint];
	[controlView unlockFocus];
}

- (void)setImage:(NSImage*)img
{
	if ( img == image ) return;
	ASSIGN(image, img);
#ifdef IMG_SIZE
	[image setSize:NSMakeSize(IMG_SIZE, IMG_SIZE)];
#endif
	[self calculateCellSize];
}

- (void)setStringValue:(NSString*)str
{
	ASSIGN(attrString, [[[NSAttributedString alloc] initWithString:str attributes:[self stringAttributes]] autorelease]);
	[self calculateCellSize];
}

- (void)setStringAttributes:(NSDictionary *)attrs
{
	if ( attrs == stringAttributes ) return;
	ASSIGN(stringAttributes, attrs);
	[self calculateCellSize];
}

- (void)setVerticalTextOffset:(CGFloat)offset
{
	verticalTextOffset = offset;
	// no need to calculate the size, the offset doesn't affect it...
}

ACC_RETURN_M(NSDictionary *, stringAttributes)
ACC_RETURN_M(CGFloat, verticalTextOffset)
ACC_RETURN_M(NSSize, cellSize)
ACC_RETURN_M(NSImage *, image)
@end

@implementation TEInstallStepCell (Private)
- (void)calculateCellSize
{
	if ( attrString ) textSize = [attrString size];
	if ( image ) imageSize = [image size];
	cellSize.width = imageSize.width + SPACING_BW_IMG_TXT + textSize.width;
	cellSize.height = MAX(imageSize.height, textSize.height);
}
@end

