#import "HyperStudioPrefix.h"
#import <Quartz/Quartz.h>


@interface HSATemplateImageBrowserCell : IKImageBrowserCell
- (CGRect)CGRectFromRect:(NSRect)aRect;
- (NSRect)frame;
- (NSRect)imageFrame;
- (NSRect)titleFrame;
- (NSUInteger)imageAlignment;
- (CGPathRef)selectionPathForRect:(NSRect)aRect;
- (id)layerForType:(id)aType;
- (void)drawLayer:(id)aLayer inContext:(CGContextRef)aContext;
@end
