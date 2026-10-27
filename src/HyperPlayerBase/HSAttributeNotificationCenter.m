#import "HSAttributeNotificationCenter.h"
#import "NSEMutableProtocolSet.h"

// Observers are kept per object (NULL for any object), then per change bit,
// per attribute protocol (NULL for any attribute), per priority (x10000,
// rounded), per observer (held weakly) and per selector, ending in an observer
// record. A record released from the maps is invalidated, so notifications
// already gathered skip it.

#define HSAttributeChangeBitCount 10

static HSAttributeNotificationCenter *HSDefaultAttributeNotificationCenter;

static const void *HSObserverRecordRetain(CFAllocatorRef aAllocator, const void *aValue)
{
    return [(id)aValue retain];
}

static void HSObserverRecordRelease(CFAllocatorRef aAllocator, const void *aValue)
{
    [(HSAttributeNotificationCenter_HSObserverRecord *)aValue invalidate];
    [(id)aValue release];
}

static CFStringRef HSObserverRecordCopyDescription(const void *aValue)
{
    return (CFStringRef)[[(id)aValue description] retain];
}

static const CFDictionaryValueCallBacks HSObserverRecordDictionaryValueCallBacks = {
    0, HSObserverRecordRetain, HSObserverRecordRelease, HSObserverRecordCopyDescription, NULL
};

// Collects keys to remove while a dictionary is being applied over.
static void HSAppendKey(NSMutableData **aKeys, const void *aKey)
{
    if (*aKeys)
        [*aKeys appendBytes:&aKey length:sizeof(aKey)];
    else
        *aKeys = [NSMutableData dataWithBytes:&aKey length:sizeof(aKey)];
}

// Removes the collected keys, unless they are all the keys: then YES tells
// the caller to drop the whole dictionary.
static BOOL HSRemoveKeys(CFMutableDictionaryRef aDictionary, NSData *aKeys)
{
    if (!aKeys)
        return NO;
    NSUInteger count = [aKeys length] / sizeof(void *);
    if ((NSUInteger)CFDictionaryGetCount(aDictionary) == count)
        return YES;
    const void * const *keys = [aKeys bytes];
    for (NSUInteger i = 0; i < count; i++)
        CFDictionaryRemoveValue(aDictionary, keys[i]);
    return NO;
}

struct HSObserverRemoval {
    id observer;
    SEL selector;
    NSMutableData *keysToRemove;
};

// Over a priority to observers map: drops the observer (or just its
// selector), noting priorities left without observers.
static void HSRemoveObserverFromPriority(const void *aKey, const void *aValue, void *aContext)
{
    struct HSObserverRemoval *removal = aContext;
    CFMutableDictionaryRef observers = (CFMutableDictionaryRef)aValue;
    if (removal->selector) {
        CFMutableDictionaryRef selectors = (CFMutableDictionaryRef)CFDictionaryGetValue(observers, removal->observer);
        if (!selectors)
            return;
        if (CFDictionaryGetCount(selectors) != 1) {
            CFDictionaryRemoveValue(selectors, removal->selector);
            return;
        }
        if (!CFDictionaryGetValue(selectors, removal->selector))
            return;
    }
    if (CFDictionaryGetCount(observers) != 1) {
        CFDictionaryRemoveValue(observers, removal->observer);
        return;
    }
    if (CFDictionaryGetValue(observers, removal->observer))
        HSAppendKey(&removal->keysToRemove, aKey);
}

// YES when the priorities map is left empty.
static BOOL HSRemoveObserverFromPriorities(CFMutableDictionaryRef aPriorities, id aObserver, SEL aSelector)
{
    struct HSObserverRemoval removal = { aObserver, aSelector, nil };
    CFDictionaryApplyFunction(aPriorities, HSRemoveObserverFromPriority, &removal);
    return HSRemoveKeys(aPriorities, removal.keysToRemove);
}

