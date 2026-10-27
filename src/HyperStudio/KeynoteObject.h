#import "HyperStudioPrefix.h"
#import "KeynoteNode.h"


@interface KeynoteObject : KeynoteNode
{
    KeynoteImportManager *_importManager;
    BOOL _isDetailed;
}
- (id)description;
- (void)didDetail;
- (void)didInitFromParser;
- (id)nodeAttributes;
- (id)nodeParentIdent;
- (id)nodeIdent;
- (id)nodeId;
- (id)nodeIdRef;
- (id)children;
- (void)detailChildren;
- (void)detailSelf;
- (void)setImportManager:(id)aManager;
- (id)importManager;
- (void)dealloc;
- (id)init;
@end

