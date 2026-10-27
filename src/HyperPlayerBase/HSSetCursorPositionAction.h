#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSSetCursorPositionAction : HSNBAAction <HSSetCursorPositionActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSCursorPositionAttribute, HSPositionAttributes, HSPositionAttribute>
{
    NSPoint _cursorPosition;
}
- (void)setPosition:(NSPoint)aPosition;
- (NSPoint)position;
- (void)setCursorPosition:(NSPoint)aPosition;
- (NSPoint)cursorPosition;
- (void)startInContext:(id)aContext;
- (void)setCursorPositionRepresentation:(id)aRepresentation;
- (id)cursorPositionRepresentation;
- (BOOL)canChangeSynchronousFlag;
- (BOOL)isSynchronous;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

