#import "NSEMutableProtocolSet.h"
#import <objc/runtime.h>

// Protocols are compared by name before protocol_isEqual (protocols of the
// same name from different images are equal).
static CFStringRef ProtocolCopyDescription(const void *value)
{
    return CFStringCreateWithCStringNoCopy(kCFAllocatorDefault, protocol_getName((Protocol *)value),
                                           kCFStringEncodingUTF8, kCFAllocatorNull);
}

static Boolean ProtocolEqual(const void *value1, const void *value2)
{
    if (value1 == value2)
        return true;
    const char *name1 = protocol_getName((Protocol *)value1);
    if (name1) {
        const char *name2 = protocol_getName((Protocol *)value2);
        if (name2 && strcmp(name1, name2) == 0)
            return protocol_isEqual((Protocol *)value1, (Protocol *)value2);
    }
    return false;
}

// The name's length and a sample of its characters.
static CFHashCode ProtocolHash(const void *value)
{
    const unsigned char *name = (const unsigned char *)protocol_getName((Protocol *)value);
    size_t length;
    if (!name || (length = strlen((const char *)name)) == 0)
        return 0;
    return (CFHashCode)name[length - 1] << 56 | (CFHashCode)name[length * 5 / 6] << 48 |
           (CFHashCode)name[length * 2 / 3] << 40 | (CFHashCode)name[length / 2] << 32 |
           (CFHashCode)name[length / 3] << 24 | (CFHashCode)name[length / 6] << 16 | (CFHashCode)name[0] << 8 |
           length;
}

static const CFSetCallBacks kProtocolSetCallBacks = {
    0, NULL, NULL, ProtocolCopyDescription, ProtocolEqual, ProtocolHash,
};

static CFMutableSetRef ProtocolSetCreateMutable(void)
{
    return CFSetCreateMutable(kCFAllocatorDefault, 0, &kProtocolSetCallBacks);
}

// A set's protocols, copied (sets are changed while their protocols are gone
// through); free() it.
static Protocol **ProtocolSetCopyProtocols(CFSetRef set, CFIndex *count)
{
    *count = CFSetGetCount(set);
    Protocol **protocols = malloc(sizeof(Protocol *) * (*count ? *count : 1));
    if (protocols)
        CFSetGetValues(set, (const void **)protocols);
    else
        *count = 0;
    return protocols;
}

static void TraverseAdoptedProtocols(Protocol *protocol, Boolean (*function)(void *, Protocol *), void *context)
{
    Protocol **adopted = protocol_copyProtocolList(protocol, NULL);
    if (!adopted)
        return;
    for (Protocol **p = adopted; *p; p++)
        if (function(context, *p))
            TraverseAdoptedProtocols(*p, function, context);
    free(adopted);
}

void NSETraverseAdoptedProtocols(Protocol *protocol, Boolean (*function)(void *context, Protocol *protocol),
                                 void *context)
{
    if (function(context, protocol))
        TraverseAdoptedProtocols(protocol, function, context);
}

static Boolean AddProtocol(void *set, Protocol *protocol)
{
    CFSetAddValue(set, protocol);
    return true;
}

// Changing a set that may be shared: the copy is made on the first change.
typedef struct {
    CFSetRef set;
    CFMutableSetRef copy;
    Boolean skip;   // the first protocol (the one traversed from)
} CopyingChange;

static Boolean AddProtocolCopying(void *context, Protocol *protocol)
{
    CopyingChange *change = context;
    if (!change->copy) {
        if (CFSetContainsValue(change->set, protocol))
            return true;
        change->copy = CFSetCreateMutableCopy(CFGetAllocator(change->set), 0, change->set);
        if (!change->copy)
            return false;
    }
    CFSetAddValue(change->copy, protocol);
    return true;
}

static Boolean RemoveProtocolCopying(void *context, Protocol *protocol)
{
    CopyingChange *change = context;
    if (!change->copy) {
        if (!CFSetContainsValue(change->set, protocol))
            return true;
        change->copy = CFSetCreateMutableCopy(CFGetAllocator(change->set), 0, change->set);
        if (!change->copy)
            return false;
    }
    CFSetRemoveValue(change->copy, protocol);
    return true;
}

