#import "HyperStudioPrefix.h"
#import "HSLegacyCreationTool.h"


@interface HSTextTool : HSLegacyCreationTool <HSToolTextColorAttribute, HSTextToolObjectEditingCanvasLayerClient>
{
    id _createdObject;
    id _additionalToolPrototype;
    HSTextToolObjectEditingCanvasLayer *_objectEditingLayer;
    BOOL _isActive;
    int _initialRectSide;
}
+ (id)allowedEditorInterfaces;
+ (id)allowedPrototypeInterfaces;
+ (Class)userObjectClass;
- (BOOL)preservesActiveInPlaceEditors;
- (BOOL)allowsActiveInPlaceEditors;
- (BOOL)acceptsFirstMouse;
- (void)noteCurrentToolSetDidChange;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)setupObjectEditingCanvasLayerIfNeeded;
- (void)setObjectEditingLayer:(id)aLayer;
- (void)setTextColor:(id)aColor;
- (id)textColor;
- (id)defaultToolCursorName;
- (BOOL)allowsToEditPrototypeObjectInterface:(id)aInterface;
- (void)prototypeObjectDidChange;
- (void)saveChangesAndNotify:(BOOL)aNotify;
- (void)setAdditionalToolPrototype:(id)aPrototype;
- (void)setCreatedObject:(id)aObject;
- (void)addCreatedObjectToCard;
- (void)handleMouseDownInNode:(id)aNode atPoint:(NSPoint)aPoint event:(id)aEvent inTextToolObjectEditingCanvasLayer:(id)aLayer;
- (void)handleMouseDown:(id)aDown;
- (void)willHandleMouseDown;
- (void)dealloc;
@end

