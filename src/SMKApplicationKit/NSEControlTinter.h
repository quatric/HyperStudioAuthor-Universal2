#import "SMKApplicationKitPrefix.h"


@interface NSEControlTinter : NSObject
{
    id<NSEControlTinterDelegate> _delegate;
    struct __CFDictionary *_keyToTintMap;
}
+ (id)setTinterWithDelegate:(id)aDelegate forKeysAndControls:(id)aKey, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)tintControl:(id)aControl;
+ (void)removeTinterForControl:(id)aControl;
+ (void)setTinter:(id)aTinter forControl:(id)aControl;
+ (id)tinterForControl:(id)aControl;
- (void)NSEControlTinter_applyTint:(NSUInteger)aTint toControl:(id)aControl;
- (void)removeKey:(id)aKey;
- (void)addKey:(id)aKey;
- (void)setValue:(id)aValue forKey:(id)aKey forTint:(NSUInteger)aTint;
- (struct __CFDictionary *)NSEControlTinter_createKeyToTintMap;
- (id)valueForKey:(id)aKey forTint:(NSUInteger)aTint;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
@end

@interface __NSEControlTinterLink : NSObject
{
    id _control;
    NSEControlTinter *_tinter;
    unsigned int _currentTint;
    unsigned int _tintChangeCounter:31;
    unsigned int _isDefaultTint:1;
}
- (void)__NSEControlTinterLink_defaultControlTintDidChange:(id)aChange;
- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext;
- (void)endTintChange;
- (void)beginTintChange;
- (void)__NSEControlTinterLink_tintDidChange;
- (NSUInteger)currentTint;
- (id)tinter;
- (void)dealloc;
- (id)initWithControl:(id)aControl tinter:(id)aTinter;
- (id)init;
@end