// Adds the protocols a protocol adopts but not the protocol itself, and
// doesn't go below protocols already there.
static Boolean AddAdoptedProtocolCopying(void *context, Protocol *protocol)
{
    CopyingChange *change = context;
    if (change->skip) {
        change->skip = false;
        return true;
    }
    if (!change->copy) {
        if (CFSetContainsValue(change->set, protocol))
            return false;
        change->copy = CFSetCreateMutableCopy(CFGetAllocator(change->set), 0, change->set);
        if (!change->copy)
            return false;
    } else if (CFSetContainsValue(change->copy, protocol))
        return false;
    CFSetAddValue(change->copy, protocol);
    return true;
}

@implementation NSEProtocolSet

+ (id)protocolSetWithProtocolsAdoptedByProtocolsFromArray:(Protocol **)aArray
{
    return [[[self alloc] initWithProtocolsAdoptedByProtocolsFromArray:aArray] autorelease];
}

+ (id)protocolSetWithProtocolsAdoptedByProtocols:(Protocol *)aProtocols, ...
{
    if (!aProtocols)
        return [self protocolSet];
    CFMutableSetRef set = ProtocolSetCreateMutable();
    if (!set)
        return nil;
    va_list arguments;
    va_start(arguments, aProtocols);
    for (Protocol *protocol = aProtocols; protocol; protocol = va_arg(arguments, Protocol *))
        NSETraverseAdoptedProtocols(protocol, AddProtocol, set);
    va_end(arguments);
    id protocolSet = [[[self alloc] NSEProtocolSet_initWithImplementation:set] autorelease];
    CFRelease(set);
    return protocolSet;
}

+ (id)protocolSetWithProtocolsAdoptedByProtocol:(Protocol *)aProtocol
{
    return [[[self alloc] initWithProtocolsAdoptedByProtocol:aProtocol] autorelease];
}

+ (id)protocolSetWithProtocolsFromArray:(Protocol **)aArray
{
    return [[[self alloc] initWithProtocolsFromArray:aArray] autorelease];
}

+ (id)protocolSetWithProtocols:(Protocol *)aProtocols, ...
{
    if (!aProtocols)
        return [self protocolSet];
    CFMutableSetRef set = ProtocolSetCreateMutable();
    if (!set)
        return nil;
    va_list arguments;
    va_start(arguments, aProtocols);
    for (Protocol *protocol = aProtocols; protocol; protocol = va_arg(arguments, Protocol *))
        CFSetAddValue(set, protocol);
    va_end(arguments);
    id protocolSet = [[[self alloc] NSEProtocolSet_initWithImplementation:set] autorelease];
    CFRelease(set);
    return protocolSet;
}

+ (id)protocolSetWithProtocol:(Protocol *)aProtocol
{
    return [[[self alloc] initWithProtocol:aProtocol] autorelease];
}

+ (id)protocolSet
{
    return [[[self alloc] init] autorelease];
}

// A copy with the protocols the set's protocols adopt.
- (id)copyAdoptedProtocols
{
    if (_implementation) {
        CopyingChange change = { _implementation, NULL, true };
        for (Protocol *protocol in (NSSet *)_implementation) {
            change.skip = true;
            NSETraverseAdoptedProtocols(protocol, AddAdoptedProtocolCopying, &change);
        }
        if (change.copy) {
            NSEProtocolSet *copy = [[NSEProtocolSet alloc] NSEProtocolSet_initWithImplementation:change.copy];
            CFRelease(change.copy);
            return copy;
        }
    }
    return [self copy];
}

// Nil-terminated, autoreleased.
- (Protocol **)allProtocols
{
    CFIndex count = _implementation ? CFSetGetCount(_implementation) : 0;
    if (count == 0) {
        Protocol *none = nil;
        return (Protocol **)[[NSData dataWithBytes:&none length:sizeof none] bytes];
    }
    Protocol **protocols = [[NSMutableData dataWithLength:sizeof(Protocol *) * (count + 1)] mutableBytes];
    if (!protocols)
        return NULL;
    CFSetGetValues(_implementation, (const void **)protocols);
    return protocols;
}