static void HSRemoveObserverFromAttribute(const void *aKey, const void *aValue, void *aContext)
{
    struct HSObserverRemoval *removal = aContext;
    if (HSRemoveObserverFromPriorities((CFMutableDictionaryRef)aValue, removal->observer, removal->selector))
        HSAppendKey(&removal->keysToRemove, aKey);
}

// Over the changes in aChanges of one object, for the attributes listed (all
// of them when NULL).
static void HSRemoveObserverFromChanges(NSUInteger aChanges, Protocol **aAttributes, CFMutableDictionaryRef aChangeMap, id aObserver, SEL aSelector)
{
    for (NSUInteger bit = 0; bit < HSAttributeChangeBitCount; bit++) {
        NSUInteger change = (NSUInteger)1 << bit;
        if (!(aChanges & change))
            continue;
        CFMutableDictionaryRef attributes = (CFMutableDictionaryRef)CFDictionaryGetValue(aChangeMap, (const void *)change);
        if (!attributes)
            continue;
        if (aAttributes) {
            for (Protocol **attribute = aAttributes; *attribute; attribute++) {
                CFMutableDictionaryRef priorities = (CFMutableDictionaryRef)CFDictionaryGetValue(attributes, *attribute);
                if (priorities && HSRemoveObserverFromPriorities(priorities, aObserver, aSelector))
                    CFDictionaryRemoveValue(attributes, *attribute);
            }
            if (CFDictionaryGetCount(attributes) == 0)
                CFDictionaryRemoveValue(aChangeMap, (const void *)change);
        } else {
            struct HSObserverRemoval removal = { aObserver, aSelector, nil };
            CFDictionaryApplyFunction(attributes, HSRemoveObserverFromAttribute, &removal);
            if (HSRemoveKeys(attributes, removal.keysToRemove))
                CFDictionaryRemoveValue(aChangeMap, (const void *)change);
        }
    }
}

struct HSObjectsObserverRemoval {
    id observer;
    SEL selector;
    NSUInteger changes;
    Protocol **attributes;
    NSMutableData *keysToRemove;
};

static void HSRemoveObserverFromObject(const void *aKey, const void *aValue, void *aContext)
{
    struct HSObjectsObserverRemoval *removal = aContext;
    HSRemoveObserverFromChanges(removal->changes, removal->attributes, (CFMutableDictionaryRef)aValue, removal->observer, removal->selector);
    if (CFDictionaryGetCount((CFDictionaryRef)aValue) == 0)
        HSAppendKey(&removal->keysToRemove, aKey);
}

// Records gathered for one observer and selector.
static void HSGatherSelectorRecord(const void *aKey, const void *aValue, void *aContext)
{
    CFMutableDictionaryRef selectors = aContext;
    CFMutableArrayRef records = (CFMutableArrayRef)CFDictionaryGetValue(selectors, aKey);
    if (!records) {
        records = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        if (!records)
            return;
        CFDictionarySetValue(selectors, aKey, records);
        CFRelease(records);
    }
    CFArrayAppendValue(records, aValue);
}

static void HSGatherObserverRecords(const void *aKey, const void *aValue, void *aContext)
{
    CFMutableDictionaryRef observers = aContext;
    CFMutableDictionaryRef selectors = (CFMutableDictionaryRef)CFDictionaryGetValue(observers, aKey);
    if (!selectors) {
        selectors = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &NSESelectorDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (!selectors)
            return;
        CFDictionarySetValue(observers, aKey, selectors);
        CFRelease(selectors);
    }
    CFDictionaryApplyFunction((CFDictionaryRef)aValue, HSGatherSelectorRecord, selectors);
}

