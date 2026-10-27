#import "HSTransformationEffectDialogController.h"

@implementation HSTransformationEffectDialogController

- (id)initWithOriginalObject:(id)aObject
{
    self = [super init];
    if (self != nil) {
        _originalObject = [aObject retain];
        if (_originalObject != nil)
            return self;
    }
    [self release];
    return nil;
}

- (void)applyChanges
{
    float scale = [_scaleFactorTextField floatValue];
    float rotation = [_rotationTextField floatValue];

    if ([_rotationMatrix selectedTag] == 0)
        rotation = -rotation;
    [HSEditorWindowController scaleObject:_originalObject aboutCenterBy:scale / 100.0f rotateAboutCenterBy:rotation * 3.1415927f / 180.0f];
}

- (void)didLoadNib
{
    BOOL canRotate = [HSEditorWindowController canRotateObject:_originalObject];

    [_rotationTextField setEnabled:canRotate];
    [_rotationMatrix setEnabled:canRotate];
    [_scaleFactorTextField setEnabled:[HSEditorWindowController canResizeObject:_originalObject]];
}

- (id)nibName
{
    return @"Transformation";
}

@end

@implementation HSTransformationEffectDialogController (TextFieldDelegate)

- (void)controlTextDidChange:(id)aChange
{
    id field = [aChange object];
    NSString *value;

    if (field == nil)
        return;
    value = [field stringValue];
    if (value == nil || [value length] == 0) {
        [_applyButton setEnabled:NO];
        return;
    }
    if (_scaleFactorTextField == field && [field floatValue] < 1.0f) {
        [field setFloatValue:1.0f];
        NSBeep();
    }
    [_applyButton setEnabled:YES];
}

@end
