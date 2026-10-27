#import "HyperStudioPrefix.h"


@interface HSHTML5LinkedStacksContext : NSObject
{
    HSDocument *_parentDocument;
    NSMutableDictionary *_linkedStacks;
    NSCountedSet *_linkedStackNames;
    BOOL _areLinkedStacksAllowed;
    unsigned int _maxAllowedLinkedStackLevel;
    unsigned int _currentLinkedStackLevel;
}
- (void)addLinkedStackURL:(id)aURL;
- (id)nameForLinkedStackURL:(id)aURL;
- (BOOL)isRootStackURL:(id)aURL;
- (BOOL)shouldAddLinkedStacks;
- (void)setStackLevel:(NSUInteger)aLevel;
- (void)dealloc;
- (id)initWithLinkedStacksLevel:(NSUInteger)aLevel andDocument:(id)aDocument;
+ (BOOL)areLinkedStacksInDocument:(id)aDocument;
- (id)initWithLinkedStacksLevel:(NSUInteger)aLevel andDocument:(id)aDocument areLinkedStacksAllowed:(BOOL)aAllowed maxAllowedLinkedStackLevel:(NSUInteger)aMax;
@end

