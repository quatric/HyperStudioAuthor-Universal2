#import "SMKApplicationKitPrefix.h"

// Calls function with a protocol and, while it returns true, with each protocol
// that protocol adopts (depth first).
void NSETraverseAdoptedProtocols(Protocol *protocol, Boolean (*function)(void *context, Protocol *protocol),
                                 void *context);

// Sets of protocols; mutable sets share their storage with copies until either
// one changes.
@interface NSEProtocolSet : NSObject <NSCopying, NSMutableCopying, NSFastEnumeration>
{
    struct __CFSet *_implementation;
}
+ (id)protocolSetWithProtocolsAdoptedByProtocolsFromArray:(Protocol **)aArray;
+ (id)protocolSetWithProtocolsAdoptedByProtocols:(Protocol *)aProtocols, ... NS_REQUIRES_NIL_TERMINATION;
+ (id)protocolSetWithProtocolsAdoptedByProtocol:(Protocol *)aProtocol;
+ (id)protocolSetWithProtocolsFromArray:(Protocol **)aArray;
+ (id)protocolSetWithProtocols:(Protocol *)aProtocols, ... NS_REQUIRES_NIL_TERMINATION;
+ (id)protocolSetWithProtocol:(Protocol *)aProtocol;
+ (id)protocolSet;
- (id)copyAdoptedProtocols;
- (Protocol **)allProtocols;
- (BOOL)isSubsetOfProtocolSet:(NSEProtocolSet *)aSet;
- (BOOL)intersectsProtocolSet:(NSEProtocolSet *)aSet;
- (BOOL)containsProtocolsExludingProtocolsFromArray:(Protocol **)aArray;
- (BOOL)containsProtocolsExludingProtocols:(Protocol *)aProtocols, ... NS_REQUIRES_NIL_TERMINATION;
- (BOOL)containsProtocol:(Protocol *)aProtocol;
- (Protocol *)anyProtocol;
- (NSUInteger)count;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)aState objects:(id *)aObjects count:(NSUInteger)aCount;
- (id)description;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (BOOL)isEqualToProtocolSet:(NSEProtocolSet *)aSet;
- (id)mutableCopyWithZone:(NSZone *)aZone;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (id)initWithProtocolsAdoptedByProtocolsFromArray:(Protocol **)aArray;
- (id)initWithProtocolsAdoptedByProtocols:(Protocol *)aProtocols, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithProtocolsAdoptedByProtocol:(Protocol *)aProtocol;
- (id)initWithProtocolSet:(NSEProtocolSet *)aSet;
- (id)initWithProtocolsFromArray:(Protocol **)aArray;
- (id)initWithProtocols:(Protocol *)aProtocols, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithProtocol:(Protocol *)aProtocol;
- (void)_NSE_setImplementation:(struct __CFSet *)aImplementation;
- (struct __CFSet *)_NSE_mutableImplementationForExpanding:(BOOL)aExpanding;
- (struct __CFSet *)_NSE_mutableImplementationIfExists;
- (struct __CFSet *)_NSE_implementation;
- (id)NSEProtocolSet_initWithImplementation:(struct __CFSet *)aImplementation;
@end

@interface NSEMutableProtocolSet : NSEProtocolSet
{
}
- (void)addAdoptedProtocols;
- (void)removeProtocolsAdoptedByProtocol:(Protocol *)aProtocol;
- (void)addProtocolsAdoptedByProtocol:(Protocol *)aProtocol;
- (void)setProtocolSet:(NSEProtocolSet *)aSet;
- (void)unionProtocolSet:(NSEProtocolSet *)aSet;
- (void)minusProtocolSet:(NSEProtocolSet *)aSet;
- (void)intersectProtocolSet:(NSEProtocolSet *)aSet;
- (void)removeAllProtocols;
- (void)removeProtocol:(Protocol *)aProtocol;
- (void)addProtocol:(Protocol *)aProtocol;
- (id)copyWithZone:(NSZone *)aZone;
@end
