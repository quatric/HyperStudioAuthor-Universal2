#import "HSRunTimeEditorFactory.h"
#import <objc/runtime.h>

static HSRunTimeEditorFactory *sSharedFactory = nil;

@implementation HSRunTimeEditorFactory

+ (id)sharedInstance
{
    if (sSharedFactory == nil)
        [[HSRunTimeEditorFactory alloc] init];
    return sSharedFactory;
}

- (id)createRunTimeEditorForObject:(id)aObject
{
    id editor = [aObject queryHyperInterface:@protocol(HSRunTimeEditor)];

    if (editor == nil)
        return nil;
    if (![editor canEditObject])
        return nil;
    [self setupRunTimeEditor:editor forObject:aObject];
    return editor;
}

- (void)setupRunTimeEditor:(id)aEditor forObject:(id)aObject
{
    id embedded = [aEditor queryHyperInterface:@protocol(HSEmbeddedEditor)];

    if (embedded != nil)
        [embedded setViewEmbedder:[self viewEmbedderForInterface:[embedded viewEmbeddingInterface]]];
}

- (id)viewEmbedderForInterface:(id)aInterface
{
    if (aInterface == @protocol(HSTextEditorEmbedder) || protocol_isEqual(aInterface, @protocol(HSTextEditorEmbedder)))
        return [[[HSTextViewEmbedder alloc] initWithGradientSupport:YES] autorelease];
    return nil;
}

- (void)dealloc
{
    if (sSharedFactory == self)
        sSharedFactory = nil;
    [super dealloc];
}

// Original quirk kept: a second instance is torn down with [super dealloc] and the singleton returned.
- (id)init
{
    if (sSharedFactory != nil) {
        [super dealloc];
        return sSharedFactory;
    }
    self = [super init];
    if (self != nil)
        sSharedFactory = self;
    return self;
}

@end
