#import "HSButtonObjectSystemBackground.h"

// Button background drawn from the system button artwork (by button type),
// optionally tinted.
@implementation HSButtonObjectSystemBackground
// Maps the old-style button types to their system equivalents.
- (void)updateButtonObjectStyle
{
    id type = [self systemButtonType];
    NSArray *oldstyleTypes = [NSArray arrayWithObjects:@"HSRoundedOldstyleButtonType", @"HSRoundedDefaultOldstyleButtonType",
                              @"HSRectangleOldstyleButtonType", @"HSDropShadowRectangleOldstyleButtonType", nil];
    NSString *systemTypes[4] = { @"HSRegularSystemButtonType", @"HSDefaultSystemButtonType",
                                 @"HSRectangleSystemButtonType", @"HSDropShadowRectangleSystemButtonType" };
    // Original indexes without checking for NSNotFound (callers check canButtonStyleBeUpdated first).
    [self setSystemButtonType:systemTypes[[oldstyleTypes indexOfObject:type]]];
}
- (BOOL)canButtonStyleBeUpdated
{
    if (![self hasOldstyleButtonType])
        return NO;
    id attributes = [[self buttonObject] queryHyperInterface:@protocol(HSButtonObjectAttributes)];
    return ![(NSString *)[(HSButtonObject *)attributes backgroundStyle] isEqualToString:@"HSButtonObjectShapeBackgroundStyle"];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects:@"ignoreTintColor", [@"tintColor" extraKeyForMultiRepresentations], @"systemButtonType", @"sizeAsString", nil]];
}
- (CGFloat)additionalHorizontalTitleSpace
{
    id attributes = [[self buttonObject] queryHyperInterface:@protocol(HSButtonObjectAttributes)];
    return (float)[[HSCustomButtonsSharedProvider sharedCustomButtonsProvider] additionalHorizontalTitleSpaceForButtonWithMediaUID:[attributes mediaUID]];
}
- (BOOL)shouldTileMiddleBackgroundParts
{
    id attributes = [[self buttonObject] queryHyperInterface:@protocol(HSButtonObjectAttributes)];
    return [[HSCustomButtonsSharedProvider sharedCustomButtonsProvider] shouldTileMiddleBackgroundPartsForButtonWithMediaUID:[attributes mediaUID]];
}
- (id)backgroundImagePartForType:(NSInteger)aType
{
    id attributes = [[self buttonObject] queryHyperInterface:@protocol(HSButtonObjectAttributes)];
    return [[HSCustomButtonsSharedProvider sharedCustomButtonsProvider] backgroundImagePartForButtonWithMediaUID:[attributes mediaUID] partType:aType];
}
- (BOOL)canResizeVertically
{
    if (![[self buttonType] isEqualToString:@"HSTexturedBackgroundSystemButtonType"])
        return YES;
    id attributes = [[self buttonObject] queryHyperInterface:@protocol(HSButtonObjectAttributes)];
    return [[HSCustomButtonsSharedProvider sharedCustomButtonsProvider] canResizeVerticallyBackgroundForButtonWithMediaUID:[attributes mediaUID]];
}
- (BOOL)isVisible
{
    return YES;
}
- (void)setSizeAsString:(id)aString
{
    [self setSize:NSSizeFromString(aString)];
}
- (id)sizeAsString
{
    return NSStringFromSize([self size]);
}
- (void)setSize:(NSSize)aSize
{
    if (NSEqualSizes(_size, aSize))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Button Background size" value:@"" table:@"UndoManager"]];
    [(HSButtonObjectSystemBackground *)[[self undoManager] prepareWithInvocationTarget:self] setSize:_size];
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSButtonObjectSystemBackgroundAttribute),
                     @protocol(HSWidthAttribute), @protocol(HSHeightAttribute), nil];
    [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    _size = aSize;
    [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}
- (NSSize)size
{
    return _size;
}
- (void)setUsesTintColor:(BOOL)aColor
{
    [self setIgnoreTintColor:!aColor];
}
- (BOOL)usesTintColor
{
    return ![self ignoreTintColor];
}
- (void)setIgnoreTintColor:(BOOL)aColor
{
    if (_ignoreTintColor == aColor)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change use of tint color" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setIgnoreTintColor:_ignoreTintColor];
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectSystemBackgroundIgnoreTintColorAttribute) withUserInfo:nil];
    _ignoreTintColor = aColor;
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectSystemBackgroundIgnoreTintColorAttribute) withUserInfo:nil];
}
- (BOOL)ignoreTintColor
{
    return _ignoreTintColor;
}
- (id)buttonType
{
    return [self systemButtonType];
}
- (void)setSystemButtonType:(id)aType
{
    if ([_systemButtonType isEqualToString:aType])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Button background" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSystemButtonType:_systemButtonType];
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectSystemButtonTypeAttribute) withUserInfo:nil];
    [_systemButtonType release];
    _systemButtonType = [aType retain];
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectSystemButtonTypeAttribute) withUserInfo:nil];
}
- (id)systemButtonType
{
    if (_systemButtonType == nil)
        _systemButtonType = [@"HSRegularSystemButtonType" retain];
    return _systemButtonType;
}
- (BOOL)hasOldstyleButtonType
{
    static NSSet *sOldstyleTypes;
    if (sOldstyleTypes == nil)
        sOldstyleTypes = [[NSSet alloc] initWithObjects:@"HSRoundedOldstyleButtonType", @"HSRoundedDefaultOldstyleButtonType",
                          @"HSRectangleOldstyleButtonType", @"HSDropShadowRectangleOldstyleButtonType", nil];
    return [sOldstyleTypes containsObject:[self systemButtonType]];
}
- (id)backgroundStyle
{
    return @"HSButtonObjectSystemBackgroundStyle";
}
- (void)setTintColor:(id)aColor
{
    if ([_tintColor isEqual:aColor])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change background tint color" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTintColor:_tintColor];
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectSystemBackgroundColorAttribute) withUserInfo:nil];
    [_tintColor release];
    _tintColor = [aColor retain];
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectSystemBackgroundColorAttribute) withUserInfo:nil];
}
- (id)tintColor
{
    return _tintColor;
}
- (void)dealloc
{
    [_tintColor release];
    [_systemButtonType release];
    [super dealloc];
}
@end
