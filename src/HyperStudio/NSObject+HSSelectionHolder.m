#import "NSObject+HSSelectionHolder.h"

@implementation NSObject (HSSelectionHolder)

// A proxy for several objects is reported as the list of objects.
- (void)getSelectedHyperObject:(id *)aObject orObjects:(id *)aObjects
{
    if (![self conformsToProtocol:@protocol(HSSelectionAccessor)]) {
        [self doesNotRecognizeSelector:_cmd];
        return;
    }
    id selected = [(id<HSSelectionAccessor>)self selectedHyperObject];
    if (![selected isHyperProxy]) {
        *aObject = selected;
        *aObjects = nil;
        return;
    }
    NSArray *objects = [selected allHyperInterfaces];
    if ([objects count] < 2) {
        *aObject = [objects lastObject];
        *aObjects = nil;
    } else {
        *aObject = nil;
        *aObjects = objects;
    }
}

- (void)notifyHyperSelectionHolderWantsToResign
{
    if ([self conformsToProtocol:@protocol(HSSelectionHolder)])
        [[(id<HSSelectionHolder>)self selectionChangeDelegate] selectionHolderWantsToResignAndPassOnSelection:self];
    else
        [self doesNotRecognizeSelector:_cmd];
}

- (void)notifyHyperSelectionHolderReactivate
{
    if ([self conformsToProtocol:@protocol(HSSelectionHolder)])
        [[(id<HSSelectionHolder>)self selectionChangeDelegate] selectionHolderWantsToReactivate:self];
    else
        [self doesNotRecognizeSelector:_cmd];
}

- (void)notifyHyperSelectionDidChangeAndActivate:(BOOL)aActivate
{
    if ([self conformsToProtocol:@protocol(HSSelectionHolder)])
        [[(id<HSSelectionHolder>)self selectionChangeDelegate] selectionHolderDidChangeSelectedHyperObject:self wantsToActivate:aActivate];
    else
        [self doesNotRecognizeSelector:_cmd];
}

@end