// Merges one priority's observers into the gathered priority records, kept
// from the highest priority down.
static void HSGatherPriorityRecords(const void *aKey, const void *aValue, void *aContext)
{
    NSMutableArray *priorityRecords = aContext;
    NSInteger priority = (NSInteger)aKey;
    NSUInteger count = [priorityRecords count];
    NSUInteger index = 0;
    CFMutableDictionaryRef observers = NULL;
    NSUInteger low = 0, high = count;
    while (low < high) {
        NSUInteger middle = (low + high) / 2;
        HSAttributeNotificationCenter_HSObserverPriorityRecord *record = [priorityRecords objectAtIndex:middle];
        NSInteger recordPriority = [record priority];
        if (recordPriority == priority) {
            observers = [record observerToSelectorsMap];
            break;
        }
        if (recordPriority > priority)
            low = middle + 1;
        else
            high = middle;
        index = low;
    }
    if (!observers) {
        HSAttributeNotificationCenter_HSObserverPriorityRecord *record = [[[HSAttributeNotificationCenter_HSObserverPriorityRecord alloc] initWithPriority:priority] autorelease];
        if (!record)
            return;
        observers = [record observerToSelectorsMap];
        if (!observers)
            return;
        [priorityRecords insertObject:record atIndex:index];
    }
    CFDictionaryApplyFunction((CFDictionaryRef)aValue, HSGatherObserverRecords, observers);
}

// Exceptions raised by an observer are logged and ignored.
static void HSPostToSelectorRecords(const void *aKey, const void *aValue, void *aContext)
{
    CFArrayRef records = aValue;
    CFIndex count = CFArrayGetCount(records);
    for (CFIndex i = 0; i < count; i++) {
        id observer = [(HSAttributeNotificationCenter_HSObserverRecord *)CFArrayGetValueAtIndex(records, i) observer];
        if (!observer)
            continue;
        @try {
            [observer performSelector:(SEL)aKey withObject:(id)aContext];
        } @catch (id exception) {
            NSLog(@"Exception was raised while posting an attribute notification. Ignored.");
            NSLog(@"(%@)", exception);
        }
    }
}

static void HSPostToObserverRecords(const void *aKey, const void *aValue, void *aContext)
{
    CFDictionaryApplyFunction((CFDictionaryRef)aValue, HSPostToSelectorRecords, aContext);
}

// Attribute change notifications to observers registered for an object (or
// any object), for changes and for attributes or the hyper interfaces
// adopting them, called in priority order.
@implementation HSAttributeNotificationCenter

+ (id)defaultCenter
{
    if (!HSDefaultAttributeNotificationCenter)
        HSDefaultAttributeNotificationCenter = [[HSAttributeNotificationCenter alloc] init];
    return HSDefaultAttributeNotificationCenter;
}

- (void)notifyChange:(NSInteger)aChange ofAttributeSet:(id)aSet ofObject:(id)aObject withUserInfoInvocation:(id)aInvocation
{
    [self postAttributeChangeNotification:[HSAttributeNotification notificationWithChange:aChange attributeSet:aSet object:aObject userInfoInvocation:aInvocation]];
}

- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute ofObject:(id)aObject withUserInfoInvocation:(id)aInvocation
{
    [self postAttributeChangeNotification:[HSAttributeNotification notificationWithChange:aChange attribute:aAttribute object:aObject userInfoInvocation:aInvocation]];
}

- (void)notifyChange:(NSInteger)aChange ofAttributeSet:(id)aSet ofObject:(id)aObject withUserInfo:(id)aInfo
{
    [self postAttributeChangeNotification:[HSAttributeNotification notificationWithChange:aChange attributeSet:aSet object:aObject userInfo:aInfo]];
}

- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute ofObject:(id)aObject withUserInfo:(id)aInfo
{
    [self postAttributeChangeNotification:[HSAttributeNotification notificationWithChange:aChange attribute:aAttribute object:aObject userInfo:aInfo]];
}

