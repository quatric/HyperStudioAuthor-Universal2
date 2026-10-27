#import "HyperStudioPrefix.h"


@interface HSHTML5LinkedStacksContext : NSObject
{
    HSDocument *_parentDocument;
    NSMutableDictionary *_linkedStacks;
    NSCountedSet *_linkedStackNames;
    unsigned int _currentLinkedStackLevel;
}
- (void)addLinkedStackURL:(id)aURL;
- (id)nameForLinkedStackURL:(id)aURL;
- (BOOL)isRootStackURL:(id)aURL;
- (BOOL)shouldAddLinkedStacks;
- (void)setStackLevel:(NSUInteger)aLevel;
- (void)dealloc;
- (id)initWithLinkedStacksLevel:(NSUInteger)aLevel andDocument:(id)aDocument;
@end

