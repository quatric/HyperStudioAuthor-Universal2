#import "HSGenericVisualization.h"
#import "HSGenericRenderer.h"
#import "HSPointer.h"

// Render layers being expanded are kept in a sublayers operation group for
// the time they are in the array.
static const void *HSGenericVisualizationGroupRetain(CFAllocatorRef aAllocator, const void *aValue)
{
    [(id)aValue beginRenderSublayersOperationGroup];
    [(id)aValue retain];
    return aValue;
}

static void HSGenericVisualizationGroupRelease(CFAllocatorRef aAllocator, const void *aValue)
{
    [(id)aValue endRenderSublayersOperationGroup];
    [(id)aValue release];
}

static CFStringRef HSGenericVisualizationGroupCopyDescription(const void *aValue)
{
    return (CFStringRef)[[(id)aValue description] copy];
}

static void HSGenericVisualizationUnregisterRenderer(const void *aKey, const void *aValue, void *aContext)
{
    [(id)aValue unregisterWeakReferencer:(id)aContext];
}

static void HSGenericVisualizationAddSubobjectIdentifier(const void *aValue, void *aContext)
{
    NSString *identifier = [NSString stringWithFormat:@"0x%lx", (unsigned long)[[(id)aValue hyperObject] hyperIdentifier]];
    if (identifier != nil)
        [(NSMutableArray *)aContext addObject:identifier];
}

// The generic visualization of a hyper object: one renderer per set of
// visualization options, and render layers shared through identifiers.
@implementation HSGenericVisualization

+ (void)unassignRenderLayer:(id)aLayer
{
    [[self HSGenericVisualization_renderLayerAssigner] unassignRenderLayer:aLayer];
}

+ (void)unassignRenderLayerForIdentifier:(id)aIdentifier forHyperObject:(id)aObject
{
    [[self HSGenericVisualization_renderLayerAssigner] unassignRenderLayerForIdentifier:aIdentifier forHyperObject:aObject];
}

+ (id)renderLayerForIdentifier:(id)aIdentifier forHyperObject:(id)aObject
{
    return [[[[self HSGenericVisualization_renderLayerAssigner] renderLayerForIdentifier:aIdentifier forHyperObject:aObject] retain] autorelease];
}

+ (void)assignRenderLayer:(id)aLayer forIdentifier:(id)aIdentifier
{
    [[self HSGenericVisualization_renderLayerAssigner] assignRenderLayer:aLayer forIdentifier:aIdentifier];
}

+ (id)HSGenericVisualization_renderLayerAssigner
{
    static id assigner = nil;
    if (assigner == nil)
        assigner = [[HSGenericVisualization_HSRenderLayerAssigner alloc] init];
    return assigner;
}

// The precreate selector makes a +1 layer when there is none yet.
- (id)expandableRenderLayerWithIdentifier:(id)aIdentifier precreateSelector:(SEL)aSelector visualizationOptions:(id)aOptions
{
    id layer = [self expandableRenderLayerForIdentifier:aIdentifier];
    if (layer != nil)
        return layer;
    layer = [[self performSelector:aSelector withObject:aOptions] autorelease];
    if (layer != nil) {
        [[self class] assignRenderLayer:layer forIdentifier:aIdentifier];
        [self prepareRenderLayerForExpanding:layer];
    }
    return layer;
}

- (id)renderLayerWithIdentifier:(id)aIdentifier precreateSelector:(SEL)aSelector visualizationOptions:(id)aOptions
{
    id layer = [self renderLayerForIdentifier:aIdentifier];
    if (layer != nil)
        return layer;
    layer = [[self performSelector:aSelector withObject:aOptions] autorelease];
    if (layer != nil)
        [[self class] assignRenderLayer:layer forIdentifier:aIdentifier];
    return layer;
}

// An existing layer gets its sublayers dispersed to be expanded again.
- (id)expandableRenderLayerForIdentifier:(id)aIdentifier
{
    id layer = [[self class] renderLayerForIdentifier:aIdentifier forHyperObject:[self hyperObject]];
    if (layer != nil) {
        [self prepareRenderLayerForExpanding:layer];
        [layer disperseRenderSublayers];
    }
    return layer;
}

