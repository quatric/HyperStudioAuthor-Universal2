#import "HyperStudioPrefix.h"


@interface HSKeysRegistry : NSObject
{
    unsigned char _keysRegistry[100];
    NSMutableSet *_keysCharCodesRegistry;
    BOOL _isRegistryReseted;
}
+ (id)sharedRegistry;
- (void)processKeyUpEvent:(id)aEvent;
- (void)processKeyDownEvent:(id)aEvent;
- (void)resetKeysRegistry;
- (BOOL)isKeyWithCharCodesPressed:(id)aPressed;
- (BOOL)isKeyWithVirtualCodePressed:(unsigned short)aPressed;
- (id)keysCharCodesRegistry;
- (void)dealloc;
@end

