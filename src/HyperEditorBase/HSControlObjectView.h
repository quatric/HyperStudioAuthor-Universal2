#import "HyperEditorBasePrefix.h"


@interface HSControlObjectView : HSQuartzOpenGLView <HSNodeSupport, NSObject>
{
    HSNode *_renderNode;
    HSNode *_nodeForPasteboard;
    NSMutableDictionary *_objectDescription;
    NSImage *_objectImage;
    NSPoint _renderOffset;
    id _delegate;
}
+ (id)controlsDescription;
- (id)accessibilityAttributeValue:(id)aValue;
- (id)accessibilityFocusedUIElement;
- (id)accessibilityHitTest:(NSPoint)aTest;
- (BOOL)accessibilityIsIgnored;
- (id)accessibilityDescriptionValue;
- (void)windowDidResignKey:(id)aKey;
- (void)windowDidBecomeKey:(id)aKey;
- (id)objectDescription;
- (id)nodeForRender;
- (id)nodeForPasteboard;
- (void)unsubscribeFromNotifications;
- (void)subscribeToNotifications;
- (void)viewFrameChanged:(id)aChanged;
- (BOOL)isAttributesNotificationPostingDisabled;
- (id)cardGroupController;
- (id)delegate;
- (id)scriptController;
- (id)undoManager;
- (void)initializeRenderNode:(id)aNode;
- (id)toolTipString;
- (id)objectImage;
- (id)objectClassName;
- (void)frameChanged:(NSRect)aChanged;
- (id)visualizationProtocol;
- (void)drawQuartzRect:(NSRect)aRect;
- (BOOL)needsPanelToBecomeKey;
- (BOOL)resignFirstResponder;
- (BOOL)becomeFirstResponder;
- (BOOL)acceptsFirstResponder;
- (BOOL)acceptsFirstMouse:(id)aMouse;
- (id)view:(id)aView stringForToolTip:(NSInteger)aTip point:(NSPoint)aPoint userData:(void *)aData;
- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType;
- (void)keyDown:(id)aDown;
- (void)mouseDown:(id)aDown;
- (void)mouseDragged:(id)aDragged;
- (void)setDelegate:(id)aDelegate;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
@end

