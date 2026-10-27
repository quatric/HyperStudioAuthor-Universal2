#import "HyperPlayerBasePrefix.h"
#import "HSCelMovieObject.h"


@interface HSGIFMovieObject : HSCelMovieObject <HSMediaObject>
{
}
+ (Class)nodeDataClass;
+ (id)defaultUnitClassNames;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (void)importLocalPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (BOOL)canBeStoredAsXMLElement;
- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext;
- (id)XMLElementName;
- (NSSize)defaultSize;
- (id)initWithMedia:(id)aMedia error:(id *)aError;
- (id)initWithMedia:(id)aMedia;
- (id)initWithFramesMedia:(id)aMedia croppingPath:(id)aPath frameSize:(NSSize)aSize precachedSource:(struct CGImageSource *)aSource;
@end