- (void)postAttributeChangeNotification:(id)aNotification
{
    if (!_objectToAttributeChangesMap || CFDictionaryGetCount(_objectToAttributeChangesMap) == 0)
        return;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray *priorityRecords = nil;
    NSEProtocolSet *attributeHierarchy = nil;
    [self HSAttributeNotificationCenter_gatherObserverPriorityRecordsIntoArray:&priorityRecords forAttributeChangeNotification:aNotification object:[aNotification object] withAttributeHierarchySet:&attributeHierarchy];
    [self HSAttributeNotificationCenter_gatherObserverPriorityRecordsIntoArray:&priorityRecords forAttributeChangeNotification:aNotification object:nil withAttributeHierarchySet:&attributeHierarchy];
    NSUInteger count = [priorityRecords count];
    for (NSUInteger i = 0; i < count; i++)
        CFDictionaryApplyFunction([[priorityRecords objectAtIndex:i] observerToSelectorsMap], HSPostToObserverRecords, aNotification);
    [pool release];
}

// Observers of any attribute, then of each attribute the changed ones adopt.
- (void)HSAttributeNotificationCenter_gatherObserverPriorityRecordsIntoArray:(id *)aArray forAttributeChangeNotification:(id)aNotification object:(id)aObject withAttributeHierarchySet:(id *)aSet
{
    CFDictionaryRef changes = CFDictionaryGetValue(_objectToAttributeChangesMap, aObject);
    if (!changes)
        return;
    CFDictionaryRef attributes = CFDictionaryGetValue(changes, (const void *)[aNotification attributeChange]);
    if (!attributes)
        return;
    if (!*aSet) {
        *aSet = [[[aNotification attributeProtocolSet] copyAdoptedProtocols] autorelease];
        if (!*aSet)
            return;
    }
    CFDictionaryRef priorities = CFDictionaryGetValue(attributes, NULL);
    if (priorities) {
        if (!*aArray)
            *aArray = [NSMutableArray array];
        CFDictionaryApplyFunction(priorities, HSGatherPriorityRecords, *aArray);
    }
    for (Protocol *attribute in *aSet) {
        priorities = CFDictionaryGetValue(attributes, attribute);
        if (priorities) {
            if (!*aArray)
                *aArray = [NSMutableArray array];
            CFDictionaryApplyFunction(priorities, HSGatherPriorityRecords, *aArray);
        }
    }
}