- (id)renderLayerForIdentifier:(id)aIdentifier
{
    return [[self class] renderLayerForIdentifier:aIdentifier forHyperObject:[self hyperObject]];
}

- (void)prepareRenderLayerForExpanding:(id)aExpanding
{
    if (_renderLayersWithSublayersOperationGroups == NULL) {
        CFArrayCallBacks callBacks = { 0, HSGenericVisualizationGroupRetain, HSGenericVisualizationGroupRelease, HSGenericVisualizationGroupCopyDescription, NULL };
        _renderLayersWithSublayersOperationGroups = CFArrayCreateMutable(kCFAllocatorDefault, 0, &callBacks);
        if (_renderLayersWithSublayersOperationGroups == NULL)
            return;
    }
    CFArrayAppendValue(_renderLayersWithSublayersOperationGroups, aExpanding);
}

// The operation groups end with the outermost expansion.
- (void)endExpandingRenderLayers
{
    _renderLayersExpandingCounter--;
    if (_renderLayersExpandingCounter == 0 && _renderLayersWithSublayersOperationGroups != NULL) {
        CFRelease(_renderLayersWithSublayersOperationGroups);
        _renderLayersWithSublayersOperationGroups = NULL;
    }
}

- (void)beginExpandingRenderLayers
{
    _renderLayersExpandingCounter++;
}

// Returns the path.
- (id)expandRenderLayerTreeWithRoot:(id)aRoot fromRenderLayerAtPath:(id)aPath withVisualizationOptions:(id)aOptions
{
    id layer = [aRoot renderLayerAtIndexPath:aPath role:nil];
    id tree = [self buildRenderLayerTreeWithVisualizationOptions:aOptions];
    if (tree != nil)
        [layer addRenderSublayer:tree forRole:@"HSSubobjectRootRenderLayerRole" asRoot:YES addingTransparencyLayerRequirement:YES];
    return aPath;
}

- (id)buildRenderLayerTreeWithVisualizationOptions:(id)aOptions
{
    [self beginExpandingRenderLayers];
    id tree = [self expandedRenderLayerTreeWithVisualizationOptions:aOptions];
    [self endExpandingRenderLayers];
    return tree;
}

- (id)expandedRenderLayerTreeWithVisualizationOptions:(id)aOptions
{
    return nil;
}

- (id)renderLayerIdentifierAppendingSuffixForVisualizationOptions:(id)aOptions toBaseIdentifier:(id)aIdentifier
{
    id suffix = [self HSGenericVisualization_rendererIdentifierForVisualizationOptions:aOptions];
    return suffix != nil ? [aIdentifier stringByAppendingString:suffix] : nil;
}

- (id)existingRenders
{
    if (_visualizationOptionsToRendererMap == NULL)
        return [NSArray array];
    CFIndex count = CFDictionaryGetCount(_visualizationOptionsToRendererMap);
    if (count == 0)
        return [NSArray array];
    const void **renderers = malloc(count * sizeof(void *));
    if (renderers == NULL)
        return nil;
    CFDictionaryGetKeysAndValues(_visualizationOptionsToRendererMap, NULL, renderers);
    NSArray *array = [NSArray arrayWithObjects:(id *)renderers count:count];
    free(renderers);
    return array;
}

- (id)existingRendererWithVisualizationOptions:(id)aOptions
{
    if (_visualizationOptionsToRendererMap == NULL)
        return nil;
    id identifier = [self HSGenericVisualization_rendererIdentifierForVisualizationOptions:aOptions];
    if (identifier == nil)
        return nil;
    return (id)CFDictionaryGetValue(_visualizationOptionsToRendererMap, identifier);
}

// Returns +1.
- (id)createRendererWithVisualizationOptions:(id)aOptions
{
    return [[HSGenericRenderer alloc] initWithVisualization:self options:aOptions];
}

