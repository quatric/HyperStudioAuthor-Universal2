#import "HyperStudioPrefix.h"
#import "HSVectorDrawingTool.h"


@interface HSVectorDrawShapeTool : HSVectorDrawingTool
{
    unsigned int _dynamicStrokeWidthAdjustmentFactor;
    BOOL _drawMultiple;
    BOOL _drawCentered;
}
+ (Class)settingsSerializationClass;
- (void)provideSelectionPath:(struct CGPath *)aPath withOrientedRectTransform:(CGAffineTransform)aTransform;
- (BOOL)canProvideSelectedShape;
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (void)setDrawCentered:(BOOL)aCentered;
- (BOOL)drawCentered;
- (void)setDrawMultiple:(BOOL)aMultiple;
- (BOOL)drawMultiple;
- (id)settingsIdentifiers;
- (id)primarySettingsIdentifier;
- (id)initWithBTTool:(id)aTool;
@end