- (BOOL)isSubsetOfProtocolSet:(NSEProtocolSet *)aSet
{
    CFIndex count;
    if (!_implementation || (count = CFSetGetCount(_implementation)) == 0)
        return YES;
    CFSetRef other = [aSet _NSE_implementation];
    if (!other)
        return NO;
    if (other == _implementation)
        return YES;
    if (CFSetGetCount(other) < count)
        return NO;
    for (Protocol *protocol in (NSSet *)_implementation)
        if (!CFSetContainsValue(other, protocol))
            return NO;
    return YES;
}

- (BOOL)intersectsProtocolSet:(NSEProtocolSet *)aSet
{
    if (!_implementation || CFSetGetCount(_implementation) == 0)
        return NO;
    CFSetRef other = [aSet _NSE_implementation];
    if (!other || CFSetGetCount(other) == 0)
        return NO;
    if (other == _implementation)
        return YES;
    for (Protocol *protocol in (NSSet *)other)
        if (CFSetContainsValue(_implementation, protocol))
            return YES;
    return NO;
}

// Whether there are protocols besides the ones listed.
- (BOOL)containsProtocolsExludingProtocolsFromArray:(Protocol **)aArray
{
    CFIndex count;
    if (!_implementation || (count = CFSetGetCount(_implementation)) == 0)
        return NO;
    for (; *aArray; aArray++)
        if (CFSetContainsValue(_implementation, *aArray) && --count == 0)
            return NO;
    return YES;
}

- (BOOL)containsProtocolsExludingProtocols:(Protocol *)aProtocols, ...
{
    if (!_implementation)
        return NO;
    CFIndex count = CFSetGetCount(_implementation);
    if (!aProtocols)
        return count > 0;
    va_list arguments;
    va_start(arguments, aProtocols);
    for (Protocol *protocol = aProtocols; protocol && count; protocol = va_arg(arguments, Protocol *))
        if (CFSetContainsValue(_implementation, protocol))
            count--;
    va_end(arguments);
    return count != 0;
}

- (BOOL)containsProtocol:(Protocol *)aProtocol
{
    return _implementation && CFSetContainsValue(_implementation, aProtocol);
}

- (Protocol *)anyProtocol
{
    for (Protocol *protocol in (NSSet *)_implementation)
        return protocol;
    return nil;
}

- (NSUInteger)count
{
    return _implementation ? CFSetGetCount(_implementation) : 0;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)aState objects:(id *)aObjects count:(NSUInteger)aCount
{
    return [(NSSet *)_implementation countByEnumeratingWithState:aState objects:aObjects count:aCount];
}

- (id)description
{
    NSMutableString *protocols = nil;
    if (!_implementation || CFSetGetCount(_implementation) == 0)
        protocols = (NSMutableString *)@"";
    else
        for (Protocol *protocol in (NSSet *)_implementation) {
            if (!protocols) {
                protocols = [NSMutableString stringWithFormat:@"%s", protocol_getName(protocol)];
                if (!protocols)
                    break;
            } else
                [protocols appendFormat:@", %s", protocol_getName(protocol)];
        }
    return [NSString stringWithFormat:@"<%@: %p>{%@}", NSStringFromClass([self class]), self, protocols];
}

- (NSUInteger)hash
{
    return _implementation ? CFHash(_implementation) : 0;
}

- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[NSEProtocolSet class]])
        return NO;
    // A subclass's instance decides.
    if ([aEqual isKindOfClass:[self class]] && ![aEqual isMemberOfClass:[self class]])
        return [aEqual isEqual:self];
    return [self isEqualToProtocolSet:aEqual];
}

- (BOOL)isEqualToProtocolSet:(NSEProtocolSet *)aSet
{
    if (aSet == self)
        return YES;
    if (!_implementation)
        return [aSet count] == 0;
    CFSetRef other = [aSet _NSE_implementation];
    if (other)
        return CFEqual(_implementation, other);
    return CFSetGetCount(_implementation) == 0;
}