- (void)removeObserver:(id)aObserver
{
    [self HSAttributeNotificationCenter_removeObserver:aObserver selector:NULL ofChanges:HSAllAttributeChanges ofAttributes:NULL ofObject:nil];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector
{
    [self HSAttributeNotificationCenter_removeObserver:aObserver selector:aSelector ofChanges:HSAllAttributeChanges ofAttributes:NULL ofObject:nil];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces ofObject:(id)aObject
{
    NSEMutableProtocolSet *attributes = [NSEMutableProtocolSet protocolSet];
    if (!attributes)
        return;
    for (; *aInterfaces; aInterfaces++)
        HSCollectHyperInterfaceAttributes(*aInterfaces, attributes);
    Protocol **protocols = [attributes allProtocols];
    if (protocols)
        [self HSAttributeNotificationCenter_removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:(id *)protocols ofObject:aObject];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface ofObject:(id)aObject
{
    NSEMutableProtocolSet *attributes = [NSEMutableProtocolSet protocolSet];
    if (!attributes)
        return;
    HSCollectHyperInterfaceAttributes(aInterface, attributes);
    Protocol **protocols = [attributes allProtocols];
    if (protocols)
        [self HSAttributeNotificationCenter_removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:(id *)protocols ofObject:aObject];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet ofObject:(id)aObject
{
    Protocol **protocols = [aSet allProtocols];
    if (protocols)
        [self HSAttributeNotificationCenter_removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:(id *)protocols ofObject:aObject];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes ofObject:(id)aObject
{
    [self HSAttributeNotificationCenter_removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:aObject];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute ofObject:(id)aObject
{
    id attributes[2] = { aAttribute, nil };
    [self HSAttributeNotificationCenter_removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttribute ? attributes : NULL ofObject:aObject];
}

// A nil object removes the observer's registrations for every object, a NULL
// selector all its selectors and NULL attributes all attributes.
- (void)HSAttributeNotificationCenter_removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes ofObject:(id)aObject
{
    if (!_objectToAttributeChangesMap)
        return;
    if (aObject) {
        CFMutableDictionaryRef changes = (CFMutableDictionaryRef)CFDictionaryGetValue(_objectToAttributeChangesMap, aObject);
        if (changes) {
            HSRemoveObserverFromChanges(aChanges, (Protocol **)aAttributes, changes, aObserver, aSelector);
            if (CFDictionaryGetCount(changes) == 0)
                CFDictionaryRemoveValue(_objectToAttributeChangesMap, aObject);
        }
        return;
    }
    struct HSObjectsObserverRemoval removal = { aObserver, aSelector, aChanges, (Protocol **)aAttributes, nil };
    CFDictionaryApplyFunction(_objectToAttributeChangesMap, HSRemoveObserverFromObject, &removal);
    if (HSRemoveKeys(_objectToAttributeChangesMap, removal.keysToRemove))
        CFDictionaryRemoveAllValues(_objectToAttributeChangesMap);
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces ofObject:(id)aObject withPriority:(CGFloat)aPriority
{
    if (!*aInterfaces)
        return;
    NSEMutableProtocolSet *attributes = [NSEMutableProtocolSet protocolSet];
    if (!attributes)
        return;
    for (; *aInterfaces; aInterfaces++)
        HSCollectHyperInterfaceAttributes(*aInterfaces, attributes);
    Protocol **protocols = [attributes allProtocols];
    if (protocols)
        [self HSAttributeNotificationCenter_addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:(id *)protocols ofObject:aObject withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface ofObject:(id)aObject withPriority:(CGFloat)aPriority
{
    NSEMutableProtocolSet *attributes = [NSEMutableProtocolSet protocolSet];
    if (!attributes)
        return;
    HSCollectHyperInterfaceAttributes(aInterface, attributes);
    Protocol **protocols = [attributes allProtocols];
    if (protocols)
        [self HSAttributeNotificationCenter_addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:(id *)protocols ofObject:aObject withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet ofObject:(id)aObject withPriority:(CGFloat)aPriority
{
    Protocol **protocols = [aSet allProtocols];
    if (protocols)
        [self HSAttributeNotificationCenter_addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:(id *)protocols ofObject:aObject withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes ofObject:(id)aObject withPriority:(CGFloat)aPriority
{
    [self HSAttributeNotificationCenter_addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:aObject withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute ofObject:(id)aObject withPriority:(CGFloat)aPriority
{
    id attributes[2] = { aAttribute, nil };
    [self HSAttributeNotificationCenter_addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttribute ? attributes : NULL ofObject:aObject withPriority:aPriority];
}

// NULL attributes observe any attribute, a nil object any object.
- (void)HSAttributeNotificationCenter_addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes ofObject:(id)aObject withPriority:(CGFloat)aPriority
{
    CFMutableDictionaryRef changes = NULL;
    if (!_objectToAttributeChangesMap) {
        _objectToAttributeChangesMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &HSNonOwnedCFTypePointerOrNullCFDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (!_objectToAttributeChangesMap)
            return;
    } else {
        changes = (CFMutableDictionaryRef)CFDictionaryGetValue(_objectToAttributeChangesMap, aObject);
    }
    if (!changes) {
        changes = CFDictionaryCreateMutable(kCFAllocatorDefault, HSAttributeChangeBitCount, &kCFEIntegerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (!changes)
            return;
        CFDictionaryAddValue(_objectToAttributeChangesMap, aObject, changes);
        CFRelease(changes);
    }
    for (NSUInteger bit = 0; bit < HSAttributeChangeBitCount; bit++) {
        if (aChanges & ((NSUInteger)1 << bit))
            [self HSAttributeNotificationCenter_addObserver:aObserver selector:aSelector ofChange:(NSInteger)1 << bit ofAttributes:aAttributes withPriority:aPriority toAttributeChangeToAttributesMap:changes];
    }
}

- (void)HSAttributeNotificationCenter_addObserver:(id)aObserver selector:(SEL)aSelector ofChange:(NSInteger)aChange ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority toAttributeChangeToAttributesMap:(struct __CFDictionary *)aMap
{
    CFMutableDictionaryRef attributes = (CFMutableDictionaryRef)CFDictionaryGetValue(aMap, (const void *)aChange);
    if (!attributes) {
        attributes = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &HSProtocolOrNullCFDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (!attributes)
            return;
        CFDictionaryAddValue(aMap, (const void *)aChange, attributes);
        CFRelease(attributes);
    }
    if (!aAttributes) {
        [self HSAttributeNotificationCenter_addObserver:aObserver selector:aSelector ofAttribute:nil withPriority:aPriority toAttributeToPrioritiesMap:attributes];
        return;
    }
    for (; *aAttributes; aAttributes++)
        [self HSAttributeNotificationCenter_addObserver:aObserver selector:aSelector ofAttribute:*aAttributes withPriority:aPriority toAttributeToPrioritiesMap:attributes];
}

// An observer already registered with the selector keeps its record.
- (void)HSAttributeNotificationCenter_addObserver:(id)aObserver selector:(SEL)aSelector ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority toAttributeToPrioritiesMap:(struct __CFDictionary *)aMap
{
    HSAttributeNotificationCenter_HSObserverRecord *record = [[[HSAttributeNotificationCenter_HSObserverRecord alloc] initWithObserver:aObserver selector:aSelector] autorelease];
    if (!record)
        return;
    CFMutableDictionaryRef priorities = (CFMutableDictionaryRef)CFDictionaryGetValue(aMap, aAttribute);
    NSInteger priority = lroundf(aPriority * 10000);
    CFMutableDictionaryRef observers = NULL;
    CFMutableDictionaryRef selectors = NULL;
    if (!priorities) {
        priorities = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEIntegerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (!priorities)
            return;
        CFDictionaryAddValue(aMap, aAttribute, priorities);
        CFRelease(priorities);
    } else {
        observers = (CFMutableDictionaryRef)CFDictionaryGetValue(priorities, (const void *)priority);
        if (observers)
            selectors = (CFMutableDictionaryRef)CFDictionaryGetValue(observers, aObserver);
    }
    if (!observers) {
        observers = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (!observers)
            return;
        CFDictionaryAddValue(priorities, (const void *)priority, observers);
        CFRelease(observers);
    }
    if (!selectors) {
        selectors = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &NSESelectorDictionaryKeyCallBacks, &HSObserverRecordDictionaryValueCallBacks);
        if (!selectors)
            return;
        CFDictionaryAddValue(observers, aObserver, selectors);
        CFRelease(selectors);
    }
    CFDictionaryAddValue(selectors, aSelector, record);
}

- (BOOL)hasObservers
{
    return _objectToAttributeChangesMap && CFDictionaryGetCount(_objectToAttributeChangesMap) > 0;
}

- (id)description
{
    NSString *map = [(NSString *)CFCopyDescription(_objectToAttributeChangesMap) autorelease];
    return [NSString stringWithFormat:@"<%@: 0x%x>{%@}", NSStringFromClass([self class]), (unsigned int)(uintptr_t)self, map];
}

- (void)dealloc
{
    if (_objectToAttributeChangesMap)
        CFRelease(_objectToAttributeChangesMap);
    [super dealloc];
}

@end

// The observers of one priority, gathered for a notification.
@implementation HSAttributeNotificationCenter_HSObserverPriorityRecord

- (struct __CFDictionary *)observerToSelectorsMap
{
    if (!_observerToSelectorsMap)
        _observerToSelectorsMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return _observerToSelectorsMap;
}

- (NSInteger)priority
{
    return _priority;
}

- (id)description
{
    NSString *records = [(NSString *)CFCopyDescription(_observerToSelectorsMap) autorelease];
    return [NSString stringWithFormat:@"<%@: 0x%x>{priority: %i, observer records: %@}", NSStringFromClass([self class]), (unsigned int)(uintptr_t)self, _priority, records];
}

- (void)dealloc
{
    if (_observerToSelectorsMap)
        CFRelease(_observerToSelectorsMap);
    [super dealloc];
}

- (id)initWithPriority:(NSInteger)aPriority
{
    self = [super init];
    if (self)
        _priority = (int)aPriority;
    return self;
}

- (id)init
{
    return [self initWithPriority:0];
}

@end

// An observer and selector, the observer cleared once the registration goes.
@implementation HSAttributeNotificationCenter_HSObserverRecord

- (void)invalidate
{
    _observer = nil;
}

- (SEL)selector
{
    return _selector;
}

- (id)observer
{
    return _observer;
}

- (id)description
{
    if (!_observer)
        return [NSString stringWithFormat:@"<%@: 0x%x> {<invalid>}", NSStringFromClass([self class]), (unsigned int)(uintptr_t)self];
    return [NSString stringWithFormat:@"<%@: 0x%x> {observer: <%@: 0x%x>, selector: %@}", NSStringFromClass([self class]), (unsigned int)(uintptr_t)self,
            NSStringFromClass([_observer class]), (unsigned int)(uintptr_t)_observer, NSStringFromSelector(_selector)];
}

- (id)initWithObserver:(id)aObserver selector:(SEL)aSelector
{
    self = [super init];
    if (self) {
        _observer = aObserver;
        _selector = aSelector;
    }
    return self;
}

- (id)init
{
    return [self initWithObserver:nil selector:NULL];
}

@end

// A change of a set of attributes of an object. The user info can come from
// an invocation, run the first time it is asked for.
@implementation HSAttributeNotification

+ (id)notificationWithChange:(NSInteger)aChange attributeSet:(id)aSet object:(id)aObject userInfoInvocation:(id)aInvocation
{
    return [[[self alloc] initWithChange:aChange attributeSet:aSet object:aObject userInfoInvocation:aInvocation] autorelease];
}

+ (id)notificationWithChange:(NSInteger)aChange attributeSet:(id)aSet object:(id)aObject userInfo:(id)aInfo
{
    return [[[self alloc] initWithChange:aChange attributeSet:aSet object:aObject userInfo:aInfo] autorelease];
}

+ (id)notificationWithChange:(NSInteger)aChange attribute:(id)aAttribute object:(id)aObject userInfoInvocation:(id)aInvocation
{
    return [[[self alloc] initWithChange:aChange attribute:aAttribute object:aObject userInfoInvocation:aInvocation] autorelease];
}

+ (id)notificationWithChange:(NSInteger)aChange attribute:(id)aAttribute object:(id)aObject userInfo:(id)aInfo
{
    return [[[self alloc] initWithChange:aChange attribute:aAttribute object:aObject userInfo:aInfo] autorelease];
}

- (id)description
{
    NSMutableString *attributes = nil;
    if ([_attributeProtocolSet count] == 0) {
        attributes = (NSMutableString *)@"";
    } else {
        for (Protocol *attribute in _attributeProtocolSet) {
            if (!attributes) {
                attributes = [NSMutableString stringWithFormat:@"%s", protocol_getName(attribute)];
                if (!attributes)
                    break;
            } else {
                [attributes appendFormat:@", %s", protocol_getName(attribute)];
            }
        }
    }
    return [NSString stringWithFormat:@"<%@: 0x%x> {change = %@; attributes = {%@}; object = <%@: 0x%x>, userInfo = %@}",
            NSStringFromClass([self class]), (unsigned int)(uintptr_t)self, [self HSAttributeNotification_attributeChangeString], attributes,
            NSStringFromClass([_object class]), (unsigned int)(uintptr_t)_object, [self userInfo]];
}

- (id)HSAttributeNotification_attributeChangeString
{
    switch (_attributeChange) {
    case 0x1:
        return @"HSAttributeWillChange";
    case 0x2:
        return @"HSAttributeDidChange";
    case 0x4:
        return @"HSAttributeWillChangeTemporarily";
    case 0x8:
        return @"HSAttributeDidChangeTemporarily";
    case 0x10:
        return @"HSAttributeWillRestore";
    case 0x20:
        return @"HSAttributeDidRestore";
    case 0x40:
        return @"HSAttributeWillBeginChangeContinuously";
    case 0x80:
        return @"HSAttributeDidEndChangeContinuously";
    }
    return nil;
}

- (id)userInfoIfCreated
{
    return _userInfo;
}

- (id)userInfo
{
    if (!_userInfo && _userInfoInvocation) {
        [_userInfoInvocation invoke];
        [_userInfoInvocation getReturnValue:&_userInfo];
        _userInfo = [_userInfo copy];
        [_userInfoInvocation release];
        _userInfoInvocation = nil;
    }
    return _userInfo;
}

- (id)object
{
    return _object;
}

- (id)attributeProtocolSet
{
    return _attributeProtocolSet;
}

- (NSInteger)attributeChange
{
    return _attributeChange;
}

// A notification not yet asked for its user info lets the copy ask this one.
- (id)notificationWithChange:(NSInteger)aChange attributeSet:(id)aSet object:(id)aObject
{
    if (!_userInfoInvocation)
        return [[[[self class] alloc] initWithChange:aChange attributeSet:aSet object:aObject userInfo:_userInfo] autorelease];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(userInfo)]];
    [invocation setTarget:self];
    [invocation setSelector:@selector(userInfo)];
    // The original left the target unretained, so the copy could outlive it.
    [invocation retainArguments];
    return [[[[self class] alloc] initWithChange:aChange attributeSet:aSet object:aObject userInfoInvocation:invocation] autorelease];
}

- (id)notificationWithObject:(id)aObject
{
    return [self notificationWithChange:_attributeChange attributeSet:_attributeProtocolSet object:aObject];
}

- (id)notificationWithChange:(NSInteger)aChange
{
    return [self notificationWithChange:aChange attributeSet:_attributeProtocolSet object:_object];
}

- (void)dealloc
{
    [_attributeProtocolSet release];
    [_object release];
    [_userInfo release];
    [_userInfoInvocation release];
    [super dealloc];
}

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithChange:(NSInteger)aChange attributeSet:(id)aSet object:(id)aObject userInfoInvocation:(id)aInvocation
{
    self = [super init];
    if (!self)
        return nil;
    _attributeProtocolSet = [aSet copy];
    if (!_attributeProtocolSet) {
        [self release];
        return nil;
    }
    _attributeChange = (int)aChange;
    _object = [aObject retain];
    _userInfoInvocation = [aInvocation retain];
    return self;
}

- (id)initWithChange:(NSInteger)aChange attributeSet:(id)aSet object:(id)aObject userInfo:(id)aInfo
{
    self = [super init];
    if (!self)
        return nil;
    if (aInfo) {
        _userInfo = [aInfo copy];
        if (!_userInfo) {
            [self release];
            return nil;
        }
    }
    _attributeProtocolSet = [aSet copy];
    if (!_attributeProtocolSet) {
        [self release];
        return nil;
    }
    _attributeChange = (int)aChange;
    _object = [aObject retain];
    return self;
}

- (id)initWithChange:(NSInteger)aChange attribute:(id)aAttribute object:(id)aObject userInfoInvocation:(id)aInvocation
{
    return [self initWithChange:aChange attributeSet:[NSEProtocolSet protocolSetWithProtocol:aAttribute] object:aObject userInfoInvocation:aInvocation];
}

- (id)initWithChange:(NSInteger)aChange attribute:(id)aAttribute object:(id)aObject userInfo:(id)aInfo
{
    return [self initWithChange:aChange attributeSet:[NSEProtocolSet protocolSetWithProtocol:aAttribute] object:aObject userInfo:aInfo];
}

@end
