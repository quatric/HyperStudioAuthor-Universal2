#import "HyperPlayerBasePrefix.h"
#import "HSCompositeCanvasLayer.h"


@interface HSNamedSublayersCanvasLayer : HSCompositeCanvasLayer
{
    NSArray *_supportedIdentifiers;
    NSMutableDictionary *_enabledSublayers;
    NSMutableDictionary *_disabledSublayers;
    NSMutableSet *_defaultSublayerIdentifiers;
    NSDictionary *_sublayerFactory;
    BOOL _isUsingDefaultIdentifierSet;
}
- (void)updateSublayersOrder;
- (void)enableSublayerForIdentifier:(id)aIdentifier withOrderCheck:(BOOL)aCheck;
- (id)sublayerForIdentifier:(id)aIdentifier;
- (void)enableSublayerForIdentifierIfNeeded:(id)aNeeded;
- (NSUInteger)indexToInsertSublayerForIdentifier:(id)aIdentifier;
- (id)disabledSublayers;
- (id)enabledSublayers;
- (void)setSublayerIdentifier:(id)aIdentifier isEnabledByDefault:(BOOL)aDefault;
- (BOOL)isSublayerIdentifierEnabledByDefault:(id)aDefault;
- (void)setDefaultSublayerIdentifiers:(id)aIdentifiers;
- (id)defaultSublayerIdentifiers;
- (id)mutableDefaultSublayerIdentifiers;
- (id)enabledSublayerIdentifiers;
- (void)setEnabledSublayerIdentifiers:(id)aIdentifiers;
- (id)enabledSublayerForIdentifier:(id)aIdentifier;
- (BOOL)isEnabledSublayerForIdentifier:(id)aIdentifier;
- (void)disableSublayerForIdentifier:(id)aIdentifier;
- (void)enableSublayerForIdentifier:(id)aIdentifier;
- (id)supportedIdentifiers;
- (void)dealloc;
- (id)init;
- (id)initWithSupportedIdentifiers:(id)aIdentifiers enabledIdentifiers:(id)aIdentifiers2 sublayerFactory:(id)aFactory;
- (id)initWithSupportedIdentifiers:(id)aIdentifiers sublayerFactory:(id)aFactory;
- (id)initWithSupportedIdentifiers:(id)aIdentifiers;
- (id)queryAndVerifySublayerWithIdentifier:(id)aIdentifier;
- (id)sublayerFactory;
- (id)querySublayerWithIdentifier:(id)aIdentifier;
@end

