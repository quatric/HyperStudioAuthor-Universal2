#import "HyperStudioPrefix.h"
#import "HSVectorDrawingTool.h"


@interface HSVectorPencilTool : HSVectorDrawingTool <BTPencilStrokeConsumer, NSObject>
{
}
- (void)addPencilStrokeFromPoint:(CGPoint)aPoint toPoint:(CGPoint)aPoint2;
- (id)settingsIdentifiers;
- (id)primarySettingsIdentifier;
- (BOOL)activateBitmapTool;
- (void)deactivateBitmapTool;
- (id)initWithBTTool:(id)aTool;
@end