- (id)mutableCopyWithZone:(NSZone *)aZone
{
    return [[NSEMutableProtocolSet allocWithZone:aZone] initWithProtocolSet:self];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [self retain];
}

- (void)dealloc
{
    if (_implementation)
        CFRelease(_implementation);
    [super dealloc];
}

- (id)initWithProtocolsAdoptedByProtocolsFromArray:(Protocol **)aArray
{
    self = [self init];
    if (!self)
        return nil;
    if (*aArray) {
        _implementation = ProtocolSetCreateMutable();
        if (!_implementation) {
            [self release];
            return nil;
        }
        for (; *aArray; aArray++)
            NSETraverseAdoptedProtocols(*aArray, AddProtocol, _implementation);
    }
    return self;
}

- (id)initWithProtocolsAdoptedByProtocols:(Protocol *)aProtocols, ...
{
    self = [self init];
    if (!self)
        return nil;
    if (aProtocols) {
        _implementation = ProtocolSetCreateMutable();
        if (!_implementation) {
            [self release];
            return nil;
        }
        va_list arguments;
        va_start(arguments, aProtocols);
        for (Protocol *protocol = aProtocols; protocol; protocol = va_arg(arguments, Protocol *))
            NSETraverseAdoptedProtocols(protocol, AddProtocol, _implementation);
        va_end(arguments);
    }
    return self;
}

- (id)initWithProtocolsAdoptedByProtocol:(Protocol *)aProtocol
{
    self = [self init];
    if (!self)
        return nil;
    _implementation = ProtocolSetCreateMutable();
    if (!_implementation) {
        [self release];
        return nil;
    }
    NSETraverseAdoptedProtocols(aProtocol, AddProtocol, _implementation);
    return self;
}

- (id)initWithProtocolSet:(NSEProtocolSet *)aSet
{
    return [self NSEProtocolSet_initWithImplementation:[aSet _NSE_implementation]];
}

- (id)initWithProtocolsFromArray:(Protocol **)aArray
{
    self = [self init];
    if (!self)
        return nil;
    if (*aArray) {
        _implementation = ProtocolSetCreateMutable();
        if (!_implementation) {
            [self release];
            return nil;
        }
        for (; *aArray; aArray++)
            CFSetAddValue(_implementation, *aArray);
    }
    return self;
}

- (id)initWithProtocols:(Protocol *)aProtocols, ...
{
    self = [self init];
    if (!self)
        return nil;
    if (aProtocols) {
        _implementation = ProtocolSetCreateMutable();
        if (!_implementation) {
            [self release];
            return nil;
        }
        va_list arguments;
        va_start(arguments, aProtocols);
        for (Protocol *protocol = aProtocols; protocol; protocol = va_arg(arguments, Protocol *))
            CFSetAddValue(_implementation, protocol);
        va_end(arguments);
    }
    return self;
}

- (id)initWithProtocol:(Protocol *)aProtocol
{
    self = [self init];
    if (!self)
        return nil;
    _implementation = ProtocolSetCreateMutable();
    if (!_implementation) {
        [self release];
        return nil;
    }
    CFSetAddValue(_implementation, aProtocol);
    return self;
}

- (void)_NSE_setImplementation:(struct __CFSet *)aImplementation
{
    if (_implementation == aImplementation)
        return;
    if (aImplementation)
        CFRetain(aImplementation);
    if (_implementation)
        CFRelease(_implementation);
    _implementation = aImplementation;
}

// The storage to change, copied if it's shared or (when expanding) created.
- (struct __CFSet *)_NSE_mutableImplementationForExpanding:(BOOL)aExpanding
{
    if (!_implementation) {
        if (aExpanding)
            _implementation = ProtocolSetCreateMutable();
        return _implementation;
    }
    if (CFGetRetainCount(_implementation) < 2)
        return _implementation;
    CFMutableSetRef copy = CFSetCreateMutableCopy(CFGetAllocator(_implementation), 0, _implementation);
    if (!copy)
        return NULL;
    CFRelease(_implementation);
    _implementation = copy;
    return copy;
}

// The storage if it isn't shared.
- (struct __CFSet *)_NSE_mutableImplementationIfExists
{
    if (_implementation && CFGetRetainCount(_implementation) < 2)
        return _implementation;
    return NULL;
}

