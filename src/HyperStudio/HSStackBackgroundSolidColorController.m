#import "HSStackBackgroundSolidColorController.h"

@implementation HSStackBackgroundSolidColorController

- (NSSize)solidColorMatrixCellSize
{
    return NSMakeSize(31, 31);
}

- (id)solidColorPreset
{
    if (!_solidColorPreset) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"SolidColorMatrixPreset" ofType:@"plist"];
        _solidColorPreset = [[NSArray arrayWithContentsOfFile:path] retain];
    }
    return _solidColorPreset;
}

- (id)presetSolidColorAtIndex:(NSInteger)aIndex
{
    return [[[NSColor alloc] initWithExtraDictionary:[[self solidColorPreset] extraObjectAtIndex:aIndex]] autorelease];
}

// Renders the preset colour as a solid gradient swatch.
- (id)solidColorImageAtIndex:(NSInteger)aIndex
{
    id color = [self presetSolidColorAtIndex:aIndex];
    HSColor *gradient = [[HSColor alloc] init];
    [gradient setSolid:YES];
    [gradient setStartColor:color];
    [gradient setEndColor:color];
    NSImage *image = [[[NSImage alloc] initWithSize:[self solidColorMatrixCellSize]] autorelease];
    [image lockFocus];
    NSSize size = [image size];
    [gradient drawGradientInCocoaContext:[NSGraphicsContext currentContext] rect:NSMakeRect(0, 0, size.width, size.height) ofBounds:NSMakeRect(0, 0, size.width, size.height)];
    [image unlockFocus];
    NSImage *result = [[[NSImage alloc] initWithData:[image TIFFRepresentation]] autorelease];
    [gradient release];
    return result;
}

- (void)setupSolidColortMatrix
{
    NSInteger rows = [_solidColorMatrix numberOfRows];
    NSInteger columns = [_solidColorMatrix numberOfColumns];
    for (NSInteger column = 0; column < columns; column++) {
        for (NSInteger row = 0; row < rows; row++)
            [[_solidColorMatrix cellAtRow:row column:column] setImage:[self solidColorImageAtIndex:column * rows + row]];
    }
}

- (void)chooseSolidColorPreset:(id)aPreset
{
    NSInteger row = [aPreset selectedRow];
    NSInteger column = [aPreset selectedColumn];
    [_solidColor setColor:[self presetSolidColorAtIndex:[aPreset numberOfRows] * column + row]];
    [self apply];
}

// A plain colour sets a solid fill; a gradient colour copies all of its
// settings into the applier. (The original passes the centre X for both
// centre coordinates.)
- (void)solidColorChanged:(id)aChanged
{
    id color = [aChanged color];
    id gradient = [[[aChanged color] hyperGradientColor] hyperHSColor];
    if (!gradient) {
        [_applier setFillType:1];
        [_applier setHyperSolidColor:color];
    } else {
        [_applier setFillType:2];
        [_applier setHyperClear:[gradient isHyperClear]];
        [_applier setHyperKind:[gradient hyperKind]];
        [_applier setHyperCacheEnabled:[gradient isHyperCacheEnabled]];
        [_applier setHyperAngle:[gradient hyperAngle]];
        [_applier setHyperCenterX:[gradient hyperCenterX] andY:[gradient hyperCenterX]];
        [_applier setHyperStartColor:[gradient hyperStartColor]];
        [_applier setHyperEndColor:[gradient hyperEndColor]];
        [[self delegate] validateFillTypeController];
    }
}

- (void)setShouldActivateColorWellOnMount:(BOOL)aMount
{
    _shouldActivateColorWell = aMount;
}

- (BOOL)deactivatedColorWellOnUnmount
{
    BOOL active = [_solidColor isActive];
    if (active)
        [_solidColor deactivate];
    return active;
}

- (void)setDelegate:(id)aDelegate
{
    if (_delegate != aDelegate)
        _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)validateUIElements
{
    id color = [_applier hyperSolidColor];
    if (_shouldActivateColorWell)
        [_solidColor activate:NO];
    [_solidColor setColor:color ? color : [NSColor blackColor]];
}

- (void)apply
{
    if (!_didInitOnce) {
        [self validateUIElements];
        _didInitOnce = YES;
    }
}

- (void)setApplier:(id)aApplier
{
    if (_applier != aApplier)
        _applier = aApplier;
}

- (id)contentView
{
    return _controlledView;
}

- (void)dealloc
{
    [_solidColor deactivate];
    [_controlledView release];
    [_solidColorPreset release];
    [super dealloc];
}

@end
