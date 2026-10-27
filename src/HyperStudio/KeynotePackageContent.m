#import "KeynotePackageContent.h"

@implementation KeynotePackageContent

- (void)setIndexXmlTree:(struct __CFTree *)aTree
{
    if (_indexXmlTree != aTree) {
        if (_indexXmlTree != NULL)
            CFRelease(_indexXmlTree);
        // Fix: CFRetain(NULL) crashed.
        _indexXmlTree = aTree != NULL ? (struct __CFTree *)CFRetain(aTree) : NULL;
    }
}

- (struct __CFTree *)indexXmlTree
{
    return _indexXmlTree;
}

- (void)setResources:(id)aResources
{
    if (_resources != aResources) {
        [_resources release];
        _resources = [aResources retain];
    }
}

- (id)resources
{
    return _resources;
}

- (void)dealloc
{
    [_resources release];
    if (_indexXmlTree != NULL)
        CFRelease(_indexXmlTree);
    [super dealloc];
}

@end