- (struct __CFSet *)_NSE_implementation
{
    return _implementation;
}

- (id)NSEProtocolSet_initWithImplementation:(struct __CFSet *)aImplementation
{
    self = [self init];
    if (!self)
        return nil;
    _implementation = aImplementation;
    if (_implementation)
        CFRetain(_implementation);
    return self;
}

@end

@implementation NSEMutableProtocolSet

// Adds the protocols the set's protocols adopt.
- (void)addAdoptedProtocols
{
    CFSetRef set = [self _NSE_implementation];
    if (!set || CFSetGetCount(set) == 0)
        return;
    CopyingChange change = { set, [self _NSE_mutableImplementationIfExists], true };
    CFIndex count;
    Protocol **protocols = ProtocolSetCopyProtocols(set, &count);
    for (CFIndex i = 0; i < count; i++) {
        change.skip = true;
        NSETraverseAdoptedProtocols(protocols[i], AddAdoptedProtocolCopying, &change);
    }
    free(protocols);
    if (change.copy && change.copy != set) {
        [self _NSE_setImplementation:change.copy];
        CFRelease(change.copy);
    }
}

// Removes a protocol and the protocols it adopts.
- (void)removeProtocolsAdoptedByProtocol:(Protocol *)aProtocol
{
    CFSetRef set = [self _NSE_implementation];
    if (!set || CFSetGetCount(set) == 0)
        return;
    CopyingChange change = { set, [self _NSE_mutableImplementationIfExists], false };
    NSETraverseAdoptedProtocols(aProtocol, RemoveProtocolCopying, &change);
    if (change.copy && change.copy != set) {
        [self _NSE_setImplementation:change.copy];
        CFRelease(change.copy);
    }
}

// Adds a protocol and the protocols it adopts.
- (void)addProtocolsAdoptedByProtocol:(Protocol *)aProtocol
{
    CopyingChange change = { [self _NSE_implementation], NULL, false };
    if (!change.set)
        change.set = change.copy = [self _NSE_mutableImplementationForExpanding:YES];
    else
        change.copy = [self _NSE_mutableImplementationIfExists];
    NSETraverseAdoptedProtocols(aProtocol, AddProtocolCopying, &change);
    if (change.copy && change.copy != change.set) {
        [self _NSE_setImplementation:change.copy];
        CFRelease(change.copy);
    }
}

- (void)setProtocolSet:(NSEProtocolSet *)aSet
{
    [self _NSE_setImplementation:[aSet _NSE_implementation]];
}

- (void)unionProtocolSet:(NSEProtocolSet *)aSet
{
    CFSetRef other = [aSet _NSE_implementation];
    CFIndex otherCount;
    if (!other || (otherCount = CFSetGetCount(other)) == 0)
        return;
    CFSetRef set = [self _NSE_implementation];
    CFIndex count;
    if (!set || (count = CFSetGetCount(set)) == 0) {
        [self _NSE_setImplementation:(CFMutableSetRef)other];
        return;
    }
    // Without storage of its own, the set adds the smaller set's protocols to
    // the larger one (copied once a protocol is missing from it).
    CFSetRef base = set;
    CFMutableSetRef target = [self _NSE_mutableImplementationIfExists];
    if (!target) {
        target = (CFMutableSetRef)set;
        if (count < otherCount) {
            target = (CFMutableSetRef)other;
            base = other;
            other = set;
        }
    }
    CFIndex protocolCount;
    Protocol **protocols = ProtocolSetCopyProtocols(other, &protocolCount);
    for (CFIndex i = 0; i < protocolCount; i++) {
        if (target == base) {
            if (CFSetContainsValue(base, protocols[i]))
                continue;
            target = CFSetCreateMutableCopy(CFGetAllocator(base), 0, base);
            if (!target)
                break;
        }
        CFSetAddValue(target, protocols[i]);
    }
    free(protocols);
    if (target) {
        [self _NSE_setImplementation:target];
        if (target != base)
            CFRelease(target);
    }
}

