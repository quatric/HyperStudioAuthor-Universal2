#import "HSHypertextLinksInspectorController.h"

static HSHypertextLinksInspectorController *sSharedHypertextLinksInspectorController = nil;

@implementation HSHypertextLinksInspectorController

+ (id)sharedHypertextLinksInspectorController
{
    @synchronized(self) {
        if (sSharedHypertextLinksInspectorController == nil) {
            [[self alloc] init];
        }
    }
    return sSharedHypertextLinksInspectorController;
}

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (sSharedHypertextLinksInspectorController == nil) {
            sSharedHypertextLinksInspectorController = [super allocWithZone:aZone];
            return sSharedHypertextLinksInspectorController;
        }
    }
    return nil;
}

- (void)dealloc
{
    [_linksInspectorToStackMap release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
}

- (id)autorelease
{
    return self;
}

- (id)linksInspectorToStackMap
{
    if (_linksInspectorToStackMap == nil) {
        _linksInspectorToStackMap = [[NSMutableDictionary alloc] init];
    }
    return _linksInspectorToStackMap;
}

- (id)hypertextLinksInspectorForStack:(id)aStack
{
    if (aStack == nil) {
        return nil;
    }
    NSString *key = [[aStack hyperUID] stringValue];
    id inspector = [[self linksInspectorToStackMap] objectForKey:key];
    if (inspector == nil) {
        inspector = [[HSHypertextLinksProxyForInspector alloc] init];
        [[self linksInspectorToStackMap] setObject:inspector forKey:[[aStack hyperUID] stringValue]];
    }
    return inspector;
}

@end
