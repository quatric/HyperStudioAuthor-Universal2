#import "HSStackPrintingView.h"
// Prints cards one per page, scaled down to fit (and centered).
@implementation HSStackPrintingView
- (void)drawContent:(NSRect)aContent
{
    if ([self currentPage] == 0 || [NSGraphicsContext currentContextDrawingToScreen])
        return;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [NSGraphicsContext saveGraphicsState];
    id card = [_cards extraObjectAtIndex:[self currentPage] - 1];
    NSSize cardSize = [(id<HSSizeAttributes>)[card queryHyperInterface:@protocol(HSSizeAttributes)] size];
    NSImage *image = [[card queryHyperInterface:@protocol(HSUserObjectImageProvider)] imageOfSize:cardSize];
    if (image != nil) {
        NSPoint origin = NSZeroPoint;
        NSSize size = [image size];
        float scale = aContent.size.width < size.width ? aContent.size.width / size.width : 1.0f;
        if (aContent.size.height < size.height * scale)
            scale = aContent.size.height / size.height;
        float width = size.width * scale, height = size.height * scale;
        if (!_dontCenterPrintout) {
            origin.x += (aContent.size.width - width) * 0.5f;
            origin.y += (aContent.size.height - height) * 0.5f;
        }
        NSRect rect = NSMakeRect(origin.x, origin.y, width, height);
        if ([image isFlipped])
            [[NSAffineTransform hyperYFlipInRect:rect] concat];
        [image drawInRect:rect fromRect:NSMakeRect(0, 0, size.width, size.height) operation:NSCompositingOperationSourceOver fraction:1.0];
    }
    [NSGraphicsContext restoreGraphicsState];
    [pool release];
}
- (NSUInteger)countOfPages
{
    return [_cards count];
}
- (void)preparePrinting
{
    [super preparePrinting];
}
- (void)setInPlayerMode:(BOOL)aMode
{
    _inPlayerMode = aMode;
}
- (void)setDontCenterPrintout:(BOOL)aPrintout
{
    _dontCenterPrintout = aPrintout;
}
- (void)dealloc
{
    [_cards release];
    [super dealloc];
}
- (id)initWithCards:(id)aCards
{
    self = [super initWithFrame:NSZeroRect];
    if (self != nil)
        _cards = [aCards retain];
    return self;
}
- (id)initWithStack:(id)aStack
{
    self = [super initWithFrame:NSZeroRect];
    if (self != nil)
        _cards = [[aStack hyperChildren] retain];
    return self;
}
@end
