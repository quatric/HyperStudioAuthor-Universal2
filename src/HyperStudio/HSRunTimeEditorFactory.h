#import "HyperStudioPrefix.h"


@interface HSRunTimeEditorFactory : NSObject
{
}
+ (id)sharedInstance;
- (id)createRunTimeEditorForObject:(id)aObject;
- (void)setupRunTimeEditor:(id)aEditor forObject:(id)aObject;
- (id)viewEmbedderForInterface:(id)aInterface;
- (void)dealloc;
- (id)init;
@end