// Renderers are kept weakly, by options identifier.
- (id)queryRendererWithVisualizationOptions:(id)aOptions
{
    id identifier = [self HSGenericVisualization_rendererIdentifierForVisualizationOptions:aOptions];
    if (identifier == nil)
        return nil;
    id renderer = nil;
    if (_visualizationOptionsToRendererMap != NULL)
        renderer = (id)CFDictionaryGetValue(_visualizationOptionsToRendererMap, identifier);
    if (renderer != nil)
        return renderer;
    renderer = [[self createRendererWithVisualizationOptions:aOptions] autorelease];
    if (renderer == nil)
        return nil;
    if (_visualizationOptionsToRendererMap == NULL) {
        _visualizationOptionsToRendererMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFEWeakObjectPointerDictionaryValueCallBacks);
        if (_visualizationOptionsToRendererMap == NULL)
            return renderer;   // the original went on with a NULL dictionary
    }
    CFDictionarySetValue(_visualizationOptionsToRendererMap, identifier, renderer);
    [renderer registerWeakReferencer:self];
    return renderer;
}

- (id)queryRenderer
{
    return [self queryRendererWithVisualizationOptions:nil];
}

- (id)visualizationForSubobject:(id)aSubobject
{
    return nil;
}

- (id)subobjectVisualizations
{
    return [NSArray array];
}

- (id)subobjects
{
    return [NSArray array];
}

- (id)visualizationProtocol
{
    return _visualizationProtocol;
}

- (id)implementationForHyperObject:(id)aObject
{
    if (_hyperObject == aObject)
        return self;
    return [[[[self class] alloc] initWithHyperObject:aObject visualizationProtocol:_visualizationProtocol] autorelease];
}

- (BOOL)implementsHyperInterface:(id)aInterface
{
    return [_hyperObject implementsHyperInterface:aInterface];
}

- (id)queryHyperInterface:(id)aInterface
{
    return [_hyperObject queryHyperInterface:aInterface];
}

- (id)hyperObject
{
    return _hyperObject;
}

- (id)description
{
    id hyperObject = [self hyperObject];
    return [NSString stringWithFormat:@"<%@: %p> {hyper-object = <%@: %p>; visualization protocol = %s; sub-object visualizations = %@}", NSStringFromClass([self class]), self, NSStringFromClass([hyperObject class]), hyperObject, protocol_getName([self visualizationProtocol]), [self subobjectVisualizations]];
}

// A renderer going away.
- (void)dereferenceObject:(id)aObject
{
    if (![aObject conformsToProtocol:@protocol(HSRendererUpdating)] || _visualizationOptionsToRendererMap == NULL)
        return;
    id identifier = [self HSGenericVisualization_rendererIdentifierForVisualizationOptions:[aObject visualizationOptions]];
    if (identifier != nil)
        CFDictionaryRemoveValue(_visualizationOptionsToRendererMap, identifier);
}

- (void)dealloc
{
    if ([_hyperObject conformsToProtocol:@protocol(HSImplementationAssociating)])
        [_hyperObject rejectImplementation:self];
    if (_visualizationOptionsToRendererMap != NULL) {
        CFDictionaryApplyFunction(_visualizationOptionsToRendererMap, HSGenericVisualizationUnregisterRenderer, self);
        CFRelease(_visualizationOptionsToRendererMap);
    }
    // Added: an expansion still running at dealloc leaked its groups.
    if (_renderLayersWithSublayersOperationGroups != NULL)
        CFRelease(_renderLayersWithSublayersOperationGroups);
    [_hyperObject release];
    [super dealloc];
}

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol
{
    self = [super init];
    if (self != nil) {
        _hyperObject = [aObject retain];
        if ([_hyperObject conformsToProtocol:@protocol(HSImplementationAssociating)])
            [_hyperObject associateImplementation:self withInterface:aProtocol];
        _visualizationProtocol = aProtocol;
    }
    return self;
}

