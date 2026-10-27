#import "HSButtonShapeCreationTool.h"

@implementation HSButtonShapeCreationTool

+ (Class)toolCanvasLayerClass
{
    return [HSButtonShapeCreationToolCanvasLayer class];
}

+ (Class)settingsSerializationClass
{
    return [BTButtonShapeCreationToolSettingsSerialization class];
}

- (id)primarySettingsIdentifier
{
    if ([[self toolIdentifier] isEqualToString:@"HSButtonLassoShapeCreationTool"] || [[self toolIdentifier] isEqualToString:@"HSButtonMagicWandShapeCreationTool"])
        return @"HSLassoSelectionTool";
    return [super primarySettingsIdentifier];
}

- (void)handleCancelOpertaion
{
    [[self delegate] toolDidCancelOperation:self];
}

- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aStage2
{
    if ([self bitmapTool] == aTool && aStage2 == nil)
        [_delegate buttonShapeCreationTool:self didFinalizeWithEvent:aEvent];
    return [super tool:aTool didFinalizeStage:aStage withEvent:aEvent nextStage:aStage2];
}

- (BOOL)allowsSelection
{
    return YES;
}

- (id)borderPath
{
    id selectionPath = [[self bitmapTool] valueForKey:@"selectionPath"];
    if (selectionPath == nil)
        return nil;
    return [NSBezierPath hyperBezierPathWithCGPath:(struct CGPath *)selectionPath];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

@end
