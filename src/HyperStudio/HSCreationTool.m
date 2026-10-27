#import "HSCreationTool.h"

@implementation HSCreationTool

+ (Class)userObjectClass
{
    return Nil;
}

- (void)saveChangesAndNotify:(BOOL)aNotify
{
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    if (aExplicitly)
        [self saveChangesAndNotify:NO];
}

- (void)saveChanges
{
    [self saveChangesAndNotify:YES];
}

- (void)removeObjectFromPrototypeNodeSupport:(id)aSupport
{
    [(HSGenericNodeSupport *)[self prototypeNodeSupport] removeNode:aSupport];
    [self notifyPrototypeObjectInterfacesDidChange];
}

- (void)addObjectToPrototypeNodeSupport:(id)aSupport
{
    [[self prototypeNodeSupport] addNode:aSupport];
    [self notifyPrototypeObjectInterfacesDidChange];
}

- (id)prototypeNodeSupport
{
    if (!_prototypeNodeSupport)
        _prototypeNodeSupport = [[HSGenericNodeSupport nodeSupport] retain];
    return _prototypeNodeSupport;
}

- (id)hyperKindDisplayName
{
    id kind = [self localizedObjectKindName];
    if (!kind)
        return nil;
    NSString *format = [[NSBundle mainBundle] localizedStringForKey:@"%@ Tool" value:@"" table:@"Tools"];
    return [NSString stringWithFormat:format, kind];
}

- (id)queryHyperInterface:(id)aInterface
{
    id result = [super queryHyperInterface:aInterface];
    if ([self allowsToEditPrototypeObjectInterface:aInterface]) {
        [self prototypeObject];
        result = [[[self prototypeNodeSupport] allObjectsInterface] queryHyperInterface:aInterface];
    }
    return result;
}

- (void)notifyPrototypeObjectInterfacesDidChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCreationToolPrototypeInterfacesDidChangeNotification" object:self];
}

- (BOOL)allowsToEditPrototypeObjectInterface:(id)aInterface
{
    return NO;
}

- (BOOL)updatePrototypeWithDictionary:(id)aDictionary
{
    BOOL hasPrototype = [self prototypeObject] != nil;
    if (hasPrototype) {
        [[self prototypeObject] loadExtraDictionaryRepresentation:aDictionary];
        [self prototypeObjectDidChange];
    }
    return hasPrototype;
}

- (id)localizedObjectKindName
{
    Class objectClass = [[self class] userObjectClass];
    if (!objectClass)
        return nil;
    return [[HSUserObjectDefaultAttributesProvider sharedInstance] localizedKindNameForUserObjectClass:objectClass key:nil];
}

- (id)createPrototypeObject
{
    return [[[HSCreationToolSettingsProvider sharedInstance] userObjectPrototypeForToolIdentifier:[self primarySettingsIdentifier]] retain];
}

- (void)didCreatePrototypeObject
{
}

- (void)prototypeObjectDidChange
{
}

- (BOOL)hasCreatedPrototypeObject
{
    return _prototypeObject != nil;
}

- (id)prototypeObject
{
    if (!_prototypeObject) {
        _prototypeObject = [self createPrototypeObject];
        if (_prototypeObject) {
            [[self prototypeNodeSupport] addNode:_prototypeObject];
            [self didCreatePrototypeObject];
            [self prototypeObjectDidChange];
        }
    }
    return _prototypeObject;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_prototypeNodeSupport release];
    [_prototypeObject release];
    [super dealloc];
}

@end