// "" or "(Sub-objects Only)", with the ignored sub-objects as "-{...}".
- (id)HSGenericVisualization_rendererIdentifierForVisualizationOptions:(id)aOptions
{
    id ignoredSubobjects = [aOptions objectForKey:@"HSIgnoredSubobjectsVisualizationOption"];
    NSUInteger count = [ignoredSubobjects count];
    BOOL subobjectsOnly = [[aOptions objectForKey:@"HSSubobjectsOnlyVisualizationOption"] boolValue];
    if (count == 0)
        return subobjectsOnly ? @"(Sub-objects Only)" : @"";
    NSMutableArray *identifiers = [NSMutableArray arrayWithCapacity:count];
    if (identifiers == nil)
        return nil;
    CFSetApplyFunction((CFSetRef)ignoredSubobjects, HSGenericVisualizationAddSubobjectIdentifier, identifiers);
    NSString *joined = [[identifiers sortedArrayUsingSelector:@selector(compare:)] componentsJoinedByString:@", "];
    if (joined == nil)
        return nil;
    return [NSString stringWithFormat:subobjectsOnly ? @"(Sub-objects Only)-{%@}" : @"-{%@}", joined];
}

@end

// Which render layers are assigned to which hyper objects, under which
// identifiers. Layers are referenced weakly.
@implementation HSGenericVisualization_HSRenderLayerAssigner

// Drops the layer's identifiers from its object's table (the whole table
// when they are all of it).
- (void)unassignRenderLayer:(id)aLayer
{
    id hyperObject = nil;
    if (_renderLayerToHyperObjectMap != nil) {
        hyperObject = NSMapGet(_renderLayerToHyperObjectMap, aLayer);
        NSMapRemove(_renderLayerToHyperObjectMap, aLayer);
    }
    if (_renderLayerToIdentifiersMap == nil)
        return;
    NSSet *identifiers = NSMapGet(_renderLayerToIdentifiersMap, aLayer);
    if (identifiers == nil)
        return;
    if (hyperObject == nil)
        hyperObject = [aLayer hyperObject];
    if (hyperObject != nil && _hyperObjectToRenderLayersMap != nil) {
        NSMapTable *layers = [(HSPointer *)NSMapGet(_hyperObjectToRenderLayersMap, hyperObject) pointer];
        if (layers != nil) {
            if ([identifiers count] == NSCountMapTable(layers)) {
                NSMapRemove(_hyperObjectToRenderLayersMap, hyperObject);
            } else {
                for (id identifier in identifiers)
                    NSMapRemove(layers, identifier);
            }
        }
    }
    NSMapRemove(_renderLayerToIdentifiersMap, aLayer);
    [aLayer unregisterWeakReferencer:self];
}

- (void)unassignRenderLayerForIdentifier:(id)aIdentifier forHyperObject:(id)aObject
{
    if (_hyperObjectToRenderLayersMap == nil)
        return;
    NSMapTable *layers = [(HSPointer *)NSMapGet(_hyperObjectToRenderLayersMap, aObject) pointer];
    if (layers == nil)
        return;
    id layer = NSMapGet(layers, aIdentifier);
    if (layer == nil)
        return;
    if (_renderLayerToHyperObjectMap != nil)
        NSMapRemove(_renderLayerToHyperObjectMap, layer);
    if (NSCountMapTable(layers) == 1)
        NSMapRemove(_hyperObjectToRenderLayersMap, aObject);
    else
        NSMapRemove(layers, aIdentifier);
    NSMutableSet *identifiers = NSMapGet(_renderLayerToIdentifiersMap, layer);
    if ([identifiers count] == 1) {
        [layer unregisterWeakReferencer:self];
        NSMapRemove(_renderLayerToIdentifiersMap, layer);
    } else {
        [identifiers removeObject:aIdentifier];
    }
}

- (id)renderLayerForIdentifier:(id)aIdentifier forHyperObject:(id)aObject
{
    if (_hyperObjectToRenderLayersMap == nil)
        return nil;
    NSMapTable *layers = [(HSPointer *)NSMapGet(_hyperObjectToRenderLayersMap, aObject) pointer];
    return layers != nil ? NSMapGet(layers, aIdentifier) : nil;
}