- (void)minusProtocolSet:(NSEProtocolSet *)aSet
{
    CFSetRef set = [self _NSE_implementation];
    if (!set || CFSetGetCount(set) == 0)
        return;
    CFSetRef other = [aSet _NSE_implementation];
    if (!other)
        return;
    CFMutableSetRef target = [self _NSE_mutableImplementationIfExists];
    CFIndex count;
    Protocol **protocols = ProtocolSetCopyProtocols(other, &count);
    for (CFIndex i = 0; i < count; i++) {
        if (!target) {
            if (!CFSetContainsValue(set, protocols[i]))
                continue;
            target = [self _NSE_mutableImplementationForExpanding:NO];
            if (!target)
                break;
        }
        CFSetRemoveValue(target, protocols[i]);
    }
    free(protocols);
}

- (void)intersectProtocolSet:(NSEProtocolSet *)aSet
{
    CFSetRef set = [self _NSE_implementation];
    CFIndex count;
    if (!set || (count = CFSetGetCount(set)) == 0)
        return;
    CFSetRef other = [aSet _NSE_implementation];
    CFIndex otherCount;
    if (!other || (otherCount = CFSetGetCount(other)) == 0) {
        [self removeAllProtocols];
        return;
    }
    // Goes through the smaller set: once its first protocol shows whether most
    // are kept, either removes the others from a copy of it or adds the kept
    // ones to a new set.
    CFSetRef smaller = set, larger = other;
    if (otherCount < count) {
        smaller = other;
        larger = set;
    }
    CFMutableSetRef result = (CFMutableSetRef)smaller;
    BOOL keptFirst = NO, droppedFirst = NO;
    CFIndex protocolCount;
    Protocol **protocols = ProtocolSetCopyProtocols(smaller, &protocolCount);
    for (CFIndex i = 0; i < protocolCount; i++) {
        Protocol *protocol = protocols[i];
        if (!CFSetContainsValue(larger, protocol)) {
            if (keptFirst) {
                if (result == smaller) {
                    result = CFSetCreateMutableCopy(CFGetAllocator(smaller), 0, smaller);
                    if (!result)
                        break;
                }
                CFSetRemoveValue(result, protocol);
            } else
                droppedFirst = YES;
        } else if (droppedFirst) {
            if (result == smaller) {
                result = ProtocolSetCreateMutable();
                if (!result)
                    break;
            }
            CFSetAddValue(result, protocol);
        } else
            keptFirst = YES;
    }
    free(protocols);
    if (!result)
        return;
    if (result == smaller && droppedFirst) {
        // None is kept.
        [self removeAllProtocols];
        return;
    }
    [self _NSE_setImplementation:result];
    if (result != smaller)
        CFRelease(result);
}

- (void)removeAllProtocols
{
    CFMutableSetRef set = [self _NSE_mutableImplementationIfExists];
    if (set)
        CFSetRemoveAllValues(set);
    else
        [self _NSE_setImplementation:NULL];
}

- (void)removeProtocol:(Protocol *)aProtocol
{
    CFSetRef set = [self _NSE_implementation];
    CFIndex count;
    if (!set || (count = CFSetGetCount(set)) == 0)
        return;
    CFMutableSetRef target = [self _NSE_mutableImplementationIfExists];
    if (!target) {
        if (!CFSetContainsValue(set, aProtocol))
            return;
        if (count == 1) {
            [self _NSE_setImplementation:NULL];
            return;
        }
        target = [self _NSE_mutableImplementationForExpanding:NO];
        if (!target)
            return;
    }
    CFSetRemoveValue(target, aProtocol);
}

- (void)addProtocol:(Protocol *)aProtocol
{
    CFMutableSetRef set = [self _NSE_mutableImplementationIfExists];
    if (!set) {
        CFSetRef shared = [self _NSE_implementation];
        if (shared && CFSetContainsValue(shared, aProtocol))
            return;
        set = [self _NSE_mutableImplementationForExpanding:YES];
        if (!set)
            return;
    }
    CFSetAddValue(set, aProtocol);
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[NSEProtocolSet allocWithZone:aZone] initWithProtocolSet:self];
}

@end
