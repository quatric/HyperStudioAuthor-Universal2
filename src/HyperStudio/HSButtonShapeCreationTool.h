#import "HyperStudioPrefix.h"
#import "HSBitmapTool.h"


@interface HSButtonShapeCreationTool : HSBitmapTool
{
    id _delegate;
}
+ (Class)toolCanvasLayerClass;
+ (Class)settingsSerializationClass;
- (id)primarySettingsIdentifier;
- (void)handleCancelOpertaion;
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aStage2;
- (BOOL)allowsSelection;
- (id)borderPath;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
@end