// A layer already under the identifier is replaced.
- (void)assignRenderLayer:(id)aLayer forIdentifier:(id)aIdentifier
{
    id hyperObject = [aLayer hyperObject];
    if (hyperObject == nil)
        return;
    NSMapTable *layers = nil;
    if (_hyperObjectToRenderLayersMap == nil) {
        _hyperObjectToRenderLayersMap = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
        if (_hyperObjectToRenderLayersMap == nil)
            return;
    } else {
        layers = [(HSPointer *)NSMapGet(_hyperObjectToRenderLayersMap, hyperObject) pointer];
    }
    if (layers == nil) {
        layers = NSCreateMapTable(NSObjectMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
        if (layers == nil)
            return;
        id wrapper = [HSPointer wrapperForPointer:layers withDisposer:NSFreeMapTable];
        if (wrapper == nil) {
            NSFreeMapTable(layers);
            return;
        }
        NSMapInsert(_hyperObjectToRenderLayersMap, hyperObject, wrapper);
    }
    if (_renderLayerToHyperObjectMap == nil) {
        _renderLayerToHyperObjectMap = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
        if (_renderLayerToHyperObjectMap == nil)
            return;
    }
    NSMutableSet *identifiers = nil;
    if (_renderLayerToIdentifiersMap == nil) {
        _renderLayerToIdentifiersMap = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
        if (_renderLayerToIdentifiersMap == nil)
            return;
    } else {
        identifiers = NSMapGet(_renderLayerToIdentifiersMap, aLayer);
    }
    if (identifiers == nil) {
        identifiers = [NSMutableSet set];
        if (identifiers == nil)
            return;
        NSMapInsert(_renderLayerToIdentifiersMap, aLayer, identifiers);
        [aLayer registerWeakReferencer:self];
    }
    id oldLayer = NSMapGet(layers, aIdentifier);
    // Fixed: reassigning a layer to its only identifier freed the set that
    // was then added to.
    if (oldLayer != nil && oldLayer != aLayer) {
        NSMutableSet *oldIdentifiers = NSMapGet(_renderLayerToIdentifiersMap, oldLayer);
        if ([oldIdentifiers count] == 1) {
            [oldLayer unregisterWeakReferencer:self];
            NSMapRemove(_renderLayerToIdentifiersMap, oldLayer);
        } else {
            [oldIdentifiers removeObject:aIdentifier];
        }
    }
    NSMapInsert(layers, aIdentifier, aLayer);
    NSMapInsert(_renderLayerToHyperObjectMap, aLayer, hyperObject);
    [identifiers addObject:aIdentifier];
}

// A layer going away.
- (void)dereferenceObject:(id)aObject
{
    id hyperObject = nil;
    if (_renderLayerToHyperObjectMap != nil) {
        hyperObject = NSMapGet(_renderLayerToHyperObjectMap, aObject);
        NSMapRemove(_renderLayerToHyperObjectMap, aObject);
    }
    if (_renderLayerToIdentifiersMap == nil)
        return;
    NSSet *identifiers = NSMapGet(_renderLayerToIdentifiersMap, aObject);
    if (identifiers == nil)
        return;
    [[identifiers retain] autorelease];
    NSMapRemove(_renderLayerToIdentifiersMap, aObject);
    if (hyperObject == nil || _hyperObjectToRenderLayersMap == nil)
        return;
    NSMapTable *layers = [(HSPointer *)NSMapGet(_hyperObjectToRenderLayersMap, hyperObject) pointer];
    if (layers == nil)
        return;
    if ([identifiers count] == NSCountMapTable(layers)) {
        NSMapRemove(_hyperObjectToRenderLayersMap, hyperObject);
    } else {
        for (id identifier in identifiers)
            NSMapRemove(layers, identifier);
    }
}

- (void)dealloc
{
    if (_renderLayerToHyperObjectMap != nil)
        NSFreeMapTable(_renderLayerToHyperObjectMap);
    if (_renderLayerToIdentifiersMap != nil) {
        NSMapEnumerator enumerator = NSEnumerateMapTable(_renderLayerToIdentifiersMap);
        void *layer;
        void *identifiers;
        while (NSNextMapEnumeratorPair(&enumerator, &layer, &identifiers))
            [(id)layer unregisterWeakReferencer:self];
        NSEndMapTableEnumeration(&enumerator);
        NSFreeMapTable(_renderLayerToIdentifiersMap);
    }
    if (_hyperObjectToRenderLayersMap != nil)
        NSFreeMapTable(_hyperObjectToRenderLayersMap);
    [super dealloc];
}

@end
