#import "HSSystemPushButton.h"
// A system push button object: only its width can change; its height is
// the cell's, and a control size change keeps the title area's width.
@implementation HSSystemPushButton
+ (Class)nodeDataClass
{
    return [HSSystemPushButtonData class];
}
- (id)hyperSizeMaxValue
{
    float maxWidth = [[[HSValueConstraints sharedConstraints] constraintForKey:@"HSSystemObjectWidthMaxValue"] floatValue];
    NSSize cellSize = [[[[self nodeData] systemButtonForGetAccessor] cell] cellSize];
    return NSStringFromSize(NSMakeSize(maxWidth, cellSize.height));
}
// (Both dimensions are the cell's height, as in the original.)
- (id)hyperSizeMinValue
{
    NSSize cellSize = [[[[self nodeData] systemButtonForGetAccessor] cell] cellSize];
    return NSStringFromSize(NSMakeSize(cellSize.height, cellSize.height));
}
- (NSSize)defaultSize
{
    return NSMakeSize(89, 32);
}
- (BOOL)canResizeVertically
{
    return NO;
}
- (BOOL)canResizeHorizontally
{
    return YES;
}
- (BOOL)canBreakSizeAspectRatio
{
    return YES;
}
- (void)hyperSizeToFitContentHorizontally:(BOOL)aHorizontally vertically:(BOOL)aVertically
{
    id geometry = [self queryHyperInterface:@protocol(HSMutableGeometryAttributes)];
    if (geometry == nil)
        return;
    NSSize size = [(id<HSMutableGeometryAttributes>)geometry size];
    NSSize cellSize = [[[[self nodeData] systemButtonForGetAccessor] cell] cellSize];
    if (aHorizontally)
        size.width = (float)((12.0 - [self adjustingWidthForControlSize:[self controlSize]]) + (float)cellSize.width);
    if (aVertically)
        size.height = cellSize.height;
    [geometry setSize:size aboutRelativePoint:NSMakePoint(0.5, 0.5)];
}
- (void)controlSizeDidChange
{
    id geometry = [self queryHyperInterface:@protocol(HSMutableGeometryAttributes)];
    if (geometry == nil)
        return;
    NSSize size = [(id<HSMutableGeometryAttributes>)geometry size];
    NSUInteger controlSize = [self controlSize];
    CGFloat fontSize = [NSFont systemHyperFontSizeForControlSize:controlSize];
    [self setTitleFont:[NSFont fontWithName:[[[[self nodeData] systemButtonForGetAccessor] font] fontName] size:fontSize]];
    NSSize cellSize = [[[[self nodeData] systemButtonForGetAccessor] cell] cellSize];
    float width = (float)size.width + (float)[self adjustingWidthForControlSize:_previousControlSize] - (float)[self adjustingWidthForControlSize:controlSize];
    [geometry setSize:NSMakeSize(width, cellSize.height) aboutRelativePoint:NSMakePoint(0.5, 0.5)];
}
- (void)controlSizeWillChange
{
    _previousControlSize = (unsigned int)[self controlSize];
}
- (void)HSSystemPushButton_controlSizeDidChange:(id)aChange
{
    [self controlSizeDidChange];
}
- (void)HSSystemPushButton_controlSizeWillChange:(id)aChange
{
    [self controlSizeWillChange];
}
// Small buttons are 2 points narrower inside, mini ones 10 (12 before
// Tiger).
- (CGFloat)adjustingWidthForControlSize:(NSUInteger)aSize
{
    if (aSize == NSControlSizeSmall)
        return 2;
    if (aSize == NSControlSizeMini)
        return 10;
    return 0;
}
- (void)didCreateSystemView
{
    [super didCreateSystemView];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSTitleStringAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemButtonBorderAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTransparencyAttribute)];
    [self linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemButtonContinuousAttribute)];
}
- (void)dealloc
{
    [super removeObserver:self selector:@selector(HSSystemPushButton_controlSizeWillChange:) ofChanges:1 ofAttribute:@protocol(HSSystemControlSizeAttribute)];
    [super removeObserver:self selector:@selector(HSSystemPushButton_controlSizeDidChange:) ofChanges:2 ofAttribute:@protocol(HSSystemControlSizeAttribute)];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    [super addObserver:self selector:@selector(HSSystemPushButton_controlSizeWillChange:) ofChanges:1 ofAttribute:@protocol(HSSystemControlSizeAttribute) withPriority:0.75];
    [super addObserver:self selector:@selector(HSSystemPushButton_controlSizeDidChange:) ofChanges:2 ofAttribute:@protocol(HSSystemControlSizeAttribute) withPriority:0.75];
    return self;
}
@end
